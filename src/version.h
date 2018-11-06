#ifndef mulleg_lexample_version_h__
#define mulleg_lexample_version_h__

/*
 *  version:  major, minor, patch
 */
#define MULLEG_LEXAMPLE_VERSION  ((0 << 20) | (7 << 8) | 56)


static inline unsigned int   MulleG_LExample_get_version_major( void)
{
   return( MULLEG_LEXAMPLE_VERSION >> 20);
}


static inline unsigned int   MulleG_LExample_get_version_minor( void)
{
   return( (MULLEG_LEXAMPLE_VERSION >> 8) & 0xFFF);
}


static inline unsigned int   MulleG_LExample_get_version_patch( void)
{
   return( MULLEG_LEXAMPLE_VERSION & 0xFF);
}

#endif
