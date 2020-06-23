#define _GNU_SOURCE

#include "CGColor.h"

#include <string.h>
#include <stdint.h>
#include <assert.h>
#include <math.h>


// all colors will have alpha set to 0xFF
// unknown is all zero


struct mulle_cstringuint32pair
{
   char       *name;
   uint32_t   value;
};


static struct mulle_cstringuint32pair
   *mulle_cstringuint32pair_bsearch( struct mulle_cstringuint32pair *buf,
                                     unsigned int n,
                                     char *search)
{
   int                              first;
   int                              diff;
   int                              last;
   int                              middle;
   struct mulle_cstringuint32pair   *p;

   assert( search);

   first  = 0;
   last   = n - 1;
   middle = (first + last) / 2;

   while( first <= last)
   {
      p    = &buf[ middle];
      diff = strcmp( p->name, search);
      if( diff <= 0)
      {
         if( ! diff)
            return( p);

         first = middle + 1;
      }
      else
         last = middle - 1;

      middle = (first + last) / 2;
   }

   return( NULL);
}


static struct mulle_cstringuint32pair   color_table[] =
{
   { "aliceblue",            0xf0f8ffff },
   { "antiquewhite",         0xfaebd7ff },
   { "aqua",                 0x00ffffff },
   { "aquamarine",           0x7fffd4ff },
   { "azure",                0xf0ffffff },
   { "beige",                0xf5f5dcff },
   { "bisque",               0xffe4c4ff },
   { "black",                0x000000ff },
   { "blanchedalmond",       0xffebcdff },
   { "blue",                 0x0000ffff },
   { "blueviolet",           0x8a2be2ff },
   { "brown",                0xa52a2aff },
   { "burlywood",            0xdeb887ff },
   { "cadetblue",            0x5f9ea0ff },
   { "chartreuse",           0x7fff00ff },
   { "chocolate",            0xd2691eff },
   { "coral",                0xff7f50ff },
   { "cornflowerblue",       0x6495edff },
   { "cornsilk",             0xfff8dcff },
   { "crimson",              0xdc143cff },
   { "cyan",                 0x00ffffff },
   { "darkblue",             0x00008bff },
   { "darkcyan",             0x008b8bff },
   { "darkgoldenrod",        0xb8860bff },
   { "darkgray",             0xa9a9a9ff },
   { "darkgreen",            0x006400ff },
   { "darkkhaki",            0xbdb76bff },
   { "darkmagenta",          0x8b008bff },
   { "darkolivegreen",       0x556b2fff },
   { "darkorange",           0xff8c00ff },
   { "darkorchid",           0x9932ccff },
   { "darkred",              0x8b0000ff },
   { "darksalmon",           0xe9967aff },
   { "darkseagreen",         0x8fbc8fff },
   { "darkslateblue",        0x483d8bff },
   { "darkslategray",        0x2f4f4fff },
   { "darkturquoise",        0x00ced1ff },
   { "darkviolet",           0x9400d3ff },
   { "deeppink",             0xff1493ff },
   { "deepskyblue",          0x00bfffff },
   { "dimgray",              0x696969ff },
   { "dodgerblue",           0x1e90ffff },
   { "firebrick",            0xb22222ff },
   { "floralwhite",          0xfffaf0ff },
   { "forestgreen",          0x228b22ff },
   { "fuchsia",              0xff00ffff },
   { "gainsboro",            0xdcdcdcff },
   { "ghostwhite",           0xf8f8ffff },
   { "gold",                 0xffd700ff },
   { "goldenrod",            0xdaa520ff },
   { "gray",                 0x808080ff },
   { "green",                0x008000ff },
   { "greenyellow",          0xadff2fff },
   { "honeydew",             0xf0fff0ff },
   { "hotpink",              0xff69b4ff },
   { "indianred ",           0xcd5c5cff },
   { "indigo",               0x4b0082ff },
   { "ivory",                0xfffff0ff },
   { "khaki",                0xf0e68cff },
   { "lavender",             0xe6e6faff },
   { "lavenderblush",        0xfff0f5ff },
   { "lawngreen",            0x7cfc00ff },
   { "lemonchiffon",         0xfffacdff },
   { "lightblue",            0xadd8e6ff },
   { "lightcoral",           0xf08080ff },
   { "lightcyan",            0xe0ffffff },
   { "lightgoldenrodyellow", 0xfafad2ff },
   { "lightgrey",            0xd3d3d3ff },
   { "lightgreen",           0x90ee90ff },
   { "lightpink",            0xffb6c1ff },
   { "lightsalmon",          0xffa07aff },
   { "lightseagreen",        0x20b2aaff },
   { "lightskyblue",         0x87cefaff },
   { "lightslategray",       0x778899ff },
   { "lightsteelblue",       0xb0c4deff },
   { "lightyellow",          0xffffe0ff },
   { "lime",                 0x00ff00ff },
   { "limegreen",            0x32cd32ff },
   { "linen",                0xfaf0e6ff },
   { "magenta",              0xff00ffff },
   { "maroon",               0x800000ff },
   { "mediumaquamarine",     0x66cdaaff },
   { "mediumblue",           0x0000cdff },
   { "mediumorchid",         0xba55d3ff },
   { "mediumpurple",         0x9370d8ff },
   { "mediumseagreen",       0x3cb371ff },
   { "mediumslateblue",      0x7b68eeff },
   { "mediumspringgreen",    0x00fa9aff },
   { "mediumturquoise",      0x48d1ccff },
   { "mediumvioletred",      0xc71585ff },
   { "midnightblue",         0x191970ff },
   { "mintcream",            0xf5fffaff },
   { "mistyrose",            0xffe4e1ff },
   { "moccasin",             0xffe4b5ff },
   { "navajowhite",          0xffdeadff },
   { "navy",                 0x000080ff },
   { "oldlace",              0xfdf5e6ff },
   { "olive",                0x808000ff },
   { "olivedrab",            0x6b8e23ff },
   { "orange",               0xffa500ff },
   { "orangered",            0xff4500ff },
   { "orchid",               0xda70d6ff },
   { "palegoldenrod",        0xeee8aaff },
   { "palegreen",            0x98fb98ff },
   { "paleturquoise",        0xafeeeeff },
   { "palevioletred",        0xd87093ff },
   { "papayawhip",           0xffefd5ff },
   { "peachpuff",            0xffdab9ff },
   { "peru",                 0xcd853fff },
   { "pink",                 0xffc0cbff },
   { "plum",                 0xdda0ddff },
   { "powderblue",           0xb0e0e6ff },
   { "purple",               0x800080ff },
   { "rebeccapurple",        0x663399ff },
   { "red",                  0xff0000ff },
   { "rosybrown",            0xbc8f8fff },
   { "royalblue",            0x4169e1ff },
   { "saddlebrown",          0x8b4513ff },
   { "salmon",               0xfa8072ff },
   { "sandybrown",           0xf4a460ff },
   { "seagreen",             0x2e8b57ff },
   { "seashell",             0xfff5eeff },
   { "sienna",               0xa0522dff },
   { "silver",               0xc0c0c0ff },
   { "skyblue",              0x87ceebff },
   { "slateblue",            0x6a5acdff },
   { "slategray",            0x708090ff },
   { "snow",                 0xfffafaff },
   { "springgreen",          0x00ff7fff },
   { "steelblue",            0x4682b4ff },
   { "tan",                  0xd2b48cff },
   { "teal",                 0x008080ff },
   { "thistle",              0xd8bfd8ff },
   { "tomato",               0xff6347ff },
   { "turquoise",            0x40e0d0ff },
   { "violet",               0xee82eeff },
   { "wheat",                0xf5deb3ff },
   { "white",                0xffffffff },
   { "whitesmoke",           0xf5f5f5ff },
   { "yellow",               0xffff00ff },
   { "yellowgreen",          0x9acd32FF }
};


uint32_t  mulle_colorname_to_uint32( char *name)
{
   struct mulle_cstringuint32pair   *pair;

   if( ! name)
      return( 0x00000000);

   pair = mulle_cstringuint32pair_bsearch( color_table,
                                           sizeof( color_table) / sizeof( color_table[ 0]),
                                           name);
   if( ! pair)
      return( 0x00000000);
   return( pair->value);
}


static inline   int  dehex( char c)
{
   if( c >= 'A' && c <= 'Z')
      return( c - 'A' + 10);
   if( c >= 'a' && c <= 'z')
      return( c - 'a' + 10);
   if( c >= '0' && c <= '9')
      return( c - '0');
   return( 0);
}


//
// returns non-normalized floats
// rgb are 0-255, alpha is normalized 0-1 (NOT MY IDEA!!)
// https://developer.mozilla.org/en-US/docs/Web/CSS/color_value
// in rgba pass the "max" values (i.e. 255,255,255,1 for RGBA
// and 360,100,100,1 for HSLA)
static inline int  decode_hsla_array( char *s, float hsla[ 4], unsigned int n)
{
   char     *end;
   int      state;
   double   value;
   float    max[ 4];
   int      i;
   int      c;

   assert( n >= 3 && n <= 4);
   i        = 0;

   max[ 0] = 360.0;
   max[ 1] = 100.0;
   max[ 2] = 100.0;
   max[ 3] = 1.0;

   hsla[ 0] = 0.0;
   hsla[ 1] = 0.0;
   hsla[ 2] = 0.0;
   hsla[ 3] = 1.0;

   assert( *s == '(' );
   while( c = *++s)
   {
      if( (c >= '0' && c <= '9') || c == '.')
      {
         hsla[ i] = strtod( s, &end);
         switch( *end)
         {
         case '%' :
            hsla[ i] = hsla[ i] / 100.0 * max[ i];
            end      = end + 1;
            break;
      
         case 't' : 
            if( i || strncmp( end, "turn", 4))
               return( -1);
            // only for h
            hsla[ i] = fmod( hsla[ i], 1) * max[ i];  // turn must be 0-1 for now
            end      = end + 4;
            break;

         case 'd' :
            if( i || strncmp( end, "deg", 3))  // default
               return( -1);
            // only for h
            end = end + 3;
            break;

         case 'g' :
            if( i || strncmp( end, "grad", 4))
               return( -1);
            // only for h
            hsla[ i]  = hsla[ i] / 400.0 * max[ i];
            end       = end + 4;
            break;

         case 'r' :
            if( i || strncmp( end, "rad", 3))
               return( -1);
            // only for h
            hsla[ i] = hsla[ i] / (2 * M_PI) * max[ i];
            end      = end + 3;
            break;
         }

         if( i == 0)
         {
            hsla[ i] = fmod( hsla[ i], max[ i]);
            if( hsla[ i] < 0.0)
               hsla[ i] = max[ i] - hsla[ i];
         }
         else
         {
            if( hsla[ i] < 0.0)
               hsla[ i] = 0.0;
            if( hsla[ i] > max[ i]) 
               hsla[ i] = max[ i];
         }

         if( ++i == n)
            return( 0);

         s = end - 1;
         continue;   
      }

      if( c == ' ')
         continue;
      if( c == ',')
         continue;
      if( c == ')')
         return( 0);
      if( c == '/')
         continue;
      return( -1);
   }
   return( -1);
}


//
// returns non-normalized floats
// rgb are 0-255, alpha is normalized 0-1 (NOT MY IDEA!!)
// https://developer.mozilla.org/en-US/docs/Web/CSS/color_value
// in hsla pass the "max" values (i.e. 255,255,255,1 for RGBA
// and 360,100,100,1 for HSLA)
static inline int  decode_rgba_array( char *s, float rgba[ 4], unsigned int n)
{
   char     *end;
   int      state;
   double   value;
   float    max[ 4];
   int      i;
   int      c;

   assert( n >= 3 && n <= 4);
   i        = 0;

   max[ 0] = 255.0;
   max[ 1] = 255.0;
   max[ 2] = 255.0;
   max[ 3] = 1.0;

   rgba[ 0] = 0.0;
   rgba[ 1] = 0.0;
   rgba[ 2] = 0.0;
   rgba[ 3] = 1.0;

   assert( *s == '(' );
   while( c = *++s)
   {
      if( (c >= '0' && c <= '9') || c == '.')
      {
         rgba[ i] = strtod( s, &end);
         switch( *end)
         {
         case '%' :
            rgba[ i] = rgba[ i] / 100.0 * max[ i];
            break;
         }

         if( rgba[ i] < 0.0)
            rgba[ i] = 0.0;
         if( rgba[ i] > max[ i]) 
            rgba[ i] = max[ i];

         if( ++i == n)
            return( 0);

         s = end - 1;
         continue;   
      }

      if( c == ' ')
         continue;
      if( c == ',')
         continue;
      if( c == ')')
         return( 0);
      if( c == '/')
         continue;
      return( -1);
   }
   return( -1);
}


#if USE_OWN_HSLA_CODE
// stolen from @mjackson: https://gist.github.com/mjackson/5311256

static float  hue2rgb( float p, float q, float t) 
{
   if (t < 0.0) t += 1;
   if (t > 1.0) t -= 1;
   if (t < 1.0/6.0) return p + (q - p) * 6.0 * t;
   if (t < 1.0/2.0) return q;
   if (t < 2.0/3.0) return p + (q - p) * (2.0/3.0 - t) * 6;
   return p;
}

/**
 * Converts an HSL color value to RGB. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSL_color_space.
 * Assumes h, s, and l are contained in the set [0, 1] and
 * returns r, g, and b in the set [0, 1]. 
 */
static void mulle_normalized_hsl_to_normalized_rgb(float hsl[3], float rgb[3])
{
   double   q;
   double   p;

   if( hsl[ 1] == 0) 
   {
      rgb[ 0] = 
      rgb[ 1] = 
      rgb[ 2] = hsl[ 2]; // achromatic
      return;
   }
   q =  hsl[ 2] < 0.5 
            ?  hsl[ 2] * (1 + hsl[ 1]) 
            :  hsl[ 2] + hsl[ 1] - hsl[ 2] * hsl[ 1];
   p = 2 * hsl[ 2] - q;

   rgb[ 0] = hue2rgb( p, q, hsl[ 0] + 1.0/3.0);
   rgb[ 1] = hue2rgb( p, q, hsl[ 0]);
   rgb[ 2] = hue2rgb( p, q, hsl[ 0] - 1.0/3.0);
}
#endif


CGColorRef   MulleColorCreateFromCString( char *string)
{
   size_t          len;
   unsigned int    rgba[ 4];
   float           rgbaf[ 4];
   float           hslaf[ 4];
   unsigned char   *s;
   uint32_t        color;
   int             i;

   if( ! string)
      return( getNVGColor( 0));

   len = strlen( string);

   if( *string == '#')
   {
      rgba[ 3] = 255;

      s = (unsigned char *) &string[ 1];
      --len;

      switch( len)
      {
      case 4:
         rgba[ 3] = dehex( s[ 3]) << 4;
         // fallthru
      case 3:
         rgba[ 0] = dehex( s[ 0]) << 4;
         rgba[ 1] = dehex( s[ 1]) << 4;
         rgba[ 2] = dehex( s[ 2]) << 4;
         break;

      case 8  :
         rgba[ 3] = (dehex( s[ 6]) << 4) + dehex( s[ 7]);
         // fallthru
      case 6  :
         rgba[ 0] = (dehex( s[ 0]) << 4) + dehex( s[ 0]);
         rgba[ 1] = (dehex( s[ 2]) << 4) + dehex( s[ 2]);
         rgba[ 2] = (dehex( s[ 4]) << 4) + dehex( s[ 4]);
         break;   

      default :
         return( getNVGColor( 0));
      }
      return( nvgRGBA( rgba[ 0], rgba[ 1], rgba[ 2], rgba[ 3]));
   }

   // look for rgb/rgba
   if( *string == 'r')
   {
      if( ! strncmp( string, "rgb", 3))
      {
         i = 3;
         if( string[ i] == 'a')
            ++i;
         if( string[ i] == '(')
         {
            if( decode_rgba_array( &string[ i], rgbaf, i))
               return( getNVGColor( 0));

            return( nvgRGBAf( rgbaf[ 0] / 255.0, 
                              rgbaf[ 1] / 255.0, 
                              rgbaf[ 2] / 255.0, 
                              rgbaf[ 3]));
         }
      }
   }

   if( *string == 'h')
   {
      if( ! strncmp( string, "hsl", 3))
      {
         i = 3;
         if( string[ i] == 'a')
            ++i;
         if( string[ i] == '(')
         {
            if( decode_hsla_array( &string[ i], hslaf, i))
               return( getNVGColor( 0));

            hslaf[ 0] /= 360.0;
            hslaf[ 1] /= 100.0;
            hslaf[ 2] /= 100.0;
            return (nvgHSLA(hslaf[0],
                            hslaf[1],
                            hslaf[2],
                            hslaf[3]));
         }
      }
   }
   color = mulle_colorname_to_uint32( string);
   return( getNVGColor( color));
}



