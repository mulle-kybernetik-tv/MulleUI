#import "import-private.h"

#import "MulleSVGImage.h"
#import "MulleSVGLayer.h"
#import "MulleBitmapImage.h"
#import "MulleBitmapLayer.h"


//	stolen from catgl ©2015,2018 Yuichiro Nakada
#define W  200
#define H  100

#include "tiger-svg.inc"
#include "sealie-bitmap.inc"

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
	int                did_render;
};


static void   mouseButtonCallback( GLFWwindow* window, 
											  int button, 
											  int action, 
											  int mods)
{
	struct demo_context   *ctxt;

	ctxt = glfwGetWindowUserPointer( window);
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


int main()
{
   MulleSVGLayer      *layer;
   MulleSVGLayer      *layer2;
   MulleBitmapLayer   *layer3;
   MulleSVGImage      *image;
   MulleBitmapImage   *bitmapImage;
   CGRect             frame;
   CGRect             bounds;

	struct demo_context   ctxt;

	memset( &ctxt, 0, sizeof( ctxt));

   image = [[[MulleSVGImage alloc] initWithBytes:svginput
                                          length:strlen( svginput) + 1] autorelease];
   fprintf( stderr, "image: %p\n", image);

   layer = [[[MulleSVGLayer alloc] initWithSVGImage:image] autorelease];
   fprintf( stderr, "layer: %p\n", layer);

   layer2 = [[[MulleSVGLayer alloc] initWithSVGImage:image] autorelease];
   fprintf( stderr, "layer: %p\n", layer2);

   // layer = [[[CALayer alloc] init] autorelease];

   frame.origin       = CGPointMake( 0.0, 0.0);
   frame.size.width   = 320;
   frame.size.height  = 200;
   [layer setFrame:frame];
 //  [layer setBounds:CGRectMake( 0.0, 0.0, 200, 30)];
   [layer setBackgroundColor:getNVGColor( 0xD0D0E0FF)];
   [layer setBorderColor:getNVGColor( 0x80FF30FF)];
   [layer setBorderWidth:32.0f];
   [layer setCornerRadius:16.0f];

   frame.origin = CGPointMake( 320, 200);
   [layer2 setFrame:frame];

   bounds = [layer2 bounds];
   bounds.origin.x = -bounds.size.width / 2.0;
   [layer2 setBounds:bounds];

   [layer2 setBackgroundColor:getNVGColor( 0x402060FF)];

   bitmapImage = [[[MulleBitmapImage alloc] initWithBytes:(void *) sealie_bitmap
                                               bitmapSize:sealie_bitmap_size]
                                                  autorelease];
   fprintf( stderr, "image: %p\n", bitmapImage);

   layer3 = [[[MulleBitmapLayer alloc] initWithBitmapImage:bitmapImage] autorelease];
   frame.origin       = CGPointMake( 320.0, 0.0);
   frame.size.width   = 320;
   frame.size.height  = 200;
   [layer3 setFrame:frame];
   fprintf( stderr, "layer: %p\n", layer3);

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

	glfwMakeContextCurrent( ctxt.window);
	glfwSetWindowUserPointer( ctxt.window, &ctxt);

	glfwSetMouseButtonCallback(ctxt.window, mouseButtonCallback);
	glfwSetCursorPosCallback(ctxt.window, mouseMoveCallback);
	glfwSetKeyCallback(ctxt.window, keyCallback);

	#define PAINT_FRAMES  1 //  60 * 5

	ctxt.vg      = nvgCreateGLES2( NVG_ANTIALIAS | NVG_STENCIL_STROKES);
	ctxt.mouse_x = -1;
	ctxt.mouse_y = -1;

	while( ! glfwWindowShouldClose(ctxt.window)) 
	{
		if( ctxt.did_render < PAINT_FRAMES)
		{
			// nvgGlobalCompositeOperation( ctxt->vg, NVG_ATOP);
			glClear( GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT);

			nvgBeginFrame( ctxt.vg, 640, 400, 640.0 / 400.0);
			{
            [layer drawInContext:ctxt.vg];
            nvgResetTransform( ctxt.vg);
            [layer2 drawInContext:ctxt.vg];
            nvgResetTransform( ctxt.vg);
            [layer3 drawInContext:ctxt.vg];
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

	nvgDeleteGLES2(ctxt.vg);

	glfwTerminate();
}

