# MulleUI

🌀 UIKit for mulle-objc - Desktop and Mobile

Work in progress. Needs unpublished mulle-objc 0.17.


## Harfbuzz

Needs ugly hacks for harfbuzz/freetype.

Both seem to have a circular dependency on each other. harfbuzz does not
necessarily provide a needed hb-ft.h header. freetype expects `<hb.h>` in the 
`include` root not in `<harfbuzz/hb.h>` where it resides. It's a complete
clusterfuck.

What I do for development is gross:

```
sudo apt-get install libharfbuzz-dev    # has hb-ft.h
cd /usr/local/include
for i in /usr/include/harfbuzz/*.h
do   
   sudo ln -s "$i"
done
```
