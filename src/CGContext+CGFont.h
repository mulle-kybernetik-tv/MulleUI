//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
// prefer a local CGContext over one in import.h
#ifdef __has_include
# if __has_include( "CGContext.h")
#  import "CGContext.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"


@interface CGContext( CGFont)

- (CGFont *) fallbackFont;
- (CGFont *) fontWithNameCString:(char *) s;
- (CGFloat) fontScale;

- (void) _initFontCache;
- (void) _doneFontCache;
- (void) _resetFontCache;

/*
 * Fill fontCache with fonts, don't use during draws as it does I/O
 */
- (void) addFontWithContentsOfFileWithFileRepresentationString:(char *) filename
                                               fontNameCString:(char *) name;
- (void) addFontWithCData:(struct mulle_data) data 
          fontNameCString:(char *) name;
@end



