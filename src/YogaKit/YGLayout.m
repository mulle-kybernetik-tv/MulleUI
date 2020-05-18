/**
 * Copyright (c) 2014-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "YGLayout.h"
#import "UIView+Yoga.h"
#import "UIView+NSArray.h"
#import "UIView+Layout.h"


#define YG_PROPERTY(type, lowercased_name, capitalized_name)      \
  -(type)lowercased_name {                                        \
    return YGNodeStyleGet##capitalized_name([self node]);           \
  }                                                               \
                                                                  \
  -(void)set##capitalized_name : (type)lowercased_name {          \
    YGNodeStyleSet##capitalized_name([self node], lowercased_name); \
  }

#define YG_VALUE_PROPERTY(lowercased_name, capitalized_name)                \
  -(YGValue)lowercased_name {                                               \
    return YGNodeStyleGet##capitalized_name([self node]);                     \
  }                                                                         \
                                                                            \
  -(void)set##capitalized_name : (YGValue)lowercased_name {                 \
    switch (lowercased_name.unit) {                                         \
      case YGUnitUndefined:                                                 \
        YGNodeStyleSet##capitalized_name([self node], lowercased_name.value); \
        break;                                                              \
      case YGUnitPoint:                                                     \
        YGNodeStyleSet##capitalized_name([self node], lowercased_name.value); \
        break;                                                              \
      case YGUnitPercent:                                                   \
        YGNodeStyleSet##capitalized_name##Percent(                          \
            [self node], lowercased_name.value);                              \
        break;                                                              \
      default:                                                              \
        NSAssert(NO, @"Not implemented");                                   \
    }                                                                       \
  }

#define YG_AUTO_VALUE_PROPERTY(lowercased_name, capitalized_name)           \
  -(YGValue)lowercased_name {                                               \
    return YGNodeStyleGet##capitalized_name([self node]);                     \
  }                                                                         \
                                                                            \
  -(void)set##capitalized_name : (YGValue)lowercased_name {                 \
    switch (lowercased_name.unit) {                                         \
      case YGUnitPoint:                                                     \
        YGNodeStyleSet##capitalized_name([self node], lowercased_name.value); \
        break;                                                              \
      case YGUnitPercent:                                                   \
        YGNodeStyleSet##capitalized_name##Percent(                          \
            [self node], lowercased_name.value);                              \
        break;                                                              \
      case YGUnitAuto:                                                      \
        YGNodeStyleSet##capitalized_name##Auto([self node]);                  \
        break;                                                              \
      default:                                                              \
        NSAssert(NO, @"Not implemented");                                   \
    }                                                                       \
  }

#define YG_EDGE_PROPERTY_GETTER(                             \
    type, lowercased_name, capitalized_name, property, edge) \
  -(type)lowercased_name {                                   \
    return YGNodeStyleGet##property([self node], edge);        \
  }

#define YG_EDGE_PROPERTY_SETTER(                                \
    lowercased_name, capitalized_name, property, edge)          \
  -(void)set##capitalized_name : (CGFloat)lowercased_name {     \
    YGNodeStyleSet##property([self node], edge, lowercased_name); \
  }

#define YG_EDGE_PROPERTY(lowercased_name, capitalized_name, property, edge) \
  YG_EDGE_PROPERTY_GETTER(                                                  \
      CGFloat, lowercased_name, capitalized_name, property, edge)           \
  YG_EDGE_PROPERTY_SETTER(lowercased_name, capitalized_name, property, edge)

#define YG_VALUE_EDGE_PROPERTY_SETTER(                                       \
    objc_lowercased_name, objc_capitalized_name, c_name, edge)               \
  -(void)set##objc_capitalized_name : (YGValue)objc_lowercased_name {        \
    switch (objc_lowercased_name.unit) {                                     \
      case YGUnitUndefined:                                                  \
        YGNodeStyleSet##c_name([self node], edge, objc_lowercased_name.value); \
        break;                                                               \
      case YGUnitPoint:                                                      \
        YGNodeStyleSet##c_name([self node], edge, objc_lowercased_name.value); \
        break;                                                               \
      case YGUnitPercent:                                                    \
        YGNodeStyleSet##c_name##Percent(                                     \
            [self node], edge, objc_lowercased_name.value);                    \
        break;                                                               \
      default:                                                               \
        NSAssert(NO, @"Not implemented");                                    \
    }                                                                        \
  }

#define YG_VALUE_EDGE_PROPERTY(                                   \
    lowercased_name, capitalized_name, property, edge)            \
  YG_EDGE_PROPERTY_GETTER(                                        \
      YGValue, lowercased_name, capitalized_name, property, edge) \
  YG_VALUE_EDGE_PROPERTY_SETTER(                                  \
      lowercased_name, capitalized_name, property, edge)

#define YG_VALUE_EDGES_PROPERTIES(lowercased_name, capitalized_name) \
  YG_VALUE_EDGE_PROPERTY(                                            \
      lowercased_name##Left,                                         \
      capitalized_name##Left,                                        \
      capitalized_name,                                              \
      YGEdgeLeft)                                                    \
  YG_VALUE_EDGE_PROPERTY(                                            \
      lowercased_name##Top,                                          \
      capitalized_name##Top,                                         \
      capitalized_name,                                              \
      YGEdgeTop)                                                     \
  YG_VALUE_EDGE_PROPERTY(                                            \
      lowercased_name##Right,                                        \
      capitalized_name##Right,                                       \
      capitalized_name,                                              \
      YGEdgeRight)                                                   \
  YG_VALUE_EDGE_PROPERTY(                                            \
      lowercased_name##Bottom,                                       \
      capitalized_name##Bottom,                                      \
      capitalized_name,                                              \
      YGEdgeBottom)                                                  \
  YG_VALUE_EDGE_PROPERTY(                                            \
      lowercased_name##Start,                                        \
      capitalized_name##Start,                                       \
      capitalized_name,                                              \
      YGEdgeStart)                                                   \
  YG_VALUE_EDGE_PROPERTY(                                            \
      lowercased_name##End,                                          \
      capitalized_name##End,                                         \
      capitalized_name,                                              \
      YGEdgeEnd)                                                     \
  YG_VALUE_EDGE_PROPERTY(                                            \
      lowercased_name##Horizontal,                                   \
      capitalized_name##Horizontal,                                  \
      capitalized_name,                                              \
      YGEdgeHorizontal)                                              \
  YG_VALUE_EDGE_PROPERTY(                                            \
      lowercased_name##Vertical,                                     \
      capitalized_name##Vertical,                                    \
      capitalized_name,                                              \
      YGEdgeVertical)                                                \
  YG_VALUE_EDGE_PROPERTY(                                            \
      lowercased_name, capitalized_name, capitalized_name, YGEdgeAll)

YGValue YGPointValue(CGFloat value)
{
  return (YGValue) { .value = value, .unit = YGUnitPoint };
}

YGValue YGPercentValue(CGFloat value)
{
  return (YGValue) { .value = value, .unit = YGUnitPercent };
}

static YGConfigRef globalConfig;


@implementation YGLayout

@synthesize isEnabled=_isEnabled;
@synthesize isIncludedInLayout=_isIncludedInLayout;
@synthesize node=_node;

+ (void)initialize
{
  globalConfig = YGConfigNew();
  YGConfigSetExperimentalFeatureEnabled(globalConfig, YGExperimentalFeatureWebFlexBasis, true);
  // YGConfigSetPointScaleFactor(globalConfig, [UIScreen mainScreen].scale);
  YGConfigSetPointScaleFactor(globalConfig, 1.0);
}

- (instancetype)initWithView:(UIView*)view
{
   assert( view);
  if (self = [super init]) {
    _view = view;
    _node = YGNodeNewWithConfig(globalConfig);
    YGNodeSetContext(_node, (__bridge void *) view);
    _isEnabled = NO;
    _isIncludedInLayout = YES;
  }

  return self;
}

- (void)dealloc
{
  YGNodeFree([self node]);
  [super dealloc];
}

- (BOOL)isDirty
{
  return YGNodeIsDirty([self node]);
}

- (void)markDirty
{
  if ([self isDirty] || ![self isLeaf]) {
    return;
  }

  // Yoga is not happy if we try to mark a node as "dirty" before we have set
  // the measure function. Since we already know that this is a leaf,
  // this *should* be fine. Forgive me Hack Gods.
  const YGNodeRef node = [self node];
  if (YGNodeGetMeasureFunc(node) == NULL) {
    YGNodeSetMeasureFunc(node, YGMeasureView);
  }

  YGNodeMarkDirty(node);
}

- (NSUInteger)numberOfChildren
{
  return YGNodeGetChildCount([self node]);
}

- (BOOL)isLeaf
{
  // NSAssert([NSThread isMainThread], @"This method must be called on the main thread.");
  if ([self isEnabled]) {
    for (UIView *subview in [[self view] subviews]) {
      YGLayout *const yoga = [subview yoga];
      if ([yoga isEnabled] && [yoga isIncludedInLayout]) {
        return NO;
      }
    }    
  }

  return YES;
}

#pragma mark - Style

- (YGPositionType)position
{
  return YGNodeStyleGetPositionType([self node]);
}

- (void)setPosition:(YGPositionType)position
{
  YGNodeStyleSetPositionType([self node], position);
}

YG_PROPERTY(YGDirection, direction, Direction)
YG_PROPERTY(YGFlexDirection, flexDirection, FlexDirection)
YG_PROPERTY(YGJustify, justifyContent, JustifyContent)
YG_PROPERTY(YGAlign, alignContent, AlignContent)
YG_PROPERTY(YGAlign, alignItems, AlignItems)
YG_PROPERTY(YGAlign, alignSelf, AlignSelf)
YG_PROPERTY(YGWrap, flexWrap, FlexWrap)
YG_PROPERTY(YGOverflow, overflow, Overflow)
YG_PROPERTY(YGDisplay, display, Display)

YG_PROPERTY(CGFloat, flex, Flex)
YG_PROPERTY(CGFloat, flexGrow, FlexGrow)
YG_PROPERTY(CGFloat, flexShrink, FlexShrink)
YG_AUTO_VALUE_PROPERTY(flexBasis, FlexBasis)

YG_VALUE_EDGE_PROPERTY(left, Left, Position, YGEdgeLeft)
YG_VALUE_EDGE_PROPERTY(top, Top, Position, YGEdgeTop)
YG_VALUE_EDGE_PROPERTY(right, Right, Position, YGEdgeRight)
YG_VALUE_EDGE_PROPERTY(bottom, Bottom, Position, YGEdgeBottom)
YG_VALUE_EDGE_PROPERTY(start, Start, Position, YGEdgeStart)
YG_VALUE_EDGE_PROPERTY(end, End, Position, YGEdgeEnd)
YG_VALUE_EDGES_PROPERTIES(margin, Margin)
YG_VALUE_EDGES_PROPERTIES(padding, Padding)

YG_EDGE_PROPERTY(borderLeftWidth, BorderLeftWidth, Border, YGEdgeLeft)
YG_EDGE_PROPERTY(borderTopWidth, BorderTopWidth, Border, YGEdgeTop)
YG_EDGE_PROPERTY(borderRightWidth, BorderRightWidth, Border, YGEdgeRight)
YG_EDGE_PROPERTY(borderBottomWidth, BorderBottomWidth, Border, YGEdgeBottom)
YG_EDGE_PROPERTY(borderStartWidth, BorderStartWidth, Border, YGEdgeStart)
YG_EDGE_PROPERTY(borderEndWidth, BorderEndWidth, Border, YGEdgeEnd)
YG_EDGE_PROPERTY(borderWidth, BorderWidth, Border, YGEdgeAll)

YG_AUTO_VALUE_PROPERTY(width, Width)
YG_AUTO_VALUE_PROPERTY(height, Height)
YG_VALUE_PROPERTY(minWidth, MinWidth)
YG_VALUE_PROPERTY(minHeight, MinHeight)
YG_VALUE_PROPERTY(maxWidth, MaxWidth)
YG_VALUE_PROPERTY(maxHeight, MaxHeight)
YG_PROPERTY(CGFloat, aspectRatio, AspectRatio)

#pragma mark - Layout and Sizing

- (YGDirection)resolvedDirection
{
  return YGNodeLayoutGetDirection([self node]);
}

- (void)applyLayout
{
  [self applyLayoutPreservingOrigin:NO];
}

- (void)applyLayoutPreservingOrigin:(BOOL)preserveOrigin
{
  UIView  *view;
  UIView  *superview;
  CGSize  size;
  CGSize  layoutedSize;

  view = [self view];
  assert( view);

  //
  // (nat) use the superview as the parentSize it makes more sense
  // to me (ATM) and the result is better
  //
#if 1
  superview = [view superview];
  if( ! superview)
#endif  
   superview = view;
  size = [superview bounds].size;

  layoutedSize = [self calculateLayoutWithSize:size];
#if DEBUG  
  fprintf( stderr, "Layout starts with: %s (parent: %.1f,%.1f, layouted: %.1f,%.1f)\n", 
                           [view cStringDescription],
                           size.width, size.height,
                           layoutedSize.width, layoutedSize.height);
#endif
  YGApplyLayoutToViewHierarchy( view, preserveOrigin);
}

- (void)applyLayoutPreservingOrigin:(BOOL)preserveOrigin dimensionFlexibility:(YGDimensionFlexibility)dimensionFlexibility
{
  UIView  *view;
  CGSize size;

  view = [self view];
  assert( view);
  size = [view bounds].size;
  if (dimensionFlexibility & YGDimensionFlexibilityFlexibleWidth) {
    size.width = YGUndefined;
  }
  if (dimensionFlexibility & YGDimensionFlexibilityFlexibleHeight) {
    size.height = YGUndefined;
  }
  [self calculateLayoutWithSize:size];
  YGApplyLayoutToViewHierarchy( view, preserveOrigin);
}


- (CGSize)intrinsicSize
{
  const CGSize constrainedSize = {
    .width = YGUndefined,
    .height = YGUndefined,
  };
  return [self calculateLayoutWithSize:constrainedSize];
}

- (CGSize)calculateLayoutWithSize:(CGSize)size
{
  //NSAssert([NSThread isMainThread], @"Yoga calculation must be done on main.");
  //NSAssert([self isEnabled], @"Yoga is not enabled for this view.");

  YGAttachNodesFromViewHierachy([self view]);

  const YGNodeRef node = [self node];
  YGNodeCalculateLayout(
    node,
    size.width,
    size.height,
    YGNodeStyleGetDirection(node));

  return (CGSize) {
    .width = YGNodeLayoutGetWidth(node),
    .height = YGNodeLayoutGetHeight(node),
  };
}

#pragma mark - Private

static YGSize YGMeasureView(
  YGNodeRef node,
  float width,
  YGMeasureMode widthMode,
  float height,
  YGMeasureMode heightMode)
{
  const CGFloat constrainedWidth = (widthMode == YGMeasureModeUndefined) ? CGFLOAT_MAX : width;
  const CGFloat constrainedHeight = (heightMode == YGMeasureModeUndefined) ? CGFLOAT_MAX: height;

  UIView *view = (__bridge UIView*) YGNodeGetContext(node);
  const CGSize sizeThatFits = [view sizeThatFits:(CGSize) {
    .width = constrainedWidth,
    .height = constrainedHeight,
  }];

  return (YGSize) {
    .width = YGSanitizeMeasurement(constrainedWidth, sizeThatFits.width, widthMode),
    .height = YGSanitizeMeasurement(constrainedHeight, sizeThatFits.height, heightMode),
  };
}



static CGFloat YGSanitizeMeasurement(
  CGFloat constrainedSize,
  CGFloat measuredSize,
  YGMeasureMode measureMode)
{
  CGFloat result;
  if (measureMode == YGMeasureModeExactly) {
    result = constrainedSize;
  } else if (measureMode == YGMeasureModeAtMost) {
    result = constrainedSize <= measuredSize ? constrainedSize : measuredSize;
  } else {
    result = measuredSize;
  }

  return result;
}

static BOOL YGNodeHasExactSameChildren(const YGNodeRef node, NSArray * subviews)
{
  NSUInteger   i;

  if (YGNodeGetChildCount(node) != [subviews count]) {
    return NO;
  }

  i = 0;
  for (UIView *subview in subviews) {
    if (YGNodeGetChild(node, i) != [[subview yoga] node]) {
      return NO;
    }
    ++i;
  }

  return YES;
}

static void YGAttachNodesFromViewHierachy(UIView *const view)
{
  YGLayout *const yoga = [view yoga];
  const YGNodeRef node = [yoga node];
  NSUInteger i;

  // Only leaf nodes should have a measure function
  if ([yoga isLeaf]) {
    YGRemoveAllChildren(node);
    YGNodeSetMeasureFunc(node, YGMeasureView);
  } else {
    YGNodeSetMeasureFunc(node, NULL);

    MulleMutableObjectArray * subviewsToInclude = [[MulleMutableObjectArray new] autorelease];
    for (UIView *subview in [view subviews]) {
      if( [[subview yoga] isIncludedInLayout]) {
        [subviewsToInclude addObject:subview];
      }
    }

    if (!YGNodeHasExactSameChildren(node, (NSArray *) subviewsToInclude)) {
      YGRemoveAllChildren(node);
       i = 0;
       for (UIView *const subview in subviewsToInclude) {
        YGNodeInsertChild(node, [[subview yoga] node], i);
        ++i;
      }
    }

    for (UIView *const subview in subviewsToInclude) {
      YGAttachNodesFromViewHierachy(subview);
    }
  }
}

static void YGRemoveAllChildren(const YGNodeRef node)
{
  if (node == NULL) {
    return;
  }

  YGNodeRemoveAllChildren(node);
}

static CGFloat YGRoundPixelValue(CGFloat value)
{
  static CGFloat scale;

  // scaling not yet
  return roundf(value * 1.0) / 1.0;
}

static void YGApplyLayoutToViewHierarchy(UIView *view, BOOL preserveOrigin)
{
  // NSCAssert([NSThread isMainThread], @"Framesetting should only be done on the main thread.");

  const YGLayout *yoga = [view yoga];
  UIView    *subview;

  if (![yoga isIncludedInLayout]) {
     return;
  }

  YGNodeRef node = [yoga node];
  const CGPoint topLeft = {
    YGNodeLayoutGetLeft(node),
    YGNodeLayoutGetTop(node),
  };

  const CGPoint bottomRight = {
    topLeft.x + YGNodeLayoutGetWidth(node),
    topLeft.y + YGNodeLayoutGetHeight(node),
  };

  const CGPoint origin = preserveOrigin ? [view frame].origin : CGPointZero;
  [view setFrame:(CGRect) {
    .origin = {
      .x = YGRoundPixelValue(topLeft.x + origin.x),
      .y = YGRoundPixelValue(topLeft.y + origin.y),
    },
    .size = {
      .width = YGRoundPixelValue(bottomRight.x) - YGRoundPixelValue(topLeft.x),
      .height = YGRoundPixelValue(bottomRight.y) - YGRoundPixelValue(topLeft.y),
    },
  }];

  if (![yoga isLeaf]) {
    for ( subview in [view subviews]) {
      YGApplyLayoutToViewHierarchy( subview, NO);
    }
  }
}


- (NSString *) debugDescription
{
   NSMutableString   *s;

   s = [NSMutableString string];
   [s appendFormat:@""
                   "isIncludedInLayout : %s\n"
                   "isEnabled          : %s\n"
                   "direction          : %s\n"
                   "flexDirection      : %s\n"
                   "justifyContent     : %s\n"
                   "alignContent       : %s\n"
                   "alignItems         : %s\n"
                   "alignSelf          : %s\n"
                   "position           : %s\n"
                   "flexWrap           : %s\n"
                   "overflow           : %s\n"
                   "display            : %s\n",
                   _isIncludedInLayout ? "YES" : "NO",
                   _isEnabled ? "YES" : "NO",
                   YGDirectionToString( _direction),
                   YGFlexDirectionToString( _flexDirection),
                   YGJustifyToString( _justifyContent),
                   YGAlignToString( _alignContent),
                   YGAlignToString( _alignItems),
                   YGAlignToString( _alignSelf),
                   YGPositionTypeToString( _position),
                   YGWrapToString( _flexWrap),
                   YGOverflowToString( _overflow),
                   YGDisplayToString( _display)];

   [s appendFormat:@""
                   "flex               : %.2f\n"
                   "flexGrow           : %.2f\n"
                   "flexShrink         : %.2f\n",
                   _flex,
                   _flexGrow,
                   _flexShrink];

   [s appendFormat:@""
                   "flexBasis          : %.2f %s\n",
                      _flexBasis.value, YGUnitToString( _flexBasis.unit)];

   [s appendFormat:@""
                   "left               : %.2f %s\n"
                   "top                : %.2f %s\n"
                   "right              : %.2f %s\n"
                   "bottom             : %.2f %s\n"
                   "start              : %.2f %s\n"
                   "end                : %.2f %s\n",
                      _left.value, YGUnitToString( _left.unit),
                      _top.value, YGUnitToString( _top.unit),
                      _right.value, YGUnitToString( _right.unit),
                      _bottom.value, YGUnitToString( _bottom.unit),
                      _start.value, YGUnitToString( _start.unit),
                      _end.value, YGUnitToString( _end.unit)];

   [s appendFormat:@""
                   "marginLeft         : %.2f %s\n"
                   "marginTop          : %.2f %s\n"
                   "marginRight        : %.2f %s\n"
                   "marginBottom       : %.2f %s\n"
                   "marginStart        : %.2f %s\n"
                   "marginEnd          : %.2f %s\n"
                   "marginHorizontal   : %.2f %s\n"
                   "marginVertical     : %.2f %s\n"
                   "margin             : %.2f %s\n",
                      _marginLeft.value, YGUnitToString( _marginLeft.unit),
                      _marginTop.value, YGUnitToString( _marginTop.unit),
                      _marginRight.value, YGUnitToString( _marginRight.unit),
                      _marginBottom.value, YGUnitToString( _marginBottom.unit),
                      _marginStart.value, YGUnitToString( _marginStart.unit),
                      _marginEnd.value, YGUnitToString( _marginEnd.unit),
                      _marginHorizontal.value, YGUnitToString( _marginHorizontal.unit),
                      _marginVertical.value, YGUnitToString( _marginVertical.unit),
                      _margin.value, YGUnitToString( _margin.unit)];

   [s appendFormat:@""
                   "paddingLeft        : %.2f %s\n"
                   "paddingTop         : %.2f %s\n"
                   "paddingRight       : %.2f %s\n"
                   "paddingBottom      : %.2f %s\n"
                   "paddingStart       : %.2f %s\n"
                   "paddingEnd         : %.2f %s\n"
                   "paddingHorizontal  : %.2f %s\n"
                   "paddingVertical    : %.2f %s\n"
                   "padding            : %.2f %s\n",
                      _paddingLeft.value, YGUnitToString( _paddingLeft.unit),
                      _paddingTop.value, YGUnitToString( _paddingTop.unit),
                      _paddingRight.value, YGUnitToString( _paddingRight.unit),
                      _paddingBottom.value, YGUnitToString( _paddingBottom.unit),
                      _paddingStart.value, YGUnitToString( _paddingStart.unit),
                      _paddingEnd.value, YGUnitToString( _paddingEnd.unit),
                      _paddingHorizontal.value, YGUnitToString( _paddingHorizontal.unit),
                      _paddingVertical.value, YGUnitToString( _paddingVertical.unit),
                      _padding.value, YGUnitToString( _padding.unit)];

   [s appendFormat:@""
                   "borderLeftWidth    : %.2f\n"
                   "borderTopWidth     : %.2f\n"
                   "borderRightWidth   : %.2f\n"
                   "borderBottomWidth  : %.2f\n"
                   "borderStartWidth   : %.2f\n"
                   "borderEndWidth     : %.2f\n"
                   "borderWidth        : %.2f\n",
                   _borderLeftWidth,
                   _borderTopWidth,
                   _borderRightWidth,
                   _borderBottomWidth,
                   _borderStartWidth,
                   _borderEndWidth,
                   _borderWidth];

   [s appendFormat:@""
                   "width              : %.2f %s\n"
                   "height             : %.2f %s\n"
                   "minWidth           : %.2f %s\n"
                   "minHeight          : %.2f %s\n"
                   "maxWidth           : %.2f %s\n"
                   "maxHeight          : %.2f %s\n",
                      _width.value, YGUnitToString( _width.unit),
                      _height.value, YGUnitToString( _height.unit),
                      _minWidth.value, YGUnitToString( _minWidth.unit),
                      _minHeight.value, YGUnitToString( _minHeight.unit),
                      _maxWidth.value, YGUnitToString( _maxWidth.unit),
                      _maxHeight.value, YGUnitToString( _maxHeight.unit)];

   [s appendFormat:@""
                   "aspectRatio        : %.2f\n", _aspectRatio];
   return( s);
}

@end
