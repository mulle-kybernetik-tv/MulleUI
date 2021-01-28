#import "import-private.h"

#import "CGFont.h"

#import "CGContext.h"

//
// CGFont needs the CGContext for fontloading and will only be valid for
// that context
//
@implementation CGFont

- (instancetype) initWithNameCString:(char *) name
                           fontIndex:(int) fontIndex
{
	if( _fontIndex == -1)
   {
      [self release];
      return( nil);
	}

   [self setNameCString:name];
	_fontIndex = fontIndex;
   return( self);
}


+ (instancetype) fontWithNameCString:(char *) name
                           fontIndex:(int) fontIndex
{
   return( [[[self alloc] initWithNameCString:name
                                   fontIndex:fontIndex] autorelease]);
}


- (void) setNameCString:(char *) s
{
   MulleObjCObjectSetDuplicatedCString( self, &_nameCString, s);
}


- (void) dealloc
{
   MulleObjCObjectDeallocateMemory( self, _nameCString);
   [super dealloc];
}

@end