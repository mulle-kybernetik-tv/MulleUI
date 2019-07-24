int   bmp_rgb32_write_file( char *filename,
                            void *image,                // rgba image bytes
                            unsigned int width,         // in pixels
                            unsigned int height,        // in pixels
                            int stridebytes);           // usually width * 4


int   bmp_grayscale_write_file( char *filename,
                                void *image,         // grayscale image bytes
                                unsigned int width,  // in pixels
                                unsigned int height, // in pixels
                                int stridebytes);    // usually same as width


