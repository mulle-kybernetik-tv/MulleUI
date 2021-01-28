//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
// prefer a local UIImage over one in import.h
#ifdef __has_include
# if __has_include( "UIImage.h")
#  import "UIImage.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"


@interface UIImage( NSData)

// FileData is kept as read/only
+ (instancetype) imageWithFileData:(NSData *) data;
- (instancetype) initWithFileData:(NSData *) data;

@end
