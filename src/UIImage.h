#import "import.h"

#import "CGGeometry.h"

@class CGContext;

// currently supported types, not very expandable...
enum UIImageDataEncoding
{
   UIImageDataEncodingUnknown = 0,
   UIImageDataEncodingPNG,
   UIImageDataEncodingJPG,
   UIImageDataEncodingBMP,
   UIImageDataEncodingSVG
};

//
// An UIImage can retain the file data read or set, so in the event
// that UIImage returns fileData it will not compress again.
// If you want to load decoded bitmap data, use MulleBitmapImage
// directly (see BitmapBytes method)
//
@interface UIImage : NSObject 
{
   id                             _fileDataSharingObject;
   struct mulle_data              _fileData;
   struct mulle_allocator        *_fileDataAllocator;
   enum UIImageDataEncoding       _fileEncoding; 
}

// if allocator is NULL, data will not be freed
// otherwise allocator will be used to free. Use &mulle_allocator_stdlib
// for malloced data
- (instancetype) initWithMulleData:(struct mulle_data) data
                         allocator:(struct mulle_allocator *) allocator;
// data belongs to sharingObject, which will be retained                     
- (instancetype) initWithMulleData:(struct mulle_data) data
                     sharingObject:(id) sharingObject;

- (instancetype) initWithContentsOfFileWithFileRepresentationString:(char *) filename;

// this is added as a category by the layer to the specific UIImage subclass
- (Class) preferredLayerClass;

- (int) textureIDWithContext:(CGContext *) context;

//
// Textures (images) in NVG can be created with different flags, for example 
// REPEAT_X andREPEAT_Y. When we are asking the CGContext for a textureID 
// for an image this will create such a NVG texture. As the context cashes the
// textureID for each UIImage it's simplest to store the nvgImageFlags here
// (readonly) and to clone UIImages for different flags. The actual image
// data can be shared w/o a problem. The default is 0:
// 
- (int) nvgImageFlags;

//
// Derive an image, that supports the given NVGflags. If the value can not be
// supported by the UIImage subclass, this will return nil.
// May return self!
//
- (UIImage *) imageWithNVGImageFlags:(int) flags;

- (enum UIImageDataEncoding) fileEncoding;
// TODO: rename to fileData or mulleFileData or so
- (struct mulle_data) mulleData;

@end


@interface UIImage( UIImageSubclass)

- (CGSize) size;
- (CGRect) visibleBounds;

@end


enum UIImageDataEncoding   UIImageDataEncodingFromMulleData(struct mulle_data data);
