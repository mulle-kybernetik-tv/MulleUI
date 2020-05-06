#import "import-private.h"

#import "CGFont.h"

#import "CGContext.h"

//
// CGFont needs the CGContext for fontloading and will only be valid for
// that context
//
@implementation CGFont 

- (instancetype) initWithName:(char *) name
                        bytes:(void *) bytes
                       length:(NSUInteger) length
                      context:(CGContext *) context
{
   [self setName:name];
  
	_fontIndex = nvgCreateFontMem( [context nvgContext], _name, bytes, (int) length, 0);
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


- (void) setName:(char *) s
{
   MulleObjCObjectSetDuplicatedCString( self, &_name, s);
}


- (void) dealloc 
{
   MulleObjCObjectDeallocateMemory( self, _name);
   [super dealloc];
}

@end