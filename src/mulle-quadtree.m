// Kvad - a C99 quadtree implementation
// http://github.com/appscape/kvad

#include "mulle-quadtree.h"

#include <stdlib.h>


// A linked list element storing a point and the reference to associated payload
struct _mulle_quadtree_data 
{
    CGRect                       rect;
    void                         *payload;
    struct _mulle_quadtree_data  *next;
};

struct _mulle_quadtree_node 
{
    NSUInteger                    level; // This node's level in the tree
    CGRect                        rect; // Bounding box
    struct _mulle_quadtree_node   *subnodes[4]; // 0=NW,1=NE,2=SW,3=SE quadrants
    struct _mulle_quadtree_data   *data; // Pointer to the first rect data (linked list)
    NSUInteger                    data_count; // Number of points stored in the linked list
};

struct mulle_quadtree 
{
   struct _mulle_quadtree_node  *root_node;
   struct mulle_allocator       *allocator;
   NSUInteger                   max_levels;
   NSUInteger                   max_rects_per_node;
};


static struct _mulle_quadtree_node * 
   _mulle_quadtree_node_create( CGRect rect, 
                                unsigned int level, 
                                struct mulle_allocator *allocator) 
{
    struct _mulle_quadtree_node* n;
    
    n        = mulle_allocator_calloc( allocator, 1, sizeof(struct _mulle_quadtree_node));
    n->rect  = rect;
    n->level = level;
    return n;
}


static NSUInteger 
   _mulle_quadtree_node_change_payload( struct _mulle_quadtree_node* node, 
                                        CGRect rect, 
                                        void* payload,
                                        void* newpayload) 
{
   NSUInteger                    count;
   NSUInteger                    i;
   struct _mulle_quadtree_data   *data;
   struct _mulle_quadtree_data   *prev_data;
   struct _mulle_quadtree_node   *subnode;
   
   count = 0;

   if( node->subnodes[0]) 
   {
      for( i = 0; i < 4; i++)
      {
         subnode = node->subnodes[ i];
         if( CGRectIntersectsRect( subnode->rect, rect))
            count += _mulle_quadtree_node_change_payload( subnode, rect, payload, newpayload);
      }
      return( count);
   } 

   data  = node->data;

   while( data) 
   {
      if( data->payload == payload && 
          CGRectIntersectsRect( data->rect, rect)) 
      {
          // Payload and point matches, change this entry
          count++;
          data->payload = newpayload;
      }
      data = data->next;
   }

   return count;
}

static NSUInteger 
   _mulle_quadtree_node_remove_payload( struct _mulle_quadtree_node* node, 
                                        CGRect rect, 
                                        void* payload,
                                        struct mulle_allocator *allocator) 
{
   NSUInteger                    count;
   struct _mulle_quadtree_data   *data;
   struct _mulle_quadtree_data   *prev_data;
   struct _mulle_quadtree_node   *subnode;
   NSUInteger                    i;

   count = 0;

   if( node->subnodes[0]) 
   {
      for( i = 0; i < 4; i++)
      {
         subnode = node->subnodes[ i];
         if( CGRectIntersectsRect( subnode->rect, rect))
            count += _mulle_quadtree_node_remove_payload( subnode, rect, payload, allocator);
      }
      return( count);
   } 

   data      = node->data;
   prev_data = NULL;

   while( data) 
   {
      if( data->payload == payload) 
      {
          // Payload matches, remove this entry
          count++;
          node->data_count--;
          if (prev_data) 
          {
              prev_data->next = data->next;
              mulle_allocator_free( allocator, data);
              data = prev_data->next;
          } 
          else 
          {
              node->data = data->next;
              mulle_allocator_free( allocator, data);
              data = node->data;
          }
      } 
      else
      {
          prev_data = data;
          data = data->next;
      }
   }

    return count;
}

static int  _mulle_quadtree_node_insert( struct mulle_quadtree* tree, 
                                         struct _mulle_quadtree_node* node, 
                                         CGRect rect, 
                                         void* payload);


static void  _mulle_quadtree_split_node( struct mulle_quadtree* tree, 
                                         struct _mulle_quadtree_node* node)
{
   CGSize                        subnode_rect_size;
   CGRect                        subnode_rect;
   struct _mulle_quadtree_data   *data;
   struct _mulle_quadtree_data   *next;
   struct _mulle_quadtree_node   *subnode;
   NSUInteger                    i;

   subnode_rect_size = CGSizeMake( node->rect.size.width / 2.0, 
                                   node->rect.size.height / 2.0);

   for( i = 0; i < 4; i++) 
   {
       subnode_rect = CGRectMake( node->rect.origin.x + ((i % 2 == 1) ? subnode_rect_size.width : 0),
                                  node->rect.origin.y + ((i >= 2) ? subnode_rect_size.height : 0),
                                  subnode_rect_size.width,
                                  subnode_rect_size.height);
       node->subnodes[i] = _mulle_quadtree_node_create( subnode_rect, node->level + 1, tree->allocator);
   }

   // ..and move all data from it into subnodes
   data       = node->data;
   node->data = NULL;

   while( data) 
   {
      next = data->next;

      for( i = 0; i < 4; i++)
      {
         subnode = node->subnodes[ i];
         if( CGRectIntersectsRect( data->rect, subnode->rect))
            _mulle_quadtree_node_insert( tree, subnode, data->rect, data->payload);
      } 

      // remove from our tree
      mulle_allocator_free( tree->allocator, data);
      node->data_count--;
      data = next;
   }
}

// 
// The incoming rectangle is clipped against the quadtree and every part
// is placed into the appropriate node
//
static int  _mulle_quadtree_node_insert( struct mulle_quadtree* tree, 
                                         struct _mulle_quadtree_node* node, 
                                         CGRect rect, 
                                         void  *payload) 
{
   struct _mulle_quadtree_data   *new_data; 
   struct _mulle_quadtree_data   *data;
   struct _mulle_quadtree_data   *next;
   struct _mulle_quadtree_data   *prev;
   struct mulle_allocator        *allocator;
   unsigned int                  i;
   struct _mulle_quadtree_node   *subnode;
   CGRect                        intersection;
   unsigned int                  nRects;
   int                           workDone;

   assert( tree);
   assert( node);

   workDone = 0;
   if( node->subnodes[ 0]) 
   {
      for( i = 0; i < 4; i++)
      {
         subnode      = node->subnodes[ i];
         intersection = CGRectIntersection( subnode->rect, rect);
         if( intersection.size.width <= 0.0 || intersection.size.height <= 0.0)
            continue;

         workDone |= _mulle_quadtree_node_insert( tree, subnode, intersection, payload);
      }
      return( workDone);
   }

   // only memorize the intersections that fits in our node,
   // which is analog to how subnodes get their client rects
   intersection = CGRectIntersection( rect, node->rect);
   if( intersection.size.width <= 0.0 || intersection.size.height <= 0.0)
      return( 0);

   // Leaf node, insert here by creating a new element at the head of linked list
   new_data          = mulle_allocator_malloc( tree->allocator, sizeof(struct _mulle_quadtree_data));
   new_data->rect    = intersection;
   new_data->payload = payload;
   new_data->next    = NULL;
   if( node->data) 
   {
//      assert(node->data_count > 0);
      new_data->next = node->data;
   }
   node->data = new_data;
   node->data_count++;

   // If maximum number of points reached AND below max level and not split yet: 
   // split this node
   if( node->level < tree->max_levels && 
       node->data_count > tree->max_rects_per_node && 
       ! node->subnodes[0]) 
   {
      _mulle_quadtree_split_node( tree, node);
   }
   return( 1);
}

static NSUInteger 
   _mulle_quadtree_node_find_point( struct _mulle_quadtree_node* node, 
                                    CGPoint point, 
                                    mulle_quadtree_callback callback, 
                                    void* context) 
{
   NSUInteger                   count;
   NSUInteger                   i;
   struct _mulle_quadtree_data  *data;

   count = 0;
   if( node->subnodes[ 0]) 
   {
      assert( ! node->data);

      for( i = 0; i < 4; i++) 
         if( CGRectContainsPoint( node->subnodes[i]->rect, point)) 
            count += _mulle_quadtree_node_find_point( node->subnodes[i], point, callback, context);
      return( count);
   }

   // Leaf node
   data = node->data;
   while( data) 
   {
      if( CGRectContainsPoint( data->rect, point)) 
      {
         count++;
         if (callback) 
            (*callback)( data->rect, data->payload, context);
      }
      data = data->next;
   }
   return( count);
}


static NSUInteger 
   _mulle_quadtree_node_find_intersecting_rect( struct _mulle_quadtree_node* node, 
                                                CGRect rect, 
                                                mulle_quadtree_callback callback, 
                                                void* context) 
{
   NSUInteger                   count;
   NSUInteger                   i;
   struct _mulle_quadtree_data  *data;

   count = 0;
   if( node->subnodes[ 0]) 
   {
      assert( ! node->data);

      for( i = 0; i < 4; i++) 
         if( CGRectIntersectsRect( node->subnodes[i]->rect, rect)) 
            count += _mulle_quadtree_node_find_intersecting_rect( node->subnodes[i], rect, callback, context);
      return( count);
   }

   // Leaf node
   data = node->data;
   while( data) 
   {
      if( CGRectIntersectsRect( data->rect, rect)) 
      {
         count++;
         if (callback) 
            (*callback)( data->rect, data->payload, context);
      }
      data = data->next;
   }
   return( count);
}


static NSUInteger 
   _mulle_quadtree_node_walk( struct _mulle_quadtree_node* node, 
                              mulle_quadtree_callback callback, 
                              void* context) 
{
   NSUInteger                    count;
   struct _mulle_quadtree_data   *data;
   NSUInteger                    i;

   count = 0;
   if( node->subnodes[0]) 
   {
      assert( ! node->data);

      for( i = 0; i < 4; i++) 
         count += _mulle_quadtree_node_walk( node->subnodes[ i], callback, context);
      return( count);
   } 

   data = node->data;
   while(data) 
   {
      count++;
      if (callback) 
         (*callback)( data->rect, data->payload, context);
      data = data->next;
   }
   assert( count == node->data_count);
   return( count);
}


static void 
   _mulle_quadtree_node_dump( struct _mulle_quadtree_node *node, 
                              FILE *fp, 
                              unsigned int level,
                              unsigned int quadrant) 
{
   struct _mulle_quadtree_data   *data;
   NSUInteger                    i;

   for( i = 0; i < level; i++)
      fputc( ' ', fp);
   fprintf( fp, "%u/%u: %.2f %.2f %.2f %.2f\n", 
                    level, quadrant,
                     node->rect.origin.x,
                     node->rect.origin.y,
                     node->rect.size.width,
                     node->rect.size.height);

   if( node->subnodes[0]) 
   {
      assert( ! node->data);

      for( i = 0; i < 4; i++) 
        _mulle_quadtree_node_dump( node->subnodes[ i], fp, level + 1, i);
      return;
   } 

   data = node->data;
   while(data) 
   {
      for( i = 0; i <= level; i++)
         fputc( ' ', fp);
      fprintf( fp, "[%.2f %.2f %.2f %.2f = %p]\n", 
                     data->rect.origin.x,
                     data->rect.origin.y,
                     data->rect.size.width,
                     data->rect.size.height,
                     data->payload);
      data = data->next;
   }
}


static void 
   _mulle_quadtree_node_release( struct _mulle_quadtree_node* node,
                                 struct mulle_allocator  *allocator) 
{
   struct _mulle_quadtree_data   *data;
   struct _mulle_quadtree_data   *curr;
   NSUInteger                    i;

   if( node->subnodes[0]) 
   {
     // Non-leaf node: first free subnodes..
      for( i = 0; i < 4; i++) 
         _mulle_quadtree_node_release( node->subnodes[i], allocator);
   } 

   // Leaf nodes: free data..
   data = node->data;
   while( data) 
   {
      curr = data;
      data = data->next;
      mulle_allocator_free( allocator, curr);
   }
   //..then free this node
   mulle_allocator_free( allocator, node);
}

// Public functions

struct mulle_quadtree* mulle_quadtree_create( CGRect world_rect, 
                                              NSUInteger max_levels,
                                              NSUInteger max_rects_per_node,
                                              struct mulle_allocator *allocator) 
{
   struct mulle_quadtree* t;

   assert( world_rect.size.width > 0);
   assert( world_rect.size.height > 0);
   assert( max_rects_per_node > 0);

   // Sane behaviour in case asserts are disabled
   if (max_rects_per_node == 0) 
      max_rects_per_node = 1;

   t                      = mulle_allocator_malloc( allocator, sizeof( struct mulle_quadtree));
   t->max_levels          = max_levels;
   t->max_rects_per_node = max_rects_per_node;
   t->root_node           = _mulle_quadtree_node_create( world_rect, 0, allocator);
   t->allocator           = allocator;
   return t;
}

void   mulle_quadtree_release( struct mulle_quadtree* tree) 
{
   _mulle_quadtree_node_release( tree->root_node, tree->allocator);
   mulle_allocator_free( tree->allocator, tree);
}

int   mulle_quadtree_insert( struct mulle_quadtree* tree,  
                              CGRect rect, 
                              void *payload) 
{
   return( _mulle_quadtree_node_insert( tree, tree->root_node, rect, payload));
}

NSUInteger   mulle_quadtree_remove_payload( struct mulle_quadtree* tree, 
                                            CGRect rect, 
                                            void *payload) 
{
    return _mulle_quadtree_node_remove_payload(tree->root_node, rect, payload, tree->allocator);
}


NSUInteger   mulle_quadtree_change_payload( struct mulle_quadtree* tree, 
                                            CGRect rect, 
                                            void *payload,
                                            void *newpayload) 
{
    return _mulle_quadtree_node_change_payload( tree->root_node, rect, payload, newpayload);
}


NSUInteger   mulle_quadtree_find_point( struct mulle_quadtree *tree, 
                                        CGPoint p,
                                        mulle_quadtree_callback callback, 
                                        void *context) 
{
    return _mulle_quadtree_node_find_point( tree->root_node, p, callback, context);
}


NSUInteger   mulle_quadtree_find_intersecting_rect( struct mulle_quadtree *tree, 
                                                    CGRect r,
                                                    mulle_quadtree_callback callback, 
                                                    void *context) 
{
    return _mulle_quadtree_node_find_intersecting_rect( tree->root_node, r, callback, context);
}


NSUInteger   mulle_quadtree_walk( struct mulle_quadtree *tree, 
                                  mulle_quadtree_callback callback, 
                                  void *context) 
{
   return _mulle_quadtree_node_walk( tree->root_node, callback, context);
}


void   mulle_quadtree_dump( struct mulle_quadtree *tree, FILE *fp) 
{
   _mulle_quadtree_node_dump( tree->root_node, fp, 0, 0);
}