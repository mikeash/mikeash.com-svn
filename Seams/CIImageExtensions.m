//
//  CIImageExtensions.m
//  GreatPhoto
//
//  Created by Ron Aldrich on 4/10/07.
//
// This source code is provided by Software Architects, Inc (Herein, SAI). on an
//  "AS IS" basis. SAI MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT
//  LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE, REGARDING THIS SOFTWARE OR ITS USE AND
//  OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
//
//  IN NO EVENT SHALL SAI BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION
//  AND/OR DISTRIBUTION OF THIS SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER
//  THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE,
//  EVEN IF SAI HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "CIImageExtensions.h"

#import <QuartzCore/QuartzCore.h>

/******************************************************************************/

@interface CIImage (CIImageExtensionsPrivate)

- (size_t) rowBytesForWidth: (size_t) inWidth
              bytesPerPixel: (size_t) inBytesPerPixel;

@end

/******************************************************************************/

@implementation CIImage (CIImageExtensionsPrivate)

/******************************************************************************/

- (size_t) rowBytesForWidth: (size_t) inWidth
              bytesPerPixel: (size_t) inBytesPerPixel
{
  size_t theResult = (inWidth * inBytesPerPixel + 15) & ~15;
  
  // Make sure we are not an even power of 2 wide. 
  // Will loop a few times for rowBytes <= 16.
  
  while ( 0 == (theResult & (theResult - 1) ) )
    theResult += 16;
  
  return theResult;
}

/******************************************************************************/

@end

/******************************************************************************/

@implementation CIImage (CIImageExtensions)

/******************************************************************************/

- (float*) getRGBAfBitmap: (CGColorSpaceRef) inColorSpace
                 fromRect: (CGRect) inFromRect
                 rowBytes: (size_t*) outRowBytes
{
  CGColorSpaceRef theColorSpace = nil;
  
  if ((inColorSpace == nil) || (inColorSpace == (CGColorSpaceRef) kCFNull))
  {
    theColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    
    NSParameterAssert(theColorSpace != nil);
    
    inColorSpace = theColorSpace;
  }
  
  NSParameterAssert(outRowBytes != nil);
  
  size_t theDestWidth = ceilf(inFromRect.size.width);
  size_t theDestHeight = ceilf(inFromRect.size.height);

  CGContextRef theCGContext = nil;
  CIContext* theCIContext = nil;
  
  size_t theBitsPerComponent = 32;
  size_t theBytesPerRow = [self rowBytesForWidth: theDestWidth
                                   bytesPerPixel: 16];
  size_t theDataSize = theBytesPerRow * theDestHeight;
    
  float* theBitmapData = malloc(theDataSize);
  
  float* theTempPtr = theBitmapData;
  unsigned theIndex;
  for (theIndex = 0; theIndex < theDataSize; theIndex += sizeof(float))
    *theTempPtr++ = 0.555;
  
  NSParameterAssert(theBitmapData != nil);
  
  CGBitmapInfo theBitmapInfo = kCGBitmapFloatComponents | kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Host;

  theCGContext = CGBitmapContextCreate(theBitmapData,
                                       theDestWidth,
                                       theDestHeight,
                                       theBitsPerComponent,
                                       theBytesPerRow,
                                       inColorSpace,
                                       theBitmapInfo);

  NSParameterAssert(theCGContext != nil);
  
  NSDictionary* theCICContextOptions = [NSDictionary dictionaryWithObjectsAndKeys: 
    (id) inColorSpace,     kCIContextOutputColorSpace, 
    (id) inColorSpace,     kCIContextWorkingColorSpace, 
    nil];
  
  theCIContext = [CIContext contextWithCGContext: theCGContext
                                          options: theCICContextOptions];
  
  NSParameterAssert(theCIContext != nil);
    
  CGContextClearRect(theCGContext,
                     CGRectMake(0, 0, theDestWidth, theDestHeight));
  
  [theCIContext drawImage: self
                  atPoint: CGPointZero
                 fromRect: inFromRect];
  
  CGContextFlush(theCGContext);
    
  *outRowBytes = CGBitmapContextGetBytesPerRow(theCGContext);
  
  CGContextRelease(theCGContext);
  CGColorSpaceRelease(theColorSpace);
    
  return theBitmapData;
}

/******************************************************************************/

@end
