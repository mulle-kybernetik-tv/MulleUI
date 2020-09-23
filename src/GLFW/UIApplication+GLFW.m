//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#ifdef __has_include
# if __has_include( "UIApplication.h")
#  import "UIApplication.h"
# endif
#endif


#import "import-private.h"



@implementation UIApplication ( GLFW)

- (void) os_terminate
{
	glfwTerminate();
}

@end
