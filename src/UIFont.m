#import "UIFont.h"

#import "CGFont.h"


@implementation UIFont


+ (instancetype) fontWithNameCString:(char *) name 
                                size:(CGFloat) pointSize
{
   UIFont   *font;

   font = [[[self alloc] init] autorelease];
   [font setFontName:name];
   [font setPointSize:pointSize];
   return( font);
}


+ (instancetype) boldSystemFontOfSize:(CGFloat) pointSize
{
   return( [self fontWithNameCString:"sans"
                                size:pointSize]);
}


- (void) dealloc 
{
   struct mulle_allocator  *allocator;

   allocator = MulleObjCObjectGetAllocator( self);
   mulle_allocator_free( allocator, _fontName);
   [super dealloc];
}


- (void) setFontName:(char *) s
{
   MulleObjCObjectSetDuplicatedCString( self, &_fontName, s);
}

@end
