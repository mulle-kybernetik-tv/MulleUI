//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#ifdef __has_include
# if __has_include( "UIView.h")
#  import "UIView.h"
# endif
#endif

#import "import.h"


@class UIImage;


@interface UIImageView : UIView

- (instancetype) initWithImage:(UIImage *) image;

@end
