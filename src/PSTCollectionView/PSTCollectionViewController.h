//
//  PSTCollectionViewController.h
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//
#import "UIViewController.h"


#import "PSTCollectionViewCommon.h"


@class PSTCollectionViewLayout, PSTCollectionViewController;

// Simple controller-wrapper around PSTCollectionView.
@interface PSTCollectionViewController : UIViewController <PSTCollectionViewDelegate, PSTCollectionViewDataSource>
{
    PSTCollectionViewLayout *_layout;
    PSTCollectionView *_collectionView;
    struct {
        unsigned int clearsSelectionOnViewWillAppear : 1;
        unsigned int appearsFirstTime : 1; // PST extension!
    }_collectionViewControllerFlags;
    char filler[100]; // [HACK] Our class needs to be larger than Apple's class for the superclass change to work.
}
@property ( retain) PSTCollectionViewLayout *layout;

// Designated initializer.
- (id)initWithCollectionViewLayout:(PSTCollectionViewLayout *)layout;

// Internally used collection view. If not set, created during loadView.
@property ( retain) PSTCollectionView *collectionView;

// Defaults to YES, and if YES, any selection is cleared in viewWillAppear:
@property ( assign) BOOL clearsSelectionOnViewWillAppear;

@end
