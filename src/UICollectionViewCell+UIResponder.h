//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
// prefer a local UICollectionViewCell over one in import.h
#ifdef __has_include
# if __has_include( "UICollectionViewCell.h")
#  import "UICollectionViewCell.h"
# endif
#endif

// we wan't "import.h" always anyway
#import "import.h"

// Should be maybe UIControl instead of UIResponder ??
@interface UICollectionViewCell( UIResponder)
@end
