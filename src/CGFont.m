#import "import-private.h"

#import "CGFont.h"

#import "CGContext.h"

//
// CGFont needs the CGContext for fontloading and will only be valid for
// that context
//
@implementation CGFont 

- (instancetype) initWithName:(char *) name
                    fontIndex:(int) fontIndex
{
	if( _fontIndex == -1) 
   {
      [self release];
      return( nil);
	}

   [self setName:name];
	_fontIndex = fontIndex;
   return( self);
}


+ (instancetype) fontWithName:(char *) name
                    fontIndex:(int) fontIndex
{
   return( [[[self alloc] initWithName:name
                             fontIndex:fontIndex] autorelease]);
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