//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "UIView.h"

#import "UIEdgeInsets.h"


typedef enum 
{
   UILayoutConstraintAxisVertical   = 0,  
   UILayoutConstraintAxisHorizontal
} UILayoutConstraintAxis;

typedef enum 
{
   UIStackViewDistributionFill      = 0,  
   UIStackViewDistributionFillEqually,
   UIStackViewDistributionFillProportionally,
   UIStackViewDistributionEqualSpacing, // probably not
   UIStackViewDistributionEqualCentering 
} UIStackViewDistribution;


typedef enum 
{
   UIStackViewAlignmentFill = 0,  
   UIStackViewAlignmentLeading,
   UIStackViewAlignmentTop,   
   UIStackViewAlignmentFirstBaseline,  // probably not
   UIStackViewAlignmentCenter,
   UIStackViewAlignmentTrailing,
   UIStackViewAlignmentLastBaseline    // probably not
} UIStackViewAlignment;


// The stackview shares the name with iOS but its very different
@interface UIStackView : UIView

@property UILayoutConstraintAxis    axis;
@property UIStackViewDistribution   distribution;
@property UIStackViewAlignment      alignment;

@property UIEdgeInsets              contentInsets;

@end
