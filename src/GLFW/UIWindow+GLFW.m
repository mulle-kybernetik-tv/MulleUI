//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#ifdef __has_include
# if __has_include( "UIWindow.h")
#  import "UIWindow.h"
# endif
#endif

#import "import-private.h"

#import "UIWindow+UIEvent.h"


@implementation UIWindow ( GLFW)

static void   keyCallback( GLFWwindow* window,
                           int key,
                           int scancode,
                           int action,
                           int mods)
{
   UIWindow   *self;

   self = glfwGetWindowUserPointer( window);
   [self _keyCallback:key
             scancode:scancode
               action:action
            modifiers:mods];
}


void   charCallback(GLFWwindow* window, unsigned int codepoint)
{
   UIWindow   *self;

   self = glfwGetWindowUserPointer( window);
   [self _charCallback:codepoint];
}


static void   mouseButtonCallback( GLFWwindow* window,
                                   int button,
                                   int action,
                                   int mods)
{
   UIWindow   *self;

   self  = glfwGetWindowUserPointer( window);
   [self _mouseButtonCallback:button 
                       action:action           
                    modifiers:mods];
}


static void   mouseMoveCallback( GLFWwindow* window,
                                 double xpos,
                                 double ypos)
{
   UIWindow   *self;

   self = glfwGetWindowUserPointer( window);
   [self _mouseMoveCallback:CGPointMake( xpos, ypos)];
}


static void   mouseScrollCallback( GLFWwindow *window,
                                   double xoffset,
                                   double yoffset)
{
   UIWindow   *self;

   self  = glfwGetWindowUserPointer( window);
   [self _mouseScrollCallback:CGPointMake( xoffset, yoffset)];
}


static void   windowMoveCallback( GLFWwindow* window, int xpos, int ypos)
{
   UIWindow   *self;

   self = glfwGetWindowUserPointer( window);
   [self _windowMoveCallback:CGPointMake( xpos, ypos)];
}


static void   windowRefreshCallback( GLFWwindow* window)
{
   UIWindow   *self;

   self = glfwGetWindowUserPointer( window);
   [self _windowRefreshCallback];
}


// framebufferResize is more interesting though
static void   windowResizeCallback( GLFWwindow* window, int width, int height)
{
   UIWindow   *self;

   self = glfwGetWindowUserPointer( window);
   [self _windowResizeCallback:CGSizeMake( width, height)];
}


static void   framebufferResizeCallback( GLFWwindow* window, int width, int height)
{
   UIWindow   *self;
   CGRect     frame;

   self = glfwGetWindowUserPointer( window);
   [self _framebufferResizeCallback:CGSizeMake( width, height)];
}


- (void) os_initEvents
{
   assert( _window);

   // input device events
   glfwSetMouseButtonCallback( _window, mouseButtonCallback);
   glfwSetCursorPosCallback( _window, mouseMoveCallback);
   glfwSetKeyCallback( _window, keyCallback);
   glfwSetCharCallback( _window, charCallback);
   glfwSetScrollCallback( _window, mouseScrollCallback);

   // window events
   glfwSetWindowSizeCallback( _window, windowResizeCallback);
   glfwSetWindowPosCallback( _window, windowMoveCallback);
   glfwSetFramebufferSizeCallback( _window, framebufferResizeCallback);
   glfwSetWindowRefreshCallback( _window, windowRefreshCallback);   
}


static void   error_callback(int code, const char* description)
{
   fprintf( stderr, "GLFW Error #%d: \"%s\"\n", code, description);
}


+ (void) os_initialize
{
   if( ! glfwInit())
   {
      fprintf( stderr, "Couldn't get GLFW initialized\n");
      abort();
   }
   // calling glSwapInterval here is too early
   glfwSetErrorCallback( error_callback);
}


+ (CGFloat) os_primaryMonitorPPI
{
   GLFWmonitor      *monitor;
   GLFWvidmode      *mode;
   int              h;
   CGFloat          ppi;

   //
   monitor = glfwGetPrimaryMonitor();
   if( ! monitor)
      return( 0.0);

   h = 0; // for valgrind
   glfwGetMonitorPhysicalSize( monitor, NULL, &h);
   if( ! h)
       return( 0.0);

   mode = (GLFWvidmode *) glfwGetVideoMode( monitor);
   if( ! mode)
       return( 0.0);

   // need to convert h in mm to inches
   ppi = mode->height / (h * 0.03937007874);
   return( ppi);
}


- (void) os_syncFrameWithWindow
{
   int   xpos;
   int   ypos;
   int   width;
   int   height;
   
   glfwGetWindowPos( _window, &xpos, &ypos);
   glfwGetWindowSize( _window, &width, &height);  // just to be sure...

   _frame.origin = CGPointMake( xpos, ypos);
   _frame.size   = CGSizeMake( width, height);
}


- (void *) os_createWindowWithFrame:(CGRect) frame
{
   void   *window;

#if MULLE_UI_GLVERSION == MULLE_GLES2
   glfwWindowHint( GLFW_CONTEXT_VERSION_MAJOR, 2);
	glfwWindowHint( GLFW_CONTEXT_VERSION_MINOR, 0);
#endif
#if MULLE_UI_GLVERSION == MULLE_GLES3
   glfwWindowHint( GLFW_CONTEXT_VERSION_MAJOR, 3);
	glfwWindowHint( GLFW_CONTEXT_VERSION_MINOR, 2);
   glfwWindowHint( GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
#endif
#if MULLE_UI_GLVERSION == MULLE_GL
   glfwWindowHint( GLFW_CONTEXT_VERSION_MAJOR, 3);
	glfwWindowHint( GLFW_CONTEXT_VERSION_MINOR, 0);
   glfwWindowHint( GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
#endif

	glfwWindowHint( GLFW_RESIZABLE, GL_TRUE);

   // not super sure about this, but lets try to avoid "old" OpenGL
   // calls. alas, we are doing OpenGLES 2.0 minimum, so I don't know
   // if this is useful.

   window = glfwCreateWindow( (int) frame.size.width,
                              (int) frame.size.height,
                              "Demo",
                              0,
                              0);
   if( ! window)
   {
      fprintf( stderr, "glfwCreateWindow failed us\n");
      return( NULL);
   }

   glfwMakeContextCurrent( window);
   glfwSetWindowUserPointer( window, self);
  
   return( window);
}


- (CGSize) os_windowSize
{
   int   winWidth;
   int   winHeight;

   glfwGetWindowSize( _window, &winWidth, &winHeight);
   return( CGSizeMake( winWidth, winHeight));
}


- (CGSize) os_framebufferSize
{
   int   fbWidth;
   int   fbHeight;

   glfwGetFramebufferSize( _window, &fbWidth, &fbHeight);
   return( CGSizeMake( fbWidth, fbHeight));
}


- (void) os_swapBuffers
{
   glfwSwapBuffers( _window);
}


- (void) os_setSwapInterval:(NSUInteger) value
{
   glfwSwapInterval( (int) value);  // need for smooth pointer/control sync
}


- (CGFloat) os_primaryMonitorRefreshRate
{
   GLFWmonitor   *monitor;
   GLFWvidmode   *mode;

   monitor = glfwGetPrimaryMonitor();
   mode    = (GLFWvidmode *) glfwGetVideoMode( monitor);

   return( mode->refreshRate);
}


- (void) os_requestClose
{
   glfwSetWindowShouldClose( _window, GL_TRUE);
}


- (BOOL) os_windowShouldClose
{
   return( glfwWindowShouldClose( _window) ? YES : NO);   
}


- (void) os_waitEventsTimeout:(CGFloat) seconds
{
   glfwWaitEventsTimeout( seconds);
}


- (void) os_pollEvents
{
	glfwPollEvents();
}



+ (void) os_sendEmptyEvent
{
   glfwPostEmptyEvent();
}


//
// OS Pasteboard
// prefix with os ?
- (char *) pasteboardCString
{
   return( (char *) glfwGetClipboardString( _window));	
}


- (void) setPasteboardCString:(char *) s
{
   glfwSetClipboardString( _window, s ? s : "");
}

@end
