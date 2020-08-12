#import "import.h"

#import "CGBase.h"

@class CGFont;


// A UIFont is a fontName + fontSize (and maybe other attributes)
// the actual font will be available during rendering only as a CGFont
// that's maintained by the CGContext
//
// Mixing emoji with roboto ? It's apparently tricky:
// https://forum.xda-developers.com/android/help/combine-2-fonts-roboto-emoji-t3501020
//

@interface UIFont : NSObject 

@property( assign) char *   fontName;
@property( assign) CGFloat  pointSize;

+ (instancetype) fontWithNameCString:(char *) name 
                                size:(CGFloat) pointSize;

+ (instancetype) boldSystemFontOfSize:(CGFloat) pointSize;

@end

