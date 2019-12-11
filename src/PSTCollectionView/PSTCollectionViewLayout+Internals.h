//
//  PSTCollectionViewLayout+Internals.h
//  FMPSTCollectionView
//
//  Created by Scott Talbot on 27/02/13.
//  Copyright (c) 2013 Scott Talbot. All rights reserved.
//

#import "PSTCollectionViewLayout.h"


@interface PSTCollectionViewLayout (Internals)

@property ( copy, readonly) NSDictionary * decorationViewClassDict;
@property ( copy, readonly) NSDictionary * decorationViewNibDict;
@property ( copy, readonly) NSDictionary * decorationViewExternalObjectsTables;

@end
