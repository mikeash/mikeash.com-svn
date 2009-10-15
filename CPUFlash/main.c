// /Developer/usr/bin/clang -W -Wall -Wno-unused-parameter -framework IOKit -framework CoreFoundation -o CPUFlash main.c keyboard_leds.c

#include <dispatch/dispatch.h>
#include <mach/mach.h>
#include <stdio.h>
#include <stdlib.h>

#include "keyboard_leds.h"


static host_cpu_load_info_data_t GetLoadInfo(void)
{
    host_name_port_t host = mach_host_self();
    host_cpu_load_info_data_t loadInfo;
    mach_msg_type_number_t count = HOST_CPU_LOAD_INFO_COUNT;
    kern_return_t ret = host_statistics(host, HOST_CPU_LOAD_INFO, (host_info_t)&loadInfo, &count);
    if(ret != KERN_SUCCESS)
    {
        fprintf(stderr, "ERROR: host_statistics returned %d\n", ret);
        exit(1);
    }
    return loadInfo;
}

double GetLoadSinceLastCall(void)
{
    static natural_t lastExecutingTotal;
    static natural_t lastTotal;
    
    host_cpu_load_info_data_t loadInfo = GetLoadInfo();
    natural_t executingTotal = loadInfo.cpu_ticks[CPU_STATE_USER] + loadInfo.cpu_ticks[CPU_STATE_SYSTEM] + loadInfo.cpu_ticks[CPU_STATE_NICE];
    natural_t total = executingTotal + loadInfo.cpu_ticks[CPU_STATE_IDLE];
    
    natural_t executingDelta = executingTotal - lastExecutingTotal;
    natural_t totalDelta = total - lastTotal;
    
    double load = (double)executingDelta / totalDelta;
    
    lastExecutingTotal = executingTotal;
    lastTotal = total;
    
    return load;
}

int main(int argc, char **argv)
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 50000000, 0);
    
    __block int current = 0;
    __block int iterations = 0;
    __block double laston = 0;
    __block int turnoff = 0;
    
    dispatch_source_set_event_handler(timer, ^{
        // every so often, reset things
        if(iterations > 1000000000)
        {
            iterations = 0;
            laston = 0;
        }
        
        int newstate = 0;
        
        turnoff = !turnoff;
        if(!turnoff)
        {
            iterations++;
            
            double load = GetLoadSinceLastCall();
            if(load < 0.0001)
                load = 0.0001;
            double delta = 1.0 / load;
            if(delta <= iterations - laston)
            {
                newstate = 1;
                laston += delta;
            }
        }
        
        if(newstate != current)
        {
            int ret = manipulate_led(kHIDUsage_LED_CapsLock, newstate);
            current = newstate;
            if(ret)
            {
                fprintf(stderr, "ERROR: manipulate_led returned %d\n", ret);
                exit(1);
            }
        }
    });
    
    dispatch_resume(timer);
    
    dispatch_main();
    
    return 0;
}
