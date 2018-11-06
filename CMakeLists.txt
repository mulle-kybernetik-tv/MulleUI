cmake_minimum_required( VERSION 3.1)

project( MulleGLExample C)


### mulle-sde environment

# add cmake module paths to search path
list( INSERT CMAKE_MODULE_PATH 0 "${PROJECT_SOURCE_DIR}/cmake/share")
list( INSERT CMAKE_MODULE_PATH 0 "${PROJECT_SOURCE_DIR}/cmake")

include( Environment)


### Files

include( PreFiles OPTIONAL)

#
# Include all .cmake files in ./cmake
#
file( GLOB LOCAL_CMAKE_INCLUDES
   "cmake/[A-Za-z0-9]*.cmake"
)

foreach( FILE ${LOCAL_CMAKE_INCLUDES} )
   include( "${FILE}")
endforeach()

include_directories( ${INCLUDE_DIRS})

include( PostFiles OPTIONAL)


set( PROJECT_FILES
   ${PROJECT_FILES}
   ${SOURCES}
   ${PUBLIC_HEADERS}
   ${PRIVATE_HEADERS}
   ${CMAKE_EDITABLE_FILES}
)

### Executable

include( PreExecutable OPTIONAL)

add_executable( MulleGLExample
   ${PROJECT_FILES}
)

# useful for mulle-c, but can be commented out
set_property( TARGET MulleGLExample PROPERTY CXX_STANDARD 11)


include( Executable OPTIONAL)

if( NOT EXECUTABLE_LIBRARY_LIST)
   set( EXECUTABLE_LIBRARY_LIST
      ${DEPENDENCY_LIBRARIES}
      ${OPTIONAL_DEPENDENCY_LIBRARIES}
      ${OS_SPECIFIC_LIBRARIES}
   )
endif()


target_link_libraries( MulleGLExample
   ${EXECUTABLE_LIBRARY_LIST}
)



include( PostExecutable OPTIONAL)


### Install

include( PreInstall OPTIONAL)

install( TARGETS MulleGLExample DESTINATION "bin")

include( PostInstall OPTIONAL)

# only for Executable

include( Motd OPTIONAL)
