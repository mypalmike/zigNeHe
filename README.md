# zigNeHe

The ancient NeHe OpenGL tutorials.

Based largely on the glfw 2 versions by Joseph Redmon (pjreddie@) https://github.com/pjreddie/NeHe-Tutorials-Using-GLFW with updates for glfw 3.

The build.zig files are rather specific to building on my MacOS laptop. If you do not have my particular laptop, you may need to modify things to get it building for you.

You will need to install and build against glfw (see https://www.glfw.org/). On MacOS, you can brew install it.

## TODO

* Should do error-handling in a more Zig-like way, and actually deal with gl initialization failing.
* All the lessons.
