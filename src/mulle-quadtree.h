// MulleQuadtree is very loosely based on the MIT Licensed:
// Kvad - a C99 quadtree implementation
// http://github.com/appscape/kvad

#ifndef mulle_quadtree_h__
#define mulle_quadtree_h__

#import "import.h" // TODO: just get NSInteger from MulleObjC minimal via include

#include "CGGeometry.h"
#include <stdio.h>


/** Opaque struct representing the quadtree. */
struct mulle_quadtree;

typedef void (*mulle_quadtree_callback)( CGRect rect, void* payload, void* context);

/**
 Creates the quadtree. Note that you must manually release the tree using 
 mulle_quadtree_release().
 
 Operations on the quadtree are not thread-safe.

 @param rect
        The bounding box. Origin can be negative.
 @param max_levels
        Maximum number of levels. If maximum level is reached, the nodes are not split anymore 
        and points are added to the node at the last level, ignoring max_points_per_node.
 @param max_points_per_node
        Maximum number of points to store in a single node. After this many points are added to
        a single node, it is split into into 4 subnodes/quadrants.
 @return Pointer to the quadtree object if successful, otherwise NULL
 */
struct mulle_quadtree* mulle_quadtree_create( CGRect rect,
                                              NSUInteger max_levels,
                                              NSUInteger max_points_per_node,
                                              struct mulle_allocator *allocator);

/** Releases the quadtree, freeing up memory. */
void mulle_quadtree_release( struct mulle_quadtree * tree);

/** Inserts a point and an associated payload into the quadtree. 
    You are responsible for making sure that payload reference remains valid 
    during the tree lifecycle.
    No check for duplicates is performed.
*/
void   mulle_quadtree_insert( struct mulle_quadtree* tree, 
                              CGRect rect, 
                              void *payload);

/** Change payload of a point with the matching coordinates and payload from the quadtree.
    Point is identified by coordinates and the payload. This is different to 
    mulle_quadtree_remove_payload
    @return Number of points changed.
 */
NSUInteger   mulle_quadtree_change_payload( struct mulle_quadtree* tree, 
                                            CGRect rect, 
                                            void *payload,
                                            void *newpayload);

/** Removes a point with the matching coordinates and payload from the quadtree.
    Point is identified the payload, coordinates are just used to speed up the lookup of the point
    to be removed.
    @return Number of rectangles removed.
 */
NSUInteger mulle_quadtree_remove_payload( struct mulle_quadtree* tree, 
                                          CGRect rect, 
                                          void* payload);

/** Searches for a point inside the rectangles. Calls supplied callback for 
    every matched rectangle.
    @return Number of rectangles found.
 */
NSUInteger   mulle_quadtree_find_point( struct mulle_quadtree* tree, 
                                        CGPoint point,
                                        mulle_quadtree_callback callback, 
                                        void *context);

/** Searches for a rect inside the rectangles. Calls supplied callback for 
    every rectangle that intersects .
    @return Number of rectangles found.
 */
NSUInteger   mulle_quadtree_find_intersecting_rect( struct mulle_quadtree* tree, 
                                                    CGRect rect,
                                                    mulle_quadtree_callback callback, 
                                                    void *context);

/** Visits all rectangles in the tree.
    @return Total number of rectangles currently stored in the tree.
 */
NSUInteger mulle_quadtree_walk( struct mulle_quadtree* tree, 
                                mulle_quadtree_callback callback, 
                                void* context);



/*
 * dump tree structure
 */
void   mulle_quadtree_dump( struct mulle_quadtree *tree, FILE *fp); 


#endif
