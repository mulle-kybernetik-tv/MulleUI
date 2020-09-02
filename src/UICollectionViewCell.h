//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#ifdef __has_include
# if __has_include( "UIView.h")
#  import "UIView.h"
# endif
#endif

#import "import.h"


@interface UIView ( UICollectionViewCell)

- (BOOL) isUICollectionViewCell;

@end


@interface UICollectionViewCell : UIView

@property( readonly, copy) NSString  *reuseIdentifier;

@property( getter=isSelected) BOOL      selected;
@property( getter=isHighlighted) BOOL   highlighted;

- (void) prepareForReuse;

@end
