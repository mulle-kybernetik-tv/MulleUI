#import "import-private.h"

#import "UIWindow.h"
#import "CGContext.h"
#import "UIEvent.h"
#import "UIView+UIEvent.h"


@implementation UIWindow

static void   mouseButtonCallback( GLFWwindow* window, 
											  int button, 
											  int action, 
											  int mods)
{
	UIWindow   *self;
   UIEvent    *event;
   uint64_t   bit;   

	self  = glfwGetWindowUserPointer( window);

   bit = 1 << button;
   self->_mouseButtonStates &= ~bit;
   if( action == GLFW_PRESS)
      self->_mouseButtonStates |= bit;
   self->_modifiers = mods;

   if( self->_discardEvents)
      return;
   
   event = [[UIMouseButtonEvent alloc] initWithMousePosition:self->_mousePosition
                                                      button:button
                                                      action:action
                                                   modifiers:mods];
   [self handleEvent:event];
   [event release];   
}

static void   mouseMoveCallback( GLFWwindow* window, 
										   double xpos, 
										   double ypos)
{
	UIWindow   *self;
   UIEvent    *event;

	self = glfwGetWindowUserPointer( window);

	self->_mousePosition.x = xpos;
	self->_mousePosition.y = ypos;
   if( self->_discardEvents)
      return;

   event = [[UIMouseMotionEvent alloc] initWithMousePosition:self->_mousePosition];
   [self handleEvent:event];
   [event release];
}


static void   keyCallback( GLFWwindow* window, 
									int key, 
									int scancode, 
									int action, 
									int mods)
{
	UIWindow   *self;
   UIEvent    *event;

	self = glfwGetWindowUserPointer( window);
   self->_modifiers = mods;
   if( self->_discardEvents)
      return;

   event = [[UIKeyboardEvent alloc] initWithMousePosition:self->_mousePosition
                                                      key:key
                                                 scanCode:scancode
                                                   action:action
                                                modifiers:mods];
   [self handleEvent:event];
   [event release];   
}


+ (void) initialize
{
   if( ! glfwInit())
   {
      fprintf( stderr, "Couldn't get GLFW initialized\n");
      abort(); 
   }
}


- (id) initWithFrame:(CGRect) frame
{
   glfwWindowHint( GLFW_CONTEXT_VERSION_MAJOR, 2);
	glfwWindowHint( GLFW_CONTEXT_VERSION_MINOR, 0);
	glfwWindowHint( GLFW_RESIZABLE, GL_FALSE);

	_window = glfwCreateWindow( frame.size.width, 
                               frame.size.height, 
                               "Demo", 
                               0, 
                               0);
	if( ! _window) 
	{
      fprintf( stderr, "glfwCreateWindow failed us\n");
      [self release];
      return( nil);
//		glfwTerminate();
//		return( -1);
	}

   // TODO: query glfw for actual frame
   _frame         = frame;
   _mousePosition = CGPointMake( -1.0, -1.0);

	glfwMakeContextCurrent( _window);
	glfwSetWindowUserPointer( _window, self);

	glfwSetMouseButtonCallback( _window, mouseButtonCallback);
	glfwSetCursorPosCallback( _window, mouseMoveCallback);
	glfwSetKeyCallback( _window, keyCallback);

   return( self);
}

- (void) dealloc
{
   // delete window
   [super dealloc];
}


- (void) addLayer:(CALayer *) layer
{
   abort();
}


- (void) renderLoopWithContext:(CGContext *) context
{
	#define PAINT_FRAMES  1 //  60 * 5

	while( ! glfwWindowShouldClose( _window)) 
	{
		if( _didRender < PAINT_FRAMES)
		{
			// nvgGlobalCompositeOperation( ctxt->vg, NVG_ATOP);
			glClear( GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT);

         [context startRenderToFrame:_frame];

         [self renderWithContext:context];

         [context endRender];

			glfwSwapBuffers( _window);
         _didRender++;           
		}
		else
			if( _didRender == PAINT_FRAMES)
			{
				printf( "finished\n");
				_didRender++;
			}

      [self waitForEvents];
	}
}

- (CGRect) frame
{
   return( _frame);
}


- (CGRect) bounds
{
   return( CGRectMake( 0.0, 0.0, _frame.size.width, _frame.size.height));
}


- (void) waitForEvents
{
   glfwWaitEventsTimeout( 1.0 / 200);
		// glfwPollEvents();   
}


- (void) discardPendingEvents
{
   BOOL   old;

   old = _discardEvents;
   _discardEvents = YES;
   {
      glfwPollEvents();
   }
   _discardEvents = old;
}


- (void) requestClose
{
   glfwSetWindowShouldClose( _window, GL_TRUE);
}


+ (void) sendEmptyEvent
{
   glfwPostEmptyEvent();
}

@end

