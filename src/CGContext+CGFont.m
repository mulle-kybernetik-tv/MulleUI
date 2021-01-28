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

#include <assert.h>


#define fallback_font_ttf   NotoEmoji_Regular_ttf


@implementation CGContext ( CGFont)

static struct mulle_container_keyvaluecallback   c_string_to_object_callback;

+ (void) load
{
   c_string_to_object_callback = (struct mulle_container_keyvaluecallback)
   {
      .keycallback   = mulle_container_keycallback_copied_cstring,
      .valuecallback = *MulleObjCContainerValueRetainCallback
   };
}


- (CGFloat) fontScale
{
   return( _currentFrameInfo.UIScale.dx * 1.35); // Still true ????
}


- (void) _initFontCache
{
   _mulle_map_init( &_fontMap,
                    8,
                    &c_string_to_object_callback,
                    MulleObjCInstanceGetAllocator( self));
}

- (void) _doneFontCache
{
   _mulle_map_done( &_fontMap);
}


- (void) _resetFontCache
{
   mulle_map_reset( &_fontMap);
}

- (void) addFontWithCData:(struct mulle_data) data 
          fontNameCString:(char *) name
{
   CGFont   *font;
   int      fontIndex;

   assert( ! mulle_map_get( &_fontMap, name));

   fontIndex = nvgCreateFontMem( _vg, name, data.bytes, (int) data.length, 0);
   font      = [CGFont fontWithNameCString:name
                                 fontIndex:fontIndex];

   mulle_map_insert( &_fontMap, name, font);
}


- (void) addFontWithContentsOfFileWithFileRepresentationString:(char *) filename
                                               fontNameCString:(char *) name
{
   CGFont   *font;
   int      fontIndex;

   assert( ! mulle_map_get( &_fontMap, name));

   fontIndex = nvgCreateFont( _vg, name, filename);
   font      = [CGFont fontWithNameCString:name
                                 fontIndex:fontIndex];

   mulle_map_insert( &_fontMap, name, font);
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
   font      = [CGFont fontWithNameCString:"fallback"
                          fontIndex:fontIndex];

   mulle_map_insert( &_fontMap, "fallback", font);
   return( font);
}


- (CGFont *) fontWithNameCString:(char *) s
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

   font = [CGFont fontWithNameCString:s
                     fontIndex:fontIndex];
   assert( font);
   mulle_map_insert( &_fontMap, s, font);

   return( font);
}

@end
