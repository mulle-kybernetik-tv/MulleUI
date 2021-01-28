//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "MulleTextStorage.h"

#import "import-private.h"

#import "UIImage.h"
#import "UIImage+NSData.h"
#import "MulleSVGImage.h"
#import "MulleBitmapImage.h"
#import "MulleBitmapImage+PNG.h"



// if line starts with '[' convert to &lbrack;
// if line starts with '!' convert to &excl;
// if line starts with '&' convert to &amp;
static NSData   *dataByEscapingFirstCharacterOfData( NSData *obj)
{
   NSMutableData       *data;
   size_t              length;
   struct mulle_data   text;
   char                *escapeCode;

   text = [obj cData];

   switch( *(char *) text.bytes)
   {
   case '[' :
      escapeCode = "&lbrack;";
      length     = strlen( "&lbrack;");
      break;

   case '!' :
      escapeCode = "&excl;";
      length     = strlen( "&excl;");
      break;
#ifdef ESCAPE_AMP
   case '&' :
      escapeCode = "&amp;";
      length     = strlen( "&amp;");
      break;
#endif
   default :
      return( obj);
   }

   data = [NSMutableData dataWithBytes:escapeCode
                                length:length];
   [data appendBytes:(char *) text.bytes + 1
              length:text.length - 1];
   return( data);
}


static NSData   *dataByUnescapingFirstCharacterOfData( NSData *obj)
{
   NSMutableData      *data;
   size_t              length;
   struct mulle_data   text;
   char                c;

   text = [obj cData];

   if( *(char *) text.bytes != '&')
      return( obj);

   c = 0;
   if( text.length >= 8 && ! strncmp( text.bytes, "&lbrack;", 8))
   {
      c      = '[';
      length = 8;
   }
   if( text.length >= 6 && ! strncmp( text.bytes, "&excl;", 6))
   {
      c      = '!';
      length = 6;
   }

#ifdef ESCAPE_AMP
   if( text.length >= 5 && ! strncmp( text.bytes, "&amp;", 5))
   {
      c      = '&';
      length = 5;
   }
#endif
   if( ! c)
      return( obj);


   data = [NSMutableData dataWithBytes:&c
                                length:1];
   [data appendBytes:(char *) text.bytes + length
              length:text.length - length];
   return( data);
}



@implementation MulleTextStorage

- (instancetype) init
{
   _lines  = [NSMutableArray new];
   _images = [NSMutableArray new];
   return( self);
}


- (void) dealloc
{
   [_lines release];
   [_images release];
   [super dealloc];  // call at end
}


 static char   lf[ 2] = { '\n' };
 static int    lf_len = 1;


//
// convert minimal markdown text to internal representation
//
- (void) setTextData:(NSData *) data
{
   NSArray            *datas;
   NSData             *sepData;
   NSData             *obj;
   NSData             *imageData;
   NSData             *base64Data;
   struct mulle_data  text;
   BOOL               ignoreText;
   long               i;
   char               *endptr;
   char               *s;
   NSNumber           *nr;
   UIImage            *image;

   [_lines removeAllObjects];
   [_images removeAllObjects];

   sepData = [NSData dataWithBytes:lf
                            length:lf_len];

   // TODOs:
   ignoreText = NO;
   datas      = [data mulleComponentsSeparatedByData:sepData];
   for( obj in datas)
   {
      // look for ![][image_     as image marker
      // look for [image_        as image data marker
      // look for & as eca
      text = [obj cData];
      if( text.length >= 1)
      {
         switch( *(char *) text.bytes)
         {
         case '&' :
            obj = dataByUnescapingFirstCharacterOfData( obj);
            break;

         case '!' :
            if( text.length < 10)
               abort();

            if( strncmp( text.bytes, "![][image_", 10))
               abort();

            s  = text.bytes;
            s += 10;
            i  = strtol( s, &endptr, 0);
            if( ! (endptr && endptr > s && *endptr == ']'))
               abort();

            nr = [NSNumber numberWithLong:i];
            [_lines addObject:nr];
            continue;

         case '[' :
            if( text.length < 7)
               abort();

            if( strncmp( text.bytes, "[image_", 7))
               abort();

            ignoreText = YES;   // ignore everything below
            // parse [image_%ld]
            s  = text.bytes;
            s += 7;
            i  = strtol( s, &endptr, 0);
            if( ! (endptr && endptr > s && *endptr == ']'))
               abort();

            s = endptr + 1;
            if( ! strncmp( s, ": data:image/png;base64,", 24))
            {
               s += 24;
               base64Data = [NSData dataWithBytes:s
                                           length:text.length - (s - (char *) text.bytes)];
               imageData  = [base64Data base64DecodedData];
               image      = [MulleBitmapImage imageWithFileData:imageData];
               [_images addObject:image];
               continue;
            }

            if( ! strncmp( s, ": data:image/svg+xml;base64,", 28))
            {
               s += 28;
               base64Data = [NSData dataWithBytes:s
                                           length:text.length - (s - (char *) text.bytes)];
               imageData  = [base64Data base64DecodedData];
               image      = [MulleSVGImage imageWithFileData:imageData];
               [_images addObject:image];
               continue;
            }
            abort();
         }
      }
      if( ! ignoreText)
         [_lines addObject:obj];
   }
}


//
// Convert internal representation to a minimal markdown text
// Main problem with minimal markdown text is, that the user can type
// [ or ! at the beginning of the line
//
- (NSData *) textData
{
   NSData              *data;
   NSData              *base64Data;
   Class               imageClass;
   Class               numberClass;
   UIImage             *image;
   NSUInteger          imageNr;
   NSMutableArray      *images;
   NSMutableData       *textData;
   struct mulle_data   svg_data;
   struct mulle_data   png_data;
   id                  obj;
   char                lf[ 2];
   char                *tmp;

   lf[ 0] = '\n';
   lf_len = 1;

   textData    = [NSMutableData data];
   numberClass = [NSNumber class];
   imageNr     = 0;

   for( obj in _lines)
   {
      if( [obj isKindOfClass:numberClass])
      {
         imageNr = [obj integerValue];
         if( imageNr >= [_images count])
         {
            // image not there anymore (panic when debugging)
            abort();
         }

         // ![][image_%ld]
         tmp = MulleObjC_asprintf( "![][image_%ld]", (long) imageNr);
         [textData appendBytes:tmp
                        length:strlen( tmp)];
      }
      else
      {
         NSParameterAssert( [obj isKindOfClass:[NSData class]]);

         obj = dataByEscapingFirstCharacterOfData( obj);
         [textData appendData:obj];
      }
      [textData appendBytes:lf
                     length:lf_len];
   }

   imageNr = 0;
   for( image in _images)
   {
      // dump image data into a line (always as PNG)
      // [image_%ld]: data:image/png;base64 <base64> <nl>

      if( [image isKindOfClass:[MulleBitmapImage class]])
      {
         // TODO: save jpg in original format as well
         tmp = MulleObjC_asprintf( "[image_%ld]: data:image/png;base64,", (long) imageNr);
         // <base64>
         if( [image fileEncoding] == UIImageDataEncodingPNG)
         {
            png_data = [image cData];
            data     = [[[NSData alloc] mulleInitWithBytesNoCopy:png_data.bytes
                                                          length:png_data.length
                                                   sharingObject:image] autorelease];
         }
         else
            data = UIImagePNGRepresentation( image);
      }
      else
      {
         assert( [image isKindOfClass:[MulleSVGImage class]]);

         tmp = MulleObjC_asprintf( "[image_%ld]: data:image/svg+xml;base64,", (long) imageNr);
         // <base64>
         svg_data = [(MulleSVGImage *) image cData];
         data     = [NSData dataWithCData:svg_data];
      }

      base64Data = [data base64EncodedDataWithMaxLineWidth:0];
      [textData appendBytes:tmp
                     length:strlen( tmp)];
      [textData appendData:base64Data];
      // <nl>
      [textData appendBytes:lf
                     length:lf_len];
      imageNr++;
   }

   return( textData);
}


- (void) insertObject:(id) obj
              atIndex:(NSUInteger) index
{
   NSParameterAssert( [obj isKindOfClass:[NSNumber class]] ||
                      [obj isKindOfClass:[NSData class]]);
   [_lines insertObject:obj
                atIndex:index];
}


- (void) replaceObjectAtIndex:(id) obj
                      atIndex:(NSUInteger) index
{
   NSParameterAssert( [obj isKindOfClass:[NSNumber class]] ||
                      [obj isKindOfClass:[NSData class]]);
   [_lines replaceObjectAtIndex:index
                     withObject:obj];
}


- (UIImage *) imageForNumber:(NSNumber *) nr
{
   return( [_images objectAtIndex:[nr unsignedIntegerValue]]);
}

- (void *) forward:(void *) param
{
   assert( _lines); // window should not forward...
   return( mulle_objc_object_call_variablemethodid_inline( _lines,
                                                          (mulle_objc_methodid_t) _cmd,
                                                          param));
}



@end
