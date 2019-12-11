#import "UIView.h"

#import "MulleObjectArray.h"


@interface UIView( NSArray)

- (NSArray *) subviews;

- (BOOL) isDescendantOfView:(UIView *) view;

- (void) sendSubviewToBack:(UIView *) view;
- (void) bringSubviewToFront:(UIView *) view;
- (void) removeFromSuperview;

- (void) insertSubview:(UIView *) view 
               atIndex:(NSInteger) index;
- (void) insertSubview:(UIView *) view 
          aboveSubview:(UIView *) other;   
- (void) insertSubview:(UIView *) view 
          belowSubview:(UIView *) other;
- (void) exchangeSubviewAtIndex:(NSInteger) index1 
             withSubviewAtIndex:(NSInteger) index2;

@end

