#include <stdio.h>
#include <string.h>
#include <stdlib.h>

//
// stolen from https://stackoverflow.com/questions/2654480/writing-bmp-image-in-pure-c-c-without-other-libraries#2654860
// and pretty much completely rewritten
// Note: removed padding code, since we are dumping 32 bits anyway
//

typedef unsigned char   bmp_fileheader_t[ 14];
typedef unsigned char   bmp_infoheader_t[ 40];

#define BMP_BYTESPERPIXEL   4  // this is more for readability than for change


static void   bmp_init_fileheader( bmp_fileheader_t fileheader,
                                   unsigned int width,
                                   unsigned int height)
{
   unsigned int  size;

   size = sizeof( bmp_fileheader_t) + sizeof( bmp_infoheader_t) + (width * BMP_BYTESPERPIXEL) * height;

   memset( fileheader, 0, sizeof( bmp_fileheader_t));

   fileheader[0]  = (unsigned char) ('B');
   fileheader[1]  = (unsigned char) ('M');
   fileheader[2]  = (unsigned char) (size);
   fileheader[3]  = (unsigned char) (size >> 8);
   fileheader[4]  = (unsigned char) (size >> 16);
   fileheader[5]  = (unsigned char) (size >> 24);
   fileheader[10] = (unsigned char) (sizeof( bmp_fileheader_t) + sizeof( bmp_infoheader_t));
}


static void   bmp_init_infoheader( bmp_infoheader_t infoheader,
                                   unsigned int width,
                                   unsigned int height)
{
   memset( infoheader, 0, sizeof( bmp_infoheader_t));

   infoheader[0]  = (unsigned char) (sizeof( bmp_infoheader_t));
   infoheader[4]  = (unsigned char) (width);
   infoheader[5]  = (unsigned char) (width >> 8);
   infoheader[6]  = (unsigned char) (width >> 16);
   infoheader[7]  = (unsigned char) (width >> 24);
   infoheader[8]  = (unsigned char) (height);
   infoheader[9]  = (unsigned char) (height >> 8);
   infoheader[10] = (unsigned char) (height >> 16);
   infoheader[11] = (unsigned char) (height >> 24);
   infoheader[12] = (unsigned char) (1);
   infoheader[14] = (unsigned char) (BMP_BYTESPERPIXEL * 8);
}


static FILE  *bmpfile_create( char *filename,
                              unsigned int width,
                              unsigned int height)
{
   bmp_fileheader_t   fileheader;
   bmp_infoheader_t   infoheader;
   FILE               *fp;
   int                rval;
   unsigned char      *image;
   unsigned int       i;
   unsigned int       size;
   unsigned int       written;

   bmp_init_fileheader( fileheader, width, height);
   bmp_init_infoheader( infoheader, width, height);

   fp = fopen( filename, "wb");
   if( ! fp)
      return( NULL);

   written  = fwrite( fileheader, 1, sizeof( bmp_fileheader_t), fp);
   written += fwrite( infoheader, 1, sizeof( bmp_infoheader_t), fp);
   if( written != sizeof( bmp_fileheader_t) + sizeof( bmp_infoheader_t))
   {
      fclose( fp);
      return( NULL);
   }
   return( fp);
}


static inline int   bmpfile_close( FILE *fp)
{
   return( fclose( fp));
}


static int   bmpfile_write_rgb32( FILE *fp,
                                  void *bitmap,
                                  unsigned int width,
                                  unsigned int height,
                                  int stridebytes)
{
   size_t          written;
   size_t          expected;
   unsigned char   *image;
   unsigned int    i;

   image     = bitmap;
   written   = 0;
   for( i = 0; i < height; i++)
   {
      written += fwrite( image, BMP_BYTESPERPIXEL, width, fp) * BMP_BYTESPERPIXEL;
      image   += stridebytes;
   }

   expected = (BMP_BYTESPERPIXEL * width) * height;
   return( written == expected ? 0 : -1);
}


int   bmp_rgb32_write_file( char *filename,
                            void *image,
                            unsigned int width,
                            unsigned int height,
                            int stridebytes)
{
   FILE   *fp;
   int    rval;

   if( ! stridebytes)
      stridebytes = width * 4;

   fp = bmpfile_create( filename, width, height);
   if( ! fp)
      return( -1);

   rval = bmpfile_write_rgb32( fp, image, width, height, stridebytes);
   bmpfile_close( fp);

   return( rval);
}


static int   bmpfile_write_grayscale( FILE *fp,
                                      void *bitmap,
                                      unsigned int width,
                                      unsigned int height,
                                      int stridebytes)
{
   size_t          written;
   size_t          expected;
   unsigned char   *image;
   unsigned int    i;
   unsigned int    j;
   unsigned int    n_padding;
   char            *convert;

   convert = malloc( width * BMP_BYTESPERPIXEL);
   if( ! convert)
      return( -1);

   image     = bitmap;
   written   = 0;
   for( i = 0; i < height; i++)
   {
      for( j = 0; j < width; j++)
         memset( &convert[ j * BMP_BYTESPERPIXEL], image[ j], BMP_BYTESPERPIXEL);
      image   += stridebytes;
      written += fwrite( convert, BMP_BYTESPERPIXEL, width, fp) * BMP_BYTESPERPIXEL;
   }

   expected = (BMP_BYTESPERPIXEL * width) * height;
   free( convert);

   return( written == expected ? 0 : -1);
}


int   bmp_grayscale_write_file( char *filename,
                                void *image,
                                unsigned int width,
                                unsigned int height,
                                unsigned int stridebytes)
{
   FILE   *fp;
   int    rval;

   if( ! stridebytes)
      stridebytes = width;

   fp = bmpfile_create( filename, width, height);
   if( ! fp)
      return( -1);

   rval = bmpfile_write_grayscale( fp, image, width, height, stridebytes);
   bmpfile_close( fp);

   return( rval);
}
