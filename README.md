Dynamic Wavefront Objects
===

![PreviewImage](https://github.com/GuntisTreulands/dwo/blob/master/example.gif?raw=true)


Demo:

 - Xcode 5.0;
 - ARC;
 - OpenGL ES 1;
 - Binary Wavefront object file loader;
 - OpenGL view with functionality: zoom / pan / rotate / swipe to rotate;

wth.pl

 - Can convert wavefront object .obj to binary files (contains already parsed vertices, normals and texture coordinates to be loaded in OpenGL); 
 
More information will be available here: http://gtreulands.blogspot.com/


wth.pl usage instructions
===

For Mac:
Open terminal, cd /to/folder/where/is/located/wth.pl/and/Your/.obj/file

Then type ./wth.pl file123.obj

and it will generate a folder file123Data, which will contain up to four files:
 - file123Header.b
 - file123PartNormals.b
 - file123PartTextureCoords.b
 - file123PartVerts.b

Latter 3 files contains binary data, but Header file contains face count and center coordinates. Check out demo project to see how they are used!

BSD license
===

	Copyright (c) 2012 Guntis Treulands.
	All rights reserved.

	Redistribution and use in source and binary forms are permitted
	provided that the above copyright notice and this paragraph are
	duplicated in all such forms and that any documentation,
	advertising materials, and other materials related to such
	distribution and use acknowledge that the software was developed
	by Guntis Treulands.  The name of the
	University may not be used to endorse or promote products derived
	from this software without specific prior written permission.
	THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
	IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
	

P.S. 
 - I don't own Objects that are used in application - they were downloaded as free .obj files from http://www.top3dmodels.com/;
 - wth.pl originated from this place: https://github.com/HBehrens/obj2opengl;
 - This project OpenGL stuff base was taken from: http://iphonedevelopment.blogspot.com/2008/12/start-of-wavefront-obj-file-loader.html.