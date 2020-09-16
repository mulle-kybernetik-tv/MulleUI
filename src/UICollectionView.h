//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "UIScrollView.h"

#import "import.h"

#import "UICollectionViewCell.h"

@class UICollectionView;
@class NSIndexPath;

//
// Move UICollectionView to MulleUIPlus, which is based on Foundation
// whereas the UIView doesn't really use NSArray/NSMutableArray.
//

@protocol UICollectionViewDataSource 

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView;;
- (NSInteger) collectionView:(UICollectionView *)collectionView 
      numberOfItemsInSection:(NSInteger) section;

- (UICollectionViewCell *) collectionView:(UICollectionView *) collectionView 
                   cellForItemAtIndexPath:(NSIndexPath *) indexPath;
@end 


@protocol UICollectionViewDelegate 
@end 


// A UICollectionView does not have a fixed size of subviews. Instead
// it manages them via a data source. The UICollectionView in MulleUI always
// has only one section. Section 0. There are no adorning views.
//
@interface UICollectionView : UIScrollView < UICollectionViewCellDelegate>
{
   NSMutableDictionary   *_cellClassRegistry;
   NSMutableDictionary   *_cellPool;
   NSMutableSet          *_selectedIndexes;  // indices ??
}

@property( assign) id <UICollectionViewDataSource>   dataSource;

@property( retain) Class    cellClass;  // UICollectionViewCell is default
@property( assign) CGSize   itemSize;
@property( assign) CGSize   itemSpacing;    

- (void) reloadData;

- (void)     registerClass:(Class) cellClass 
forCellWithReuseIdentifier:(NSString *) identifier;

- (UICollectionViewCell *) 
   dequeueReusableCellWithReuseIdentifier:(NSString *) identifier 
                             forIndexPath:(NSIndexPath *) indexPath;

- (NSArray *) indexPathsForSelectedItems;
- (NSIndexPath *) indexPathForCell:(UICollectionViewCell *) cell;

@end
