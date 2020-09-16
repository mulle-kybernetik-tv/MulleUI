//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#ifdef __has_include
# if __has_include( "UIView.h")
#  import "UIView.h"
# endif
#endif

#import "import.h"

#ifdef __has_include
# if __has_include( "UIControl.h")
#  import "UIControl.h"
# endif
#endif


@interface UIView ( UICollectionViewCell)

- (BOOL) isUICollectionViewCell;

@end


@class UICollectionViewCell;
@class NSIndexPath;


@protocol UICollectionViewCellDelegate 

- (void)       cell:(UICollectionViewCell *) cell
   didChangeStateTo:(UIControlState) state 
          fromState:(UIControlState) oldState;

@end 


//
// Consider using a protocolclass for this
//
@interface UICollectionViewCell : UIView < UIControl>
{
   UIControlIvars;
   NSIndexPath       *_indexPath;
}

UIControlProperties;

@property( readonly, copy) NSString                    *reuseIdentifier;
@property( assign) id <UICollectionViewCellDelegate>   delegate;
@property( copy) NSIndexPath                           *indexPath;

- (void) prepareForReuse;

- (UIView *) contentView;  // currently self

@end

