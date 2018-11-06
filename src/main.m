#import "import-private.h"

//	stolen from catgl ©2015,2018 Yuichiro Nakada
#define X  100
#define Y  50
#define W  200
#define H  50

struct demo_context
{
	GLFWwindow         *window;
	struct NVGcontext  *vg;	
	double  				 mouse_x, mouse_y;
};


static void   mouseButtonCallback( GLFWwindow* window, 
											  int button, 
											  int action, 
											  int mods)
{
	struct demo_context   *ctxt;

	ctxt = glfwGetWindowUserPointer( window);
	if( ctxt->mouse_x >= X &&
		 ctxt->mouse_y >= Y &&
		 ctxt->mouse_x < X + W &&
		 ctxt->mouse_y < Y + H)
	{
		glfwSetWindowShouldClose( window, GL_TRUE);
	}
}


static void   mouseMoveCallback( GLFWwindow* window, 
										   double xpos, 
										   double ypos)
{
	struct demo_context   *ctxt;

	ctxt          = glfwGetWindowUserPointer( window);
	ctxt->mouse_x = xpos;
	ctxt->mouse_y = ypos;
}


static void   keyCallback( GLFWwindow* window, 
									int key, 
									int scancode, 
									int action, 
									int mods)
{
	if( key == GLFW_KEY_ESCAPE && action == GLFW_PRESS) 
	{
		glfwSetWindowShouldClose( window, GL_TRUE);
	}
}


static void   setup_gl( void)
{
	glViewport(0, 0, 640, 400);

	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT);

	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_CULL_FACE);
	glDisable(GL_DEPTH_TEST);
}


int main()
{
	struct demo_context   ctxt;

	if( ! glfwInit()) 
		return -1;

	glfwWindowHint( GLFW_CONTEXT_VERSION_MAJOR, 2);
	glfwWindowHint( GLFW_CONTEXT_VERSION_MINOR, 0);
	glfwWindowHint( GLFW_RESIZABLE, GL_FALSE);

	ctxt.window = glfwCreateWindow( 640, 400, "Demo", 0, 0);
	if (!ctxt.window) 
	{
		glfwTerminate();
		return( -1);
	}

	glfwSetWindowUserPointer( ctxt.window, &ctxt);

	glfwMakeContextCurrent( ctxt.window);

	glfwSetMouseButtonCallback(ctxt.window, mouseButtonCallback);
	glfwSetCursorPosCallback(ctxt.window, mouseMoveCallback);
	glfwSetKeyCallback(ctxt.window, keyCallback);


	ctxt.vg      = nvgCreateGLES2( NVG_ANTIALIAS | NVG_STENCIL_STROKES);
	ctxt.mouse_x = -1;
	ctxt.mouse_y = -1;

	while( ! glfwWindowShouldClose(ctxt.window)) 
	{
		nvgBeginFrame( ctxt.vg, 640, 400, 640.0 / 400.0);
		// setup_gl();

		nvgBeginPath(ctxt.vg);
		nvgRect(ctxt.vg, X, Y, W, H);
		nvgFillColor(ctxt.vg, nvgRGBA(255,192,0,255));
		nvgFill(ctxt.vg);

		nvgEndFrame(ctxt.vg);

		glfwSwapBuffers(ctxt.window);
		glfwPollEvents();
	}

	nvgDeleteGLES2(ctxt.vg);

	glfwTerminate();
}

