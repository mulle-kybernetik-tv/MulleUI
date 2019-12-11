#import "UIViewController.h"


@implementation UIViewController

- (UIView *) view
{
   if( ! _view)
   {
      [self loadView];
      if( _view)  // maybe this must happen ?
         [self viewDidLoad];
   }
   return( _view);
}

- (void) loadView
{
}


- (void) loadViewIfNeeded
{
   [self view];
}


- (void) viewDidLoad
{
}


- (BOOL) isViewLoaded
{
   return( _view != nil);
}


- (UIView *) viewIfLoaded
{
   return( _view);
}

- (void) viewWillAppear:(BOOL) animated
{
}


@end
