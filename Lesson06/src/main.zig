const std = @import("std");
const warn = std.log.warn;
const panic = std.debug.panic;
const c = @import("c");
const PngImage = @import("png.zig").PngImage;
const nehe_png = @embedFile("data/NeHe.png");

const width: i32 = 1024;
const height: i32 = 768;

var window: *c.GLFWwindow = undefined;

var xrot: c.GLfloat = 0.0;
var yrot: c.GLfloat = 0.0;
var zrot: c.GLfloat = 0.0;

var texture: c.GLuint = 0; //      texture[1];                 // Storage For One Texture

fn errorCallback(err: c_int, description: [*c]const u8) callconv(.c) void {
    _ = err;
    panic("Error: {s}\n", .{description});
}

fn keyCallback(win: ?*c.GLFWwindow, key: c_int, scancode: c_int, action: c_int, mods: c_int) callconv(.c) void {
    _ = scancode;
    _ = mods;

    if (action != c.GLFW_PRESS) return;

    switch (key) {
        c.GLFW_KEY_ESCAPE => c.glfwSetWindowShouldClose(win, c.GL_TRUE),
        else => {},
    }
}

fn perspectiveGL(fovY: f64, aspect: f64, zNear: f64, zFar: f64) void {
    const fH = std.math.tan(fovY / 360 * std.math.pi) * zNear;
    const fW = fH * aspect;
    c.glFrustum(-fW, fW, -fH, fH, zNear, zFar);
}

fn load_texture() !void {
    var img = try PngImage.create(nehe_png);
    c.glGenTextures(1, &texture);
    errdefer c.glDeleteTextures(1, &texture);

    c.glBindTexture(c.GL_TEXTURE_2D, texture);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MIN_FILTER, c.GL_LINEAR);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MAG_FILTER, c.GL_LINEAR);
    // c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_WRAP_S, c.GL_CLAMP_TO_EDGE);
    // c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_WRAP_T, c.GL_CLAMP_TO_EDGE);
    // c.glPixelStorei(c.GL_PACK_ALIGNMENT, 4);
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

}

fn init_gl() void {
    load_texture() catch {
        warn("Failed to load texture.\n", .{});
    };

    c.glMatrixMode(c.GL_PROJECTION);                    // Select The Projection Matrix
    c.glLoadIdentity();
    const fHeight: f32 = @floatFromInt(height);
    const fWidth: f32 = @floatFromInt(width);
    const aspect_ratio = fHeight / fWidth;
    perspectiveGL(45.0, (1.0 / aspect_ratio), 0.1, 100.0);
    c.glMatrixMode(c.GL_MODELVIEW);
    c.glEnable(c.GL_TEXTURE_2D);
    c.glShadeModel(c.GL_SMOOTH);                        // Enables Smooth Shading
    c.glClearColor(0.0, 0.0, 0.0, 0.0);                 // Black Background
    c.glClearDepth(1.0);                                // Depth Buffer Setup
    c.glEnable(c.GL_DEPTH_TEST);                        // Enables Depth Testing
    c.glDepthFunc(c.GL_LEQUAL);                         // The Type Of Depth Test To Do
    c.glHint(c.GL_PERSPECTIVE_CORRECTION_HINT, c.GL_NICEST);  // Really Nice Perspective Calculations
}

fn init() bool {
    _ = c.glfwSetErrorCallback(errorCallback);

    if (c.glfwInit() == c.GL_FALSE) {
        warn("Failed to initialize GLFW\n", .{});
        return false;
    }

    c.glfwWindowHint(c.GLFW_SAMPLES, 4);                // 4x antialiasing

    window = c.glfwCreateWindow(width, height, "Lesson06", null, null) orelse {
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
    c.glTranslatef(0.0, 0.0, -5.0);             // Move Into The Screen 5 Units
    c.glRotatef(xrot, 1.0, 0.0, 0.0);           // Rotate On The X Axis
    c.glRotatef(yrot, 0.0, 1.0, 0.0);           // Rotate On The Y Axis
    c.glRotatef(zrot, 0.0, 0.0, 1.0);           // Rotate On The Z Axis
    c.glBindTexture(c.GL_TEXTURE_2D, texture);  // Select Our Texture

    c.glBegin(c.GL_QUADS);
    // Front Face
    c.glTexCoord2f(0.0, 0.0); c.glVertex3f(-1.0, -1.0,  1.0);  // Bottom Left Of The Texture and Quad
    c.glTexCoord2f(1.0, 0.0); c.glVertex3f( 1.0, -1.0,  1.0);  // Bottom Right Of The Texture and Quad
    c.glTexCoord2f(1.0, 1.0); c.glVertex3f( 1.0,  1.0,  1.0);  // Top Right Of The Texture and Quad
    c.glTexCoord2f(0.0, 1.0); c.glVertex3f(-1.0,  1.0,  1.0);  // Top Left Of The Texture and Quad
    // Back Face
    c.glTexCoord2f(1.0, 0.0); c.glVertex3f(-1.0, -1.0, -1.0);  // Bottom Right Of The Texture and Quad
    c.glTexCoord2f(1.0, 1.0); c.glVertex3f(-1.0,  1.0, -1.0);  // Top Right Of The Texture and Quad
    c.glTexCoord2f(0.0, 1.0); c.glVertex3f( 1.0,  1.0, -1.0);  // Top Left Of The Texture and Quad
    c.glTexCoord2f(0.0, 0.0); c.glVertex3f( 1.0, -1.0, -1.0);  // Bottom Left Of The Texture and Quad
    // Top Face
    c.glTexCoord2f(0.0, 1.0); c.glVertex3f(-1.0,  1.0, -1.0);  // Top Left Of The Texture and Quad
    c.glTexCoord2f(0.0, 0.0); c.glVertex3f(-1.0,  1.0,  1.0);  // Bottom Left Of The Texture and Quad
    c.glTexCoord2f(1.0, 0.0); c.glVertex3f( 1.0,  1.0,  1.0);  // Bottom Right Of The Texture and Quad
    c.glTexCoord2f(1.0, 1.0); c.glVertex3f( 1.0,  1.0, -1.0);  // Top Right Of The Texture and Quad
    // Bottom Face
    c.glTexCoord2f(1.0, 1.0); c.glVertex3f(-1.0, -1.0, -1.0);  // Top Right Of The Texture and Quad
    c.glTexCoord2f(0.0, 1.0); c.glVertex3f( 1.0, -1.0, -1.0);  // Top Left Of The Texture and Quad
    c.glTexCoord2f(0.0, 0.0); c.glVertex3f( 1.0, -1.0,  1.0);  // Bottom Left Of The Texture and Quad
    c.glTexCoord2f(1.0, 0.0); c.glVertex3f(-1.0, -1.0,  1.0);  // Bottom Right Of The Texture and Quad
    // Right face
    c.glTexCoord2f(1.0, 0.0); c.glVertex3f( 1.0, -1.0, -1.0);  // Bottom Right Of The Texture and Quad
    c.glTexCoord2f(1.0, 1.0); c.glVertex3f( 1.0,  1.0, -1.0);  // Top Right Of The Texture and Quad
    c.glTexCoord2f(0.0, 1.0); c.glVertex3f( 1.0,  1.0,  1.0);  // Top Left Of The Texture and Quad
    c.glTexCoord2f(0.0, 0.0); c.glVertex3f( 1.0, -1.0,  1.0);  // Bottom Left Of The Texture and Quad
    // Left Face
    c.glTexCoord2f(0.0, 0.0); c.glVertex3f(-1.0, -1.0, -1.0);  // Bottom Left Of The Texture and Quad
    c.glTexCoord2f(1.0, 0.0); c.glVertex3f(-1.0, -1.0,  1.0);  // Bottom Right Of The Texture and Quad
    c.glTexCoord2f(1.0, 1.0); c.glVertex3f(-1.0,  1.0,  1.0);  // Top Right Of The Texture and Quad
    c.glTexCoord2f(0.0, 1.0); c.glVertex3f(-1.0,  1.0, -1.0);  // Top Left Of The Texture and Quad
    c.glEnd();

    c.glLoadIdentity();                         // Reset The Current Modelview Matrix

    xrot += 0.3;                               // X Axis Rotation
    yrot += 0.2;                               // Y Axis Rotation
    zrot += 0.4;                               // Z Axis Rotation
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
