//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
// prefer a local MulleBitmapImage over one in import.h
#ifdef __has_include
# if __has_include( "MulleBitmapImage.h")
#  import "MulleBitmapImage.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"

//
// Used for UITextView and MulleTextStorage. At this point we are 
// moving to NSData and NSString use. Chances are good, that the whole text
// system moves into its own library, with different dependencies
// PNG writing is right on the border of both libraries though...
//
@interface MulleBitmapImage( PNG)

- (id) initWithPNGData:(NSData *) data;
- (NSData *) PNGData;
- (BOOL) writeToPNGFileWithSystemRepresentation:(char *) filename;

@end



// TODO: move to a UIImage+PNG header ?
static inline NSData   *UIImagePNGRepresentation( UIImage *image)
{
   if( [image respondsToSelector:@selector( PNGData)])
      return( [(id) image PNGData]);
   return( nil);
}
