cmake_minimum_required( VERSION 3.1)

project( MulleUI C)


### mulle-sde environment

# add cmake module paths to search path
list( INSERT CMAKE_MODULE_PATH 0 "${PROJECT_SOURCE_DIR}/cmake/share")
list( INSERT CMAKE_MODULE_PATH 0 "${PROJECT_SOURCE_DIR}/cmake/reflect")
list( INSERT CMAKE_MODULE_PATH 0 "${PROJECT_SOURCE_DIR}/cmake/reflect")
list( INSERT CMAKE_MODULE_PATH 0 "${PROJECT_SOURCE_DIR}/cmake")

include( Environment)

include( Files)
include( Dependencies)

### Executables

add_library( MulleUI OBJECT ${SOURCES})

# Overwrite rule generated MAIN_SOURCES, because we don't want all the 
# demos built all the time

set( MAIN_SOURCES
#src/main-animate-circles.m
#src/main-buttons.m
#src/main-calculator.m
#src/main-collectionview.m
#src/main-draw.m
#src/main-imageview.m
#src/main-jspiechart.m
#src/main-layer.m
#src/main-many-rectangles.m
#src/main-path.m
#src/main-remove-from-area.m
#src/main-rowcolumn.m
#src/main-scrollview.m
#src/main-slider.m
#src/main-springs-and-struts.m
#src/main-stackview.m
#src/main-svg.m
#src/main-textfield.m
src/main-textstorage.m
src/main-textview.m
#src/main-viewconversion.m
)

foreach( MAIN_SOURCE ${MAIN_SOURCES})
   # get rid off src/main- prefix and .m suffix
   #             offset 9  length -9 - 2
   string( LENGTH "${MAIN_SOURCE}" MAIN_SOURCE_LENGTH)
   math( EXPR MAIN_SOURCE_LENGTH "${MAIN_SOURCE_LENGTH} - 11")
   string( SUBSTRING "${MAIN_SOURCE}" 9 ${MAIN_SOURCE_LENGTH} EXECUTABLE_NAME)
   
   set( SOURCES ${MAIN_SOURCE})
   set( OTHER_EXECUTABLE_OBJECT_FILES $<TARGET_OBJECTS:MulleUI>)
  
   include( Executable)
   include( InstallExecutable)
   include( FinalOutput OPTIONAL)
# only for Executable
   include( Motd OPTIONAL)
endforeach()

