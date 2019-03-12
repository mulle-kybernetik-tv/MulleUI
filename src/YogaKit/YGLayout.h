/**
 * Copyright (c) 2014-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "import.h"
#import "UIView.h"
#import <yoga/YGEnums.h>
#import <yoga/Yoga.h>
#import <yoga/YGMacros.h>

YG_EXTERN_C_BEGIN

extern YGValue YGPointValue(CGFloat value)
    NS_SWIFT_UNAVAILABLE("Use the swift Int and FloatingPoint extensions instead");
extern YGValue YGPercentValue(CGFloat value)
    NS_SWIFT_UNAVAILABLE("Use the swift Int and FloatingPoint extensions instead");

YG_EXTERN_C_END

typedef NS_OPTIONS(NSInteger, YGDimensionFlexibility) {
  YGDimensionFlexibilityFlexibleWidth = 1 << 0,
  YGDimensionFlexibilityFlexibleHeigth = 1 << 1,
};



@interface YGLayout : NSObject

@property (nonatomic, assign, readonly) YGNodeRef   node;

/**
  The property that decides if we should include this view when calculating layout. Defaults to YES.
 */
@property (nonatomic, assign, setter=setIncludedInLayout:) BOOL isIncludedInLayout;

/**
 The property that decides during layout/sizing whether or not styling properties should be applied.
 Defaults to NO.
 */
@property (nonatomic, assign, setter=setEnabled:) BOOL isEnabled;

@property (nonatomic, assign) YGDirection direction;
@property (nonatomic, assign) YGFlexDirection flexDirection;
@property (nonatomic, assign) YGJustify justifyContent;
@property (nonatomic, assign) YGAlign alignContent;
@property (nonatomic, assign) YGAlign alignItems;
@property (nonatomic, assign) YGAlign alignSelf;
@property (nonatomic, assign) YGPositionType position;
@property (nonatomic, assign) YGWrap flexWrap;
@property (nonatomic, assign) YGOverflow overflow;
@property (nonatomic, assign) YGDisplay display;

@property (nonatomic, assign) CGFloat flexGrow;
@property (nonatomic, assign) CGFloat flexShrink;
@property (nonatomic, assign) YGValue flexBasis;

@property (nonatomic, assign) YGValue left;
@property (nonatomic, assign) YGValue top;
@property (nonatomic, assign) YGValue right;
@property (nonatomic, assign) YGValue bottom;
@property (nonatomic, assign) YGValue start;
@property (nonatomic, assign) YGValue end;

@property (nonatomic, assign) YGValue marginLeft;
@property (nonatomic, assign) YGValue marginTop;
@property (nonatomic, assign) YGValue marginRight;
@property (nonatomic, assign) YGValue marginBottom;
@property (nonatomic, assign) YGValue marginStart;
@property (nonatomic, assign) YGValue marginEnd;
@property (nonatomic, assign) YGValue marginHorizontal;
@property (nonatomic, assign) YGValue marginVertical;
@property (nonatomic, assign) YGValue margin;

@property (nonatomic, assign) YGValue paddingLeft;
@property (nonatomic, assign) YGValue paddingTop;
@property (nonatomic, assign) YGValue paddingRight;
@property (nonatomic, assign) YGValue paddingBottom;
@property (nonatomic, assign) YGValue paddingStart;
@property (nonatomic, assign) YGValue paddingEnd;
@property (nonatomic, assign) YGValue paddingHorizontal;
@property (nonatomic, assign) YGValue paddingVertical;
@property (nonatomic, assign) YGValue padding;

@property (nonatomic, assign) CGFloat borderLeftWidth;
@property (nonatomic, assign) CGFloat borderTopWidth;
@property (nonatomic, assign) CGFloat borderRightWidth;
@property (nonatomic, assign) CGFloat borderBottomWidth;
@property (nonatomic, assign) CGFloat borderStartWidth;
@property (nonatomic, assign) CGFloat borderEndWidth;
@property (nonatomic, assign) CGFloat borderWidth;

@property (nonatomic, assign) YGValue width;
@property (nonatomic, assign) YGValue height;
@property (nonatomic, assign) YGValue minWidth;
@property (nonatomic, assign) YGValue minHeight;
@property (nonatomic, assign) YGValue maxWidth;
@property (nonatomic, assign) YGValue maxHeight;

// Yoga specific properties, not compatible with flexbox specification
@property (nonatomic, assign) CGFloat aspectRatio;

/**
 Get the resolved direction of this node. This won't be YGDirectionInherit
 */
@property (nonatomic, readonly, assign) YGDirection resolvedDirection;

/**
 Perform a layout calculation and update the frames of the views in the hierarchy with the results.
 If the origin is not preserved, the root view's layout results will applied from {0,0}.
 */
- (void)applyLayoutPreservingOrigin:(BOOL)preserveOrigin
    NS_SWIFT_NAME(applyLayout(preservingOrigin:));

/**
 Perform a layout calculation and update the frames of the views in the hierarchy with the results.
 If the origin is not preserved, the root view's layout results will applied from {0,0}.
 */
- (void)applyLayoutPreservingOrigin:(BOOL)preserveOrigin
               dimensionFlexibility:(YGDimensionFlexibility)dimensionFlexibility
    NS_SWIFT_NAME(applyLayout(preservingOrigin:dimensionFlexibility:));

/**
 Returns the size of the view if no constraints were given. This could equivalent to calling [self
 sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
 */
@property (nonatomic, readonly, assign) CGSize intrinsicSize;

/**
  Returns the size of the view based on provided constraints. Pass NaN for an unconstrained dimension.
 */
- (CGSize)calculateLayoutWithSize:(CGSize)size
    NS_SWIFT_NAME(calculateLayout(with:));

/**
 Returns the number of children that are using Flexbox.
 */
@property (nonatomic, readonly, assign) NSUInteger numberOfChildren;

/**
 Return a BOOL indiciating whether or not we this node contains any subviews that are included in
 Yoga's layout.
 */
@property (nonatomic, readonly, assign) BOOL isLeaf;

/**
 Return's a BOOL indicating if a view is dirty. When a node is dirty
 it usually indicates that it will be remeasured on the next layout pass.
 */
@property (nonatomic, readonly, assign) BOOL isDirty;

/**
 Mark that a view's layout needs to be recalculated. Only works for leaf views.
 */
- (void)markDirty;

@property (nonatomic, assign, readonly) UIView *view;


@end
