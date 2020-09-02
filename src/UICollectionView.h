//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "UIScrollView.h"

#import "import.h"

@class UICollectionView;
@class UICollectionViewCell;
@class NSIndexPath;


//
// Move UICollectionView to MulleUIPlus, which is based on Foundation
// whereas the other code is from NSArray/NSMutableArray
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
@interface UICollectionView : UIScrollView
{
   NSMutableDictionary   *_cellClassRegistry;
   NSMutableDictionary   *_cellPool;
}

@property( assign) id <UICollectionViewDataSource>   dataSource;

@property( retain) Class    cellClass;  // UICollectionViewCell is default
@property( assign) CGSize   cellSize;
@property( assign) CGSize   itemSpacing;    

- (void) reloadData;

- (void)     registerClass:(Class)cellClass 
forCellWithReuseIdentifier:(NSString *)identifier;

- (UICollectionViewCell *) 
   dequeueReusableCellWithReuseIdentifier:(NSString *) identifier 
                             forIndexPath:(NSIndexPath *) indexPath;

@end
