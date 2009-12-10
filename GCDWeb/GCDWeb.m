// gcc --std=c99 -W -Wall -Wno-unused-parameter -I../MAGenerator -framework Foundation GCDWeb.m ../MAGenerator/MAGenerator.m

#include <dispatch/dispatch.h>
#include <errno.h>
#include <libkern/OSAtomic.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>

#include <MAGenerator.h>


#define LOG_ENABLED 0

#if LOG_ENABLED
#define LOG(fmt, ...) fprintf(stderr, fmt "\n", __VA_ARGS__)
#else
#define LOG(...) do { } while(0)
#endif

#define CHECK(call) Check(call, __FILE__, __LINE__, #call)


struct Connection
{
    volatile int32_t refcount;
    int sock;
};


static int Check(int retval, const char *file, int line, const char *name)
{
    if(retval == -1)
    {
        fprintf(stderr, "%s:%d: %s returned error %d (%s)\n", file, line, name, errno, strerror(errno));
        exit(1);
    }
    return retval;
}

static dispatch_source_t NewFDSource(int s, dispatch_source_type_t type, dispatch_block_t block)
{
    dispatch_source_t source = dispatch_source_create(type, s, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_event_handler(source, block);
    return source;
}

static struct Connection *NewConnection(int sock)
{
    struct Connection *c = malloc(sizeof(*c));
    c->refcount = 2; // 1 read, 1 write
    c->sock = sock;
    return c;
}

static void ReleaseConnection(struct Connection *c)
{
    if(OSAtomicDecrement32(&c->refcount) == 0)
    {
        close(c->sock);
        free(c);
    }
}

static NSData *Data(NSString *s)
{
    return [s dataUsingEncoding: NSUTF8StringEncoding];
}

GENERATOR(NSData *, ErrCodeWriter(int code), (void))
{
    GENERATOR_BEGIN(void)
    {
        if(code == 400)
            GENERATOR_YIELD(Data(@"HTTP/1.0 400 Bad Request"));
        else if(code == 501)
            GENERATOR_YIELD(Data(@"HTTP/1.0 501 Not Implemented"));
        else
            GENERATOR_YIELD(Data(@"HTTP/1.0 500 Internal Server Error"));
        
        NSString *str = [NSString stringWithFormat:
            @"\r\n"
            @"Content-type: text/html\r\n"
            @"\r\n"
            @"The server generated error code %d while processing the HTTP request",
            code];
        GENERATOR_YIELD(Data(str));
    }
    GENERATOR_END
}

NSString *HTMLEscape(NSString *s)
{
    s = [s stringByReplacingOccurrencesOfString: @"&" withString: @"&amp;"];
    s = [s stringByReplacingOccurrencesOfString: @"<" withString: @"&lt;"];
    s = [s stringByReplacingOccurrencesOfString: @">" withString: @"&gt;"];
    return s;
}

GENERATOR(NSData *, NotFoundHandler(NSString *resource), (void))
{
    GENERATOR_BEGIN(void)
    {
        NSString *str = [NSString stringWithFormat:
            @"HTTP/1.0 404 Not Found\r\n"
            @"Content-type: text/html\r\n"
            @"\r\n"
            @"The resource %@ could not be found",
            HTMLEscape(resource)];
        GENERATOR_YIELD(Data(str));
    }
    GENERATOR_END
}

GENERATOR(NSData *, RootHandler(NSString *resource), (void))
{
    GENERATOR_BEGIN(void)
    {
        NSString *str = @"HTTP/1.0 200 OK\r\n"
                        @"Content-type: text/html\r\n"
                        @"\r\n"
                        @"Welcome to GCDWeb. There isn't much here. <a href=\"listing\">Try the listing.</a>";
        GENERATOR_YIELD(Data(str));
    }
    GENERATOR_END
}

GENERATOR(NSData *, ListingHandler(NSString *resource), (void))
{
    __block NSEnumerator *enumerator = nil;
    GENERATOR_BEGIN(void)
    {
        NSString *str = @"HTTP/1.0 200 OK\r\n"
                        @"Content-type: text/html; charset=utf-8\r\n"
                        @"\r\n"
                        @"Directory listing of <tt>/tmp</tt>:<p>";
        GENERATOR_YIELD(Data(str));
        
        NSFileManager *fm = [[NSFileManager alloc] init]; // +defaultManager is not thread safe
        NSArray *contents = [fm contentsOfDirectoryAtPath: @"/tmp" error: NULL];
        enumerator = [[contents objectEnumerator] retain];
        [fm release];
        
        NSString *file;
        while((file = [enumerator nextObject]))
        {
            GENERATOR_YIELD(Data(file));
            // note: file is no longer valid after this point!
            
            GENERATOR_YIELD(Data(@"<br>"));
        }
    }
    GENERATOR_CLEANUP
    {
        [enumerator release];
    }
    GENERATOR_END
}

GENERATOR(int, ByteGenerator(NSData *(^contentGenerator)(void)), (void))
{
    __block NSData *data = nil;
    __block NSUInteger cursor = 0;
    GENERATOR_BEGIN(void)
    {
        do
        {
            if(cursor < [data length])
            {
                const unsigned char *ptr = [data bytes];
                GENERATOR_YIELD((int)ptr[cursor++]);
            }
            else
            {
                [data release];
                data = [contentGenerator() retain];
                cursor = 0;
            }
        } while(data);
        GENERATOR_YIELD(-1);
    }
    GENERATOR_CLEANUP
    {
        [data release];
    }
    GENERATOR_END
}

static void Write(struct Connection *connection, NSData *(^contentGenerator)(void))
{
    int (^byteGenerator)(void) = ByteGenerator(contentGenerator);
    __block dispatch_source_t source;
    source = NewFDSource(connection->sock, DISPATCH_SOURCE_TYPE_WRITE, ^{
        int byte = byteGenerator();
        BOOL err = NO;
        if(byte != -1) // EOF
        {
            unsigned char buf = byte;
            int howMuch;
            do
            {
                howMuch = write(connection->sock, &buf, 1);
            }
            while(howMuch == -1 && (errno == EAGAIN || errno == EINTR));
            if(howMuch == -1)
            {
                err = YES;
                LOG("write returned error %d (%s)", errno, strerror(errno));
            }
        }
        if(byte == -1 || err)
        {
            LOG("Done servicing %d", connection->sock);
            dispatch_source_cancel(source);
        }
    });
    dispatch_source_set_cancel_handler(source, ^{
        CHECK(shutdown(connection->sock, SHUT_WR));
        ReleaseConnection(connection);
        dispatch_release(source);
    });
    dispatch_resume(source);
}

static NSData *(^ContentGeneratorForResource(NSString *resource))(void)
{
    if([resource isEqual: @"/"])
        return RootHandler(resource);
    if([resource isEqual: @"/listing"])
        return ListingHandler(resource);
    
    return NotFoundHandler(resource);
}

static void ProcessResource(struct Connection *connection, NSString *resource)
{
    Write(connection, ContentGeneratorForResource(resource));
}

GENERATOR(int, RequestReader(struct Connection *connection), (char))
{
    NSMutableData *buffer = [NSMutableData data];
    GENERATOR_BEGIN(char c)
    {
        // read the request method
        while(c != '\r' && c != '\n' && c != ' ')
        {
            [buffer appendBytes: &c length: 1];
            GENERATOR_YIELD(0);
        }
        
        // if the line ended before we got a space then we don't understand the request
        if(c != ' ')
        {
            LOG("Got a bad request from the client on %d", connection->sock);
            Write(connection, ErrCodeWriter(400));
            GENERATOR_YIELD(1); // signal that we got enough for a response
        }
        else
        {
            // we only support GET
            if([buffer length] != 3 || memcmp([buffer bytes], "GET", 3) != 0)
            {
                LOG("Got an unknown method from the client on %d", connection->sock);
                Write(connection, ErrCodeWriter(501));
                GENERATOR_YIELD(1); // signal that we got enough for a response
            }
            else
            {
                // skip over the delimeter
                GENERATOR_YIELD(0);
                
                // read the resource
                [buffer setLength: 0];
                while(c != '\r' && c != '\n' && c != ' ')
                {
                    [buffer appendBytes: &c length: 1];
                    GENERATOR_YIELD(0);
                }
                
                LOG("Servicing request from the client on %d", connection->sock);
                NSString *s = [[[NSString alloc] initWithData: buffer encoding: NSUTF8StringEncoding] autorelease];
                if(!s)
                    Write(connection, ErrCodeWriter(400));
                else
                    ProcessResource(connection, s);
                GENERATOR_YIELD(1); // signal that we got enough for a response
            }
        }
        
        // we just ignore anything else sent by the client
        while(1)
            GENERATOR_YIELD(0);
    }
    GENERATOR_END
}

static void AcceptConnection(int listenSock)
{
    struct sockaddr addr;
    socklen_t addrlen = sizeof(addr);
    int newSock = CHECK(accept(listenSock, &addr, &addrlen));
    LOG("new connection on socket %d, new socket is %d", listenSock, newSock);
    
    struct Connection *connection = NewConnection(newSock);
    
    int (^requestReader)(char) = RequestReader(connection);
    
    __block BOOL didSendResponse = NO;
    __block dispatch_source_t source; // gcc won't compile if the next line is an initializer?!
    source = NewFDSource(newSock, DISPATCH_SOURCE_TYPE_READ, ^{
        char c;
        LOG("reading from %d", newSock);
        int howMuch = read(newSock, &c, 1);
        LOG("read from %d returned %d (errno is %d %s)", newSock, howMuch, errno, strerror(errno));
        
        BOOL isErr = NO;
        if(howMuch == -1 && errno != EAGAIN && errno != EINTR)
        {
            LOG("read returned error %d (%s)", errno, strerror(errno));
            isErr = YES;
        }
        if(howMuch > 0)
        {
            int ret = requestReader(c);
            if(ret)
                didSendResponse = YES;
        }
        if(howMuch == 0 || isErr)
        {
            if(!didSendResponse)
                Write(connection, ErrCodeWriter(400));
            dispatch_source_cancel(source);
        }
    });
    dispatch_source_set_cancel_handler(source, ^{
        ReleaseConnection(connection);
        dispatch_release(source);
    });
    dispatch_resume(source);
}

static void SetupListenSource(int s)
{
    CHECK(listen(s, 16));
    
    dispatch_source_t source = NewFDSource(s, DISPATCH_SOURCE_TYPE_READ, ^{
        AcceptConnection(s);
    });
    dispatch_resume(source);
    
    // leak it, it lives forever
}

static void SetupSockets(int port)
{
    int listenSocket4 = CHECK(socket(PF_INET, SOCK_STREAM, 0));
    int listenSocket6 = CHECK(socket(PF_INET6, SOCK_STREAM, 0));
    
    struct sockaddr_in addr4 = { sizeof(addr4), AF_INET, htons(port), { INADDR_ANY }, { 0 } };
    struct sockaddr_in6 addr6 = { sizeof(addr6), AF_INET6, htons(port), 0, IN6ADDR_ANY_INIT, 0 };
    
    int yes = 1;
    CHECK(setsockopt(listenSocket4, SOL_SOCKET, SO_REUSEADDR, (void *)&yes, sizeof(yes)));
    CHECK(setsockopt(listenSocket6, SOL_SOCKET, SO_REUSEADDR, (void *)&yes, sizeof(yes)));
    CHECK(bind(listenSocket4, (void *)&addr4, sizeof(addr4)));
    CHECK(bind(listenSocket6, (void *)&addr6, sizeof(addr6)));
    
    SetupListenSource(listenSocket4);
    SetupListenSource(listenSocket6);
}

int main(int argc, char **argv)
{
    if(argc != 2)
    {
        fprintf(stderr, "usage: %s <port>\n", argv[0]);
        return 1;
    }
    
    int port = atoi(argv[1]);
    SetupSockets(port);
    
    LOG("listening on port %d", port);
    
    dispatch_main();
    
    return 0;
}

