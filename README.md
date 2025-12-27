# zigNeHe

The ancient NeHe OpenGL tutorials, ported to the Zig language.

Based largely on the C-based [glfw 2 NeHe tutorials by Joseph Redmon (pjreddie@)](https://github.com/pjreddie/NeHe-Tutorials-Using-GLFW) with updates for glfw 3. Other useful base material from [andrewrk/tetris](https://github.com/andrewrk/tetris).

Currently tested on Linux (Debian 12) with Zig version 0.15.2.

Older versions were tested on MacOS and FreeBSD. Some tweaking may be needed to get the latest version running, or to build on other OSes - contributions welcome.

## Requirements

You will need to install [glfw](https://www.glfw.org/).

### MacOS

```sh
brew install glfw
```

On MacOS, you will also need to install XCode in order to get the OpenGL framework.

### Debian 11-12

```sh
apt install libglfw3-dev libglu1-mesa-dev
```

## Building and running

In each LessonXX directory, you can build and run the given tutorial by running:

```sh
zig build run
```

On MacOS, you may run into linking problems with OpenGL. If this happens try:

```sh
ZIG_SYSTEM_LINKER_HACK=1 zig build run
```

## Screenshot

From Lesson 6:

![Screenshot](zigNeHe.png)

## TODO

* Should do error-handling in a more Zig-like way, and actually deal with gl initialization failing.
* All the lessons.
