//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "UIView+Layout.h"

#import "UIEdgeInsets.h"


typedef enum 
{
   UIStackViewDistributionFill      = 0,  
   UIStackViewDistributionFillEqually,
   UIStackViewDistributionFillProportionally,
   UIStackViewDistributionEqualSpacing, 
   UIStackViewDistributionEqualCentering,
   MulleStackViewDistributionFillRowColumn
} UIStackViewDistribution;


typedef enum 
{
   UIStackViewAlignmentCenter = 0,     // center is the new default!  
   UIStackViewAlignmentLeading,
   UIStackViewAlignmentTop,   
   UIStackViewAlignmentTrailing,
   MulleUIStackViewAlignmentBottom   
} UIStackViewAlignment;


// The stackview shares the name with iOS but its very different
@interface UIStackView : UIView

@property UILayoutConstraintAxis    axis;
@property UIStackViewDistribution   distribution;

@property UIEdgeInsets              contentInsets;

// the alignment is not used if the subview has a autoresizingMask set
@property UIStackViewAlignment      alignment;

// used for MulleStackViewDistributionFillRowColumn only
@property CGFloat                   minimumInteritemSpacing;
@property CGFloat                   minimumLineSpacing;

@end
