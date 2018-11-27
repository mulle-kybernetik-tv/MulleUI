#import "UIView.h"

@class UIEvent;


@interface UIButton : UIView

@property( assign) UIEvent *(*click)( UIButton *button, UIEvent *event);
@property( assign) id  target;
@property( assign) SEL action;

@end