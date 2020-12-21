//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "CGContext+CGFont.h"

#import "import-private.h"

#import "CGFont.h"

// #define USE_ANONYMOUS_PRO


#ifdef USE_ANONYMOUS_PRO
# include "anonymous-pro.inc"
# define FONT_DATA   Anonymous_Pro_ttf
#else
# include "Roboto-Regular.inc"
# define FONT_DATA   Roboto_Regular_ttf
#endif
#include "entypo.inc"
#include "emoji.inc"


#define fallback_font_ttf   NotoEmoji_Regular_ttf


@implementation CGContext ( CGFont)

- (CGFloat) fontScale
{
   return( _currentFrameInfo.UIScale.dx * 1.35); // Still true ????
}


- (void) resetFontCache
{
   mulle_map_reset( &_fontMap);
}


//
// TODO: use hash table to keep track of names and avoid duplicate loads of
//       fonts
//
- (CGFont *) fallbackFont
{
   CGFont   *font;
   int      fontIndex;

   font = mulle_map_get( &_fontMap, "fallback");
   if( font)
      return( font);
   
   fontIndex = nvgCreateFontMem( [self nvgContext], 
                                 "fallback", 
                                 fallback_font_ttf, 
                                 (int) sizeof( fallback_font_ttf), 
                                 0);   
   font      = [CGFont fontWithName:"fallback"
                          fontIndex:fontIndex];  

   mulle_map_insert( &_fontMap, "fallback", font);
   return( font);
}


- (CGFont *) fontWithName:(char *) s
{
   CGFont   *font;
   CGFont   *fallbackFont;
   int       fontIndex;

   font = mulle_map_get( &_fontMap, s);
   if( font)
      return( font);

   fontIndex = -1;
   if( ! strcmp( s, "sans"))
   {
      fontIndex = nvgCreateFontMem( _vg, 
                                    s, 
                                    FONT_DATA, 
                                    (int) sizeof( FONT_DATA), 
                                    0);
   }
   else
      if( ! strcmp( s, "icons"))
      {
         fontIndex = nvgCreateFontMem( _vg, 
                                       s, 
                                       entypo_ttf, 
                                       (int) sizeof( entypo_ttf), 
                                       0);         
      }

   if( fontIndex == -1)
      abort();

   fallbackFont = [self fallbackFont];
   if( fallbackFont)
      nvgAddFallbackFontId( _vg, fontIndex, [fallbackFont fontIndex]);

   font = [CGFont fontWithName:s
                     fontIndex:fontIndex];
   assert( font);
   mulle_map_insert( &_fontMap, s, font);
 
   return( font);
}


@end
