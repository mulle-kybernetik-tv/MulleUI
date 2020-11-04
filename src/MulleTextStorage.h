//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#ifdef __has_include
# if __has_include( "NSObject.h")
#  import "NSObject.h"
# endif
#endif

#import "import.h"

//
// The storage for text and images of a UITextView.
// The persistance format is markdown with embedded images
//
// The format is very simplistic. Each line can be a
// NSData for text or a NSNumber as an index into the UIImages
// for an image. There are no font attributes.
//
@interface MulleTextStorage : NSObject < NSMutableArray>
{
   NSMutableArray   *_lines;
   NSMutableArray   *_images;
}

// our tiny markdown 
- (void) setTextData:(NSData *) data;
- (NSData *) textData;

@property( relationship, retain) NSArray  *images;

@end
