const std = @import("std");
const warn = std.log.warn;
const panic = std.debug.panic;
const c = @import("c");
const PngImage = @import("png.zig").PngImage;
const crate_png = @embedFile("data/Crate.png");

const width: i32 = 1024;
const height: i32 = 768;

var window: *c.GLFWwindow = undefined;

var light: bool = false;              // Lighting ON/OFF

var xrot: c.GLfloat = 0.0;            // X Rotation
var yrot: c.GLfloat = 0.0;            // Y Rotation
var xspeed: c.GLfloat = 0.0;          // X Rotation Speed
var yspeed: c.GLfloat = 0.0;          // Y Rotation Speed
var z: c.GLfloat = -5.0;              // Depth Into The Screen

var filter: c.GLuint = 0;             // Which Filter To Use
var texture: [3]c.GLuint = undefined; // Storage For 3 Textures

const lightAmbient = [_]c.GLfloat {0.5, 0.5, 0.5, 1.0};
const lightDiffuse = [_]c.GLfloat {1.0, 1.0, 1.0, 1.0};
const lightPosition = [_]c.GLfloat {0.0, 0.0, 2.0, 1.0};

fn errorCallback(err: c_int, description: [*c]const u8) callconv(.c) void {
    _ = err;
    panic("Error: {s}\n", .{description});
}

fn keyCallback(win: ?*c.GLFWwindow, key: c_int, scancode: c_int, action: c_int, mods: c_int) callconv(.c) void {
    _ = scancode;
    _ = mods;

    if (action == c.GLFW_PRESS) {
        switch (key) {
            c.GLFW_KEY_ESCAPE => c.glfwSetWindowShouldClose(win, c.GL_TRUE),
            'L' => {
                light = !light;
                if (light) {
                    c.glEnable(c.GL_LIGHTING);
                } else {
                    c.glDisable(c.GL_LIGHTING);
                }
            },
            'F' => {
                filter += 1;
                filter = filter % 3;
            },
            else => {},
        }
    } else if (action == c.GLFW_REPEAT) {
        switch (key) {
            c.GLFW_KEY_PAGE_UP => z -= 0.02,
            c.GLFW_KEY_PAGE_DOWN => z += 0.02,
            c.GLFW_KEY_UP => xspeed -= 0.01,
            c.GLFW_KEY_DOWN => xspeed -= 0.01,
            c.GLFW_KEY_RIGHT => yspeed += 0.01,
            c.GLFW_KEY_LEFT => yspeed -= 0.01,
            else => {},
        }
    }
}

fn perspectiveGL(fovY: f64, aspect: f64, zNear: f64, zFar: f64) void {
    const fH = std.math.tan(fovY / 360 * std.math.pi) * zNear;
    const fW = fH * aspect;
    c.glFrustum(-fW, fW, -fH, fH, zNear, zFar);
}

fn load_textures() !void {
    var img = try PngImage.create(crate_png);

    // Create 3 textures
    c.glGenTextures(3, &texture);
    // errdefer c.glDeleteTextures(3, &texture);

    c.glBindTexture(c.GL_TEXTURE_2D, texture[0]);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MIN_FILTER, c.GL_NEAREST);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MAG_FILTER, c.GL_NEAREST);
    c.glTexImage2D(
        c.GL_TEXTURE_2D,
        0,
        c.GL_RGBA,
        @intCast(img.width),
        @intCast(img.height),
        0,
        c.GL_RGBA,
        c.GL_UNSIGNED_BYTE,
        @ptrCast(&img.raw[0]),
    );

    c.glBindTexture(c.GL_TEXTURE_2D, texture[1]);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MIN_FILTER, c.GL_LINEAR);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MAG_FILTER, c.GL_LINEAR);
    c.glTexImage2D(
        c.GL_TEXTURE_2D,
        0,
        c.GL_RGBA,
        @intCast(img.width),
        @intCast(img.height),
        0,
        c.GL_RGBA,
        c.GL_UNSIGNED_BYTE,
        @ptrCast(&img.raw[0]),
    );

    c.glBindTexture(c.GL_TEXTURE_2D, texture[2]);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MIN_FILTER, c.GL_LINEAR_MIPMAP_NEAREST);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MAG_FILTER, c.GL_LINEAR);
    _ = c.gluBuild2DMipmaps(
        c.GL_TEXTURE_2D,
        c.GL_RGBA,
        @intCast(img.width),
        @intCast(img.height),
        c.GL_RGBA,
        c.GL_UNSIGNED_BYTE,
        @ptrCast(&img.raw[0]),
    );
}

fn init_gl() void {
    load_textures() catch {
        warn("Failed to load textures.\n", .{});
    };

    c.glViewport(0, 0, width, height);
    c.glMatrixMode(c.GL_PROJECTION);                        // Select The Projection Matrix
    c.glLoadIdentity();
    const fHeight: f32 = @floatFromInt(height);
    const fWidth: f32 = @floatFromInt(width);
    const aspect_ratio = fHeight / fWidth;
    perspectiveGL(45.0, (1.0 / aspect_ratio), 0.1, 100.0);
    c.glMatrixMode(c.GL_MODELVIEW);
    c.glLoadIdentity();

    c.glEnable(c.GL_TEXTURE_2D);
    c.glShadeModel(c.GL_SMOOTH);                            // Enables Smooth Shading
    c.glClearColor(0.0, 0.0, 0.0, 0.5);                     // Black Background
    c.glClearDepth(1.0);                                    // Depth Buffer Setup
    c.glEnable(c.GL_DEPTH_TEST);                            // Enables Depth Testing
    c.glDepthFunc(c.GL_LEQUAL);                             // The Type Of Depth Test To Do
    c.glHint(c.GL_PERSPECTIVE_CORRECTION_HINT, c.GL_NICEST);  // Really Nice Perspective Calculations

    c.glLightfv(c.GL_LIGHT1, c.GL_AMBIENT, &lightAmbient[0]);   // Setup The Ambient Light
    c.glLightfv(c.GL_LIGHT1, c.GL_DIFFUSE, &lightDiffuse[0]);   // Setup The Diffuse Light
    c.glLightfv(c.GL_LIGHT1, c.GL_POSITION, &lightPosition[0]); // Position The Light
    c.glEnable(c.GL_LIGHT1);                                // Enable Light One
}

fn init() bool {
    _ = c.glfwSetErrorCallback(errorCallback);

    if (c.glfwInit() == c.GL_FALSE) {
        warn("Failed to initialize GLFW\n", .{});
        return false;
    }

    c.glfwWindowHint(c.GLFW_SAMPLES, 4);                // 4x antialiasing

    window = c.glfwCreateWindow(width, height, "Lesson07", null, null) orelse {
        panic("unable to create window\n", .{});
    };

    _ = c.glfwSetKeyCallback(window, keyCallback);
    c.glfwMakeContextCurrent(window);
    c.glfwSwapInterval(1);

    init_gl();
    return true;
}

fn draw() void {                                // Here's Where We Do All The Drawing
    c.glClear(c.GL_COLOR_BUFFER_BIT | c.GL_DEPTH_BUFFER_BIT);         // Clear The Screen And The Depth Buffer
    c.glLoadIdentity();                         // Reset The Current Modelview Matrix

    c.glTranslatef(0.0, 0.0, z);
    c.glRotatef(xrot, 1.0, 0.0, 0.0);
    c.glRotatef(yrot, 0.0, 1.0, 0.0);

    c.glBindTexture(c.GL_TEXTURE_2D, texture[filter]);  // Select Our Texture

    c.glBegin(c.GL_QUADS);
    // Front
    c.glNormal3f(0.0, 0.0, 1.0);
    c.glTexCoord2f(0.0, 0.0); c.glVertex3f(-1.0, -1.0,  1.0);  // Bottom Left Of The Texture and Quad
    c.glTexCoord2f(1.0, 0.0); c.glVertex3f( 1.0, -1.0,  1.0);  // Bottom Right Of The Texture and Quad
    c.glTexCoord2f(1.0, 1.0); c.glVertex3f( 1.0,  1.0,  1.0);  // Top Right Of The Texture and Quad
    c.glTexCoord2f(0.0, 1.0); c.glVertex3f(-1.0,  1.0,  1.0);  // Top Left Of The Texture and Quad
    // Back Face
    c.glNormal3f(0.0, 0.0, -1.0);
    c.glTexCoord2f(1.0, 0.0); c.glVertex3f(-1.0, -1.0, -1.0);  // Bottom Right Of The Texture and Quad
    c.glTexCoord2f(1.0, 1.0); c.glVertex3f(-1.0,  1.0, -1.0);  // Top Right Of The Texture and Quad
    c.glTexCoord2f(0.0, 1.0); c.glVertex3f( 1.0,  1.0, -1.0);  // Top Left Of The Texture and Quad
    c.glTexCoord2f(0.0, 0.0); c.glVertex3f( 1.0, -1.0, -1.0);  // Bottom Left Of The Texture and Quad
    // Top Face
    c.glNormal3f(0.0, 1.0, 0.0);
    c.glTexCoord2f(0.0, 1.0); c.glVertex3f(-1.0,  1.0, -1.0);  // Top Left Of The Texture and Quad
    c.glTexCoord2f(0.0, 0.0); c.glVertex3f(-1.0,  1.0,  1.0);  // Bottom Left Of The Texture and Quad
    c.glTexCoord2f(1.0, 0.0); c.glVertex3f( 1.0,  1.0,  1.0);  // Bottom Right Of The Texture and Quad
    c.glTexCoord2f(1.0, 1.0); c.glVertex3f( 1.0,  1.0, -1.0);  // Top Right Of The Texture and Quad
    // Bottom Face
    c.glNormal3f(0.0, -1.0, 0.0);
    c.glTexCoord2f(1.0, 1.0); c.glVertex3f(-1.0, -1.0, -1.0);  // Top Right Of The Texture and Quad
    c.glTexCoord2f(0.0, 1.0); c.glVertex3f( 1.0, -1.0, -1.0);  // Top Left Of The Texture and Quad
    c.glTexCoord2f(0.0, 0.0); c.glVertex3f( 1.0, -1.0,  1.0);  // Bottom Left Of The Texture and Quad
    c.glTexCoord2f(1.0, 0.0); c.glVertex3f(-1.0, -1.0,  1.0);  // Bottom Right Of The Texture and Quad
    // Right face
    c.glNormal3f(1.0, 0.0, 0.0);
    c.glTexCoord2f(1.0, 0.0); c.glVertex3f( 1.0, -1.0, -1.0);  // Bottom Right Of The Texture and Quad
    c.glTexCoord2f(1.0, 1.0); c.glVertex3f( 1.0,  1.0, -1.0);  // Top Right Of The Texture and Quad
    c.glTexCoord2f(0.0, 1.0); c.glVertex3f( 1.0,  1.0,  1.0);  // Top Left Of The Texture and Quad
    c.glTexCoord2f(0.0, 0.0); c.glVertex3f( 1.0, -1.0,  1.0);  // Bottom Left Of The Texture and Quad
    // Left Face
    c.glNormal3f(-1.0, 0.0, 0.0);
    c.glTexCoord2f(0.0, 0.0); c.glVertex3f(-1.0, -1.0, -1.0);  // Bottom Left Of The Texture and Quad
    c.glTexCoord2f(1.0, 0.0); c.glVertex3f(-1.0, -1.0,  1.0);  // Bottom Right Of The Texture and Quad
    c.glTexCoord2f(1.0, 1.0); c.glVertex3f(-1.0,  1.0,  1.0);  // Top Right Of The Texture and Quad
    c.glTexCoord2f(0.0, 1.0); c.glVertex3f(-1.0,  1.0, -1.0);  // Top Left Of The Texture and Quad
    c.glEnd();

    xrot += xspeed;
    yrot += yspeed;
}

pub fn main() u8 {
    if (!init()) {
        return 1;
    }

    while (c.glfwWindowShouldClose(window) == c.GL_FALSE) {
        // Actually draw stuff.
        draw();

        // Swap buffers
        c.glfwSwapBuffers(window);

        c.glfwPollEvents();
    }

    return 0;
}
