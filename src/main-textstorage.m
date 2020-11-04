#import "import-private.h"

#import "MulleTextStorage.h"



static char   *demo_md =
"Markdown with an embedded image\n"
"\n"
"![][image_0]\n"
"\n"
"---\n"
"\n"
"![][image_1]\n"
"\n"
"---\n"
"\n"
"[image_0]: data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH5AYREAsA2TZM"
"1QAAABl0RVh0Q29tbWVudABDcmVhdGVkIHdpdGggR0lNUFeBDhcAAACSSURBVEjHY2zibWEgEXSXr4QwSjvDCSpmItt0IgHJFsABMc6nyAKa+2DUglELRi0YQRYwEl9ck1qOQgAL7YwmN"
"ogoMZ2wD9BMJ7IOINYCZNPJMJpAEFHFdJwWUMt07BZQ0XQscUBSk4Q0C6jrcPQgopHpUAtoZzoDAwMjb4su7UxHxAEtjEYEEe1MJ624HqQVDgDwUi5ARdKSLwAAAABJRU5ErkJggg==\n"
"[image_1]: data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjxzdmcgeG1sbnM9Imh0"
"dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB3aWR0aD0iNTAwIiBoZWlnaHQ9IjUwMCI+CjxjaXJjbGUgY3g9IjI1MCIgY3k9IjI1MCIgcj0iMjEwIiBmaWxsPSIjZmZmIiBzdHJva2U9I"
"iMwMDAiIHN0cm9rZS13aWR0aD0iOCIvPgo8L3N2Zz4K\n";



int   main()
{
   MulleTextStorage   *storage;
   NSData             *data;
   NSData             *data2;

   storage = [MulleTextStorage object];
   data    = [NSData dataWithBytes:demo_md
                            length:strlen( demo_md) - 1];
   [storage setTextData:data];

   data2 = [storage textData];
   if( ! [data isEqualToData:data2])
   {
      fprintf( stderr, "original: (%d)\n------------\n%.*s\n------------\n\n", 
               (int) [data length], 
               (int) [data length], [data bytes]);
      fprintf( stderr, "failed  : (%d)\n------------\n%.*s\n------------\n\n", 
               (int) [data2 length],
               (int) [data2 length], [data2 bytes]);
      return( 1);
   }

   return( 0);
}

