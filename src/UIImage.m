#import "UIImage.h"

#import "CGContext.h"


@implementation UIImage 


- (instancetype) initWithMulleData:(struct mulle_data) data
                         allocator:(struct mulle_allocator *) allocator
{
   _fileData          = data;
   _fileDataAllocator = allocator;
   _fileEncoding      = UIImageDataEncodingFromMulleData( data);
   
   return( self);
}


- (instancetype) initWithMulleData:(struct mulle_data) data
                     sharingObject:(id) sharingObject
{
   _fileDataSharingObject = [sharingObject retain];
   return( [self initWithMulleData:data
                         allocator:NULL]);
}


enum UIImageDataEncoding   UIImageDataEncodingFromMulleData(struct mulle_data data)
{
   // could be more clever...
   if( data.length > 4 && ! strncmp( data.bytes, "<svg", 4))
      return( UIImageDataEncodingSVG);

   return( UIImageDataEncodingUnknown);
}


- (instancetype) initWithContentsOfFileWithFileRepresentationString:(char *) filename
{
   FILE                     *fp;
	ssize_t                  actual_length;
   struct mulle_data        data;
   struct mulle_allocator   *allocator;

	fp = fopen( filename, "r");
	if( ! fp)
   { 
      [self release];
      return( nil);
   }

   fseek( fp, 0, SEEK_END);
   data.length = ftell( fp);
   fseek( fp, 0, SEEK_SET);
   allocator  = MulleObjCInstanceGetAllocator( self);
   data.bytes = mulle_allocator_malloc( allocator, data.length);
	actual_length = fread( data.bytes, 1, data.length, fp);
   fclose( fp);

   if( actual_length != data.length)
   { 
      [self release];
      return( nil);
   }

   return( [self initWithMulleData:data
                         allocator:allocator]);   
}


- (void) dealloc 
{
   if( _fileDataAllocator)
      mulle_allocator_free( _fileDataAllocator, _fileData.bytes);
   [_fileDataSharingObject release];

   [super dealloc];
}


- (struct mulle_data) mulleData
{
   return( _fileData);
}


- (void) clearData
{
   if( _fileDataAllocator)
      mulle_allocator_free( _fileDataAllocator, _fileData.bytes);	
   _fileData = mulle_data_make( 0, 0);
}


// "abstract"
- (Class) preferredLayerClass
{
	return( Nil);
}

- (int) textureIDWithContext:(CGContext *) context
{
   return( context ? [context registerTextureIDForImage:self] : -1);
}

- (int) nvgImageFlags
{
   return( 0);
}

- (UIImage *) imageWithNVGImageFlags:(int) flags
{
   if( flags == [self nvgImageFlags])
      return( self);
   return( nil);
}

- (enum UIImageDataEncoding) fileEncoding
{
   return( _fileEncoding);
}

@end
