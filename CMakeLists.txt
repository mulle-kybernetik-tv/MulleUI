cmake_minimum_required( VERSION 3.1)

project( MulleUI C)


### mulle-sde environment

# add cmake module paths to search path
list( INSERT CMAKE_MODULE_PATH 0 "${PROJECT_SOURCE_DIR}/cmake/share")
list( INSERT CMAKE_MODULE_PATH 0 "${PROJECT_SOURCE_DIR}/cmake")

include( Environment)

include( Files)
include( Dependencies)

### Executables

set( MEMO_SOURCES ${SOURCES})

foreach( MAIN_SOURCE ${MAIN_SOURCES})
   # get rid off src/main- prefix and .m suffix
   #             offset 9  length -9 - 2
   string( LENGTH "${MAIN_SOURCE}" MAIN_SOURCE_LENGTH)
   math( EXPR MAIN_SOURCE_LENGTH "${MAIN_SOURCE_LENGTH} - 11")
   string( SUBSTRING "${MAIN_SOURCE}" 9 ${MAIN_SOURCE_LENGTH} EXECUTABLE_NAME)
   
   set( SOURCES ${MEMO_SOURCES} ${MAIN_SOURCE})
   include( Executable)
   include( InstallExecutable)
   include( FinalOutput OPTIONAL)
# only for Executable
   include( Motd OPTIONAL)
endforeach()

