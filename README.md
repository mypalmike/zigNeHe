# zigNeHe

The ancient NeHe OpenGL tutorials, ported to the Zig language.

Based largely on the C-based glfw 2 NeHe tutorials by Joseph Redmon (pjreddie@) https://github.com/pjreddie/NeHe-Tutorials-Using-GLFW with updates for glfw 3. Other useful base material from https://github.com/andrewrk/tetris.

The build.zig files are rather specific to building on my MacOS laptop. If you do not have my particular laptop, you may need to modify things to get it building for you.


## Requirements

Tested with Zig version 0.5.0.

You will need to install glfw (see https://www.glfw.org/). On MacOS:

```
$ brew install glfw
```


## Building and running

In each LessonXX directory, you can build and run the given tutorial by running:

```
$ zig build run
```


## Screenshot

From Lesson 6:

![Screenshot](zigNeHe.png)


## TODO

* Should do error-handling in a more Zig-like way, and actually deal with gl initialization failing.
* All the lessons.
