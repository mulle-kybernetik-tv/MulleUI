//
//  PSTCollectionViewController.m
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import "PSTCollectionViewController.h"
#import "PSTCollectionView.h"
#import "UIView+Yoga.h"


@implementation PSTCollectionViewController

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (id) initWithCollectionViewLayout:(PSTCollectionViewLayout *)layout 
{
    if ((self = [super init])) {
        _layout = [layout retain];
        _collectionViewControllerFlags.clearsSelectionOnViewWillAppear = YES;
        _collectionViewControllerFlags.appearsFirstTime = YES;
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController

- (void)loadView 
{
   UIView   *view;

   [super loadView];

   view = [self view];

    // if this is restored from IB, we don't have plain main view.
    if ([view isKindOfClass:[PSTCollectionView class]]) 
    {
        _collectionView = (PSTCollectionView *)[view retain];
        [_view autorelease];
        _view = [[UIView alloc] initWithFrame:[view bounds]];
        [_collectionView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    }

    if ([_collectionView delegate] == nil) 
      [_collectionView setDelegate:self];
    if ([_collectionView dataSource] == nil) 
      [_collectionView setDataSource:self];

    // only create the collection view if it is not already created (by IB)
    if (!_collectionView) {
        _collectionView = [[PSTCollectionView alloc] initWithFrame:[[self view] bounds] 
                                              collectionViewLayout:[self layout]];
        [_collectionView setDelegate:self];
        [_collectionView setDataSource:self];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // This seems like a hack, but is needed for real compatibility
    // There can be implementations of loadView that don't call super and don't set the view, yet it works in UICollectionViewController.
    if (! [self isViewLoaded]) 
    {
       [_view autorelease];
        _view = [[UIView alloc] initWithFrame:CGRectZero];
    }

    // Attach the view
    if ([self view] != _collectionView) {
        [[self view] addSubview:_collectionView];
        [_collectionView setFrame:[[self view] bounds]];
        [_collectionView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (_collectionViewControllerFlags.appearsFirstTime) {
        [_collectionView reloadData];
        _collectionViewControllerFlags.appearsFirstTime = NO;
    }

    if (_collectionViewControllerFlags.clearsSelectionOnViewWillAppear) {
        for (NSIndexPath *aIndexPath in [_collectionView indexPathsForSelectedItems]) {
            [_collectionView deselectItemAtIndexPath:aIndexPath animated:animated];
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lazy load the collection view

- (PSTCollectionView *)collectionView 
{
   UIView   *view;

    if (!_collectionView) 
    {
        _collectionView = [[PSTCollectionView alloc] initWithFrame:CGRectMake( 0, 0, 1024, 768) 
                                              collectionViewLayout:[self layout]];
        [_collectionView setDelegate:self];
        [_collectionView setDataSource:self];

        // If the collection view isn't the main view, add it.
        if( [self isViewLoaded])
        {
           view = [self view]; 

           if( view != _collectionView) 
           {
               [view addSubview:_collectionView];
               [_collectionView setFrame:[view bounds]];
               [_collectionView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
           }
        }    
    }
    return _collectionView;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Properties

- (void)setClearsSelectionOnViewWillAppear:(BOOL)clearsSelectionOnViewWillAppear {
    _collectionViewControllerFlags.clearsSelectionOnViewWillAppear = (unsigned int)clearsSelectionOnViewWillAppear;
}

- (BOOL)clearsSelectionOnViewWillAppear {
    return _collectionViewControllerFlags.clearsSelectionOnViewWillAppear;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSTCollectionViewDataSource

- (NSInteger)collectionView:(PSTCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}

- (PSTCollectionViewCell *)collectionView:(PSTCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
