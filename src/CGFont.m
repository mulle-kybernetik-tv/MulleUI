#import "import-private.h"

#import "CGFont.h"

#import "CGContext.h"

//
// CGFont needs the CGContextfor fontloading and will only be valid for
// that context
//
@implementation CGFont 

//
// name must be strduped or static string, will leak though
//
- (instancetype) initWithName:(char *) name
                        bytes:(void *) bytes
                       length:(NSUInteger) length
                      context:(CGContext *) context
{
   _name      = name;
	_fontIndex = nvgCreateFontMem( [context nvgContext], name, bytes, (int) length, 0);
	if( _fontIndex == -1) 
   {
      [self release];
      return( nil);
	}
   return( self);
}

+ (instancetype) fontWithName:(char *) name
                        bytes:(void *) bytes
                       length:(NSUInteger) length
                      context:(CGContext *) context
{
   return( [[[self alloc] initWithName:name
                                 bytes:bytes
                                length:length
                               context:context] autorelease]);
}                       
@end