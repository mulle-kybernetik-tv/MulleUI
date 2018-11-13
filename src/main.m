#import "import-private.h"

//	stolen from catgl ©2015,2018 Yuichiro Nakada
#define X  100
#define Y  50
#define W  200
#define H  100

#include "tiger-svg.inc"

#if 0
static char   svginput[] = \
"<svg version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\">\n"
"   <rect x=\"100\" y=\"50\" width=\"200\" height=\"100\" stroke=\"#c04949\" stroke-linejoin=\"round\" stroke-width=\"5.265\"/>\n"
"</svg>\n"
"\n"
;
#endif



struct demo_context
{
	GLFWwindow         *window;
	struct NVGcontext  *vg;	
	double  				 mouse_x, mouse_y;
	NSVGimage          *image;
	int                did_render;
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


static NVGcolor getNVGColor(uint32_t color) 
{
	return nvgRGBA(
		(color >> 0) & 0xff,
		(color >> 8) & 0xff,
		(color >> 16) & 0xff,
		(color >> 24) & 0xff);
}


static void   render_frame( struct demo_context *ctxt)
{
	NSVGshape  *shape;
	NSVGpath   *path;
	int        i;
	float      *p;
	int        shape_no;
	int        path_no;
	static int  frame_no;

   nvgTranslate( ctxt->vg, X, Y);
	shape_no = 0;
	for( shape = ctxt->image->shapes; shape != NULL; shape = shape->next) 
	{
		shape_no++;
	   if( ! (shape->flags & NSVG_FLAGS_VISIBLE))
   	   continue;


	   nvgFillColor( ctxt->vg, getNVGColor( shape->fill.color));
	   nvgStrokeColor( ctxt->vg, getNVGColor( shape->stroke.color));
	   nvgStrokeWidth( ctxt->vg, shape->strokeWidth);

		path_no = 0;

	   for( path = shape->paths; path != NULL; path = path->next) 
	   {
			path_no++;

			nvgBeginPath( ctxt->vg);
			printf( "%d/%d: %.1f,%1.f\n", shape_no, path_no, path->pts[0], path->pts[1]);

			nvgMoveTo( ctxt->vg, path->pts[0], path->pts[1]);
			for (i = 0; i < path->npts-1; i += 3) 
			{
			   p = &path->pts[i*2];
			   nvgBezierTo( ctxt->vg, p[2], p[3], p[4], p[5], p[6], p[7]);
			}

			if( path->closed)
			   nvgLineTo( ctxt->vg, path->pts[0], path->pts[1]);

			if( shape->fill.type)
			   nvgFill( ctxt->vg);

			if( shape->stroke.type)
			   nvgStroke( ctxt->vg);
	   }
	}



//	
//	nvgBeginPath( ctxt->vg);
//	nvgRect( ctxt->vg, X, Y, W, H);
//	nvgFillColor( ctxt->vg, nvgRGBA(255,192,0,255));
//	nvgFill( ctxt->vg);
}


int main()
{
	struct demo_context   ctxt;

	memset( &ctxt, 0, sizeof( ctxt));

	if( ! glfwInit()) 
		return -1;

	glfwWindowHint( GLFW_CONTEXT_VERSION_MAJOR, 2);
	glfwWindowHint( GLFW_CONTEXT_VERSION_MINOR, 0);
	glfwWindowHint( GLFW_RESIZABLE, GL_FALSE);

	ctxt.window = glfwCreateWindow( 640, 400, "Demo", 0, 0);
	if( ! ctxt.window) 
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

	ctxt.image = nsvgParse( svginput, "px", 96.0);

	#define PAINT_FRAMES  1 //  60 * 5

	while( ! glfwWindowShouldClose(ctxt.window)) 
	{
		if( ctxt.did_render < PAINT_FRAMES)
		{
			// nvgGlobalCompositeOperation( ctxt->vg, NVG_ATOP);
			glClear( GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT);

			nvgBeginFrame( ctxt.vg, 640, 400, 640.0 / 400.0);
			{
				render_frame( &ctxt);
				ctxt.did_render++;
			}
			nvgEndFrame( ctxt.vg);
			glfwSwapBuffers(ctxt.window);
		}
		else
			if( ctxt.did_render == PAINT_FRAMES)
			{
				printf( "finished\n");
				ctxt.did_render++;
			}

		glfwWaitEventsTimeout( 1.0 / 200);
		// glfwPollEvents();
	}

	nsvgDelete( ctxt.image);	
	nvgDeleteGLES2(ctxt.vg);

	glfwTerminate();
}

