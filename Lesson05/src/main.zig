const std = @import("std");
const warn = std.log.warn;
const panic = std.debug.panic;
const c = @import("c");

const width: i32 = 1024;
const height: i32 = 768;

var window: *c.GLFWwindow = undefined;
var rtri: c.GLfloat = 0.0;               // Angle For The Triangle
var rquad: c.GLfloat = 0.0;              // Angle For The Quad

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

fn init_gl() void {
    c.glMatrixMode(c.GL_PROJECTION);                    // Select The Projection Matrix
    c.glLoadIdentity();
    const fHeight: f32 = @floatFromInt(height);
    const fWidth: f32 = @floatFromInt(width);
    const aspect_ratio = fHeight / fWidth;
    perspectiveGL(45.0, (1.0 / aspect_ratio), 0.1, 100.0);
    c.glMatrixMode(c.GL_MODELVIEW);
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

    window = c.glfwCreateWindow(width, height, "Lesson05", null, null) orelse {
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
    c.glTranslatef(-1.5, 0.0, -6.0);            // Move Left 1.5 Units And Into The Screen 6.0
    c.glRotatef(rtri, 0.0, 1.0, 0.0);           // Rotate The Triangle On The Y axis

    c.glBegin(c.GL_TRIANGLES);                  // Drawing Using Triangles
    c.glColor3f(1.0, 0.0, 0.0);                 // Red
    c.glVertex3f(0.0, 1.0, 0.0);                // Top Of Triangle (Front)
    c.glColor3f(0.0, 1.0, 0.0);                 // Green
    c.glVertex3f(-1.0, -1.0, 1.0);              // Left Of Triangle (Front)
    c.glColor3f(0.0, 0.0, 1.0);                 // Blue
    c.glVertex3f(1.0, -1.0, 1.0);               // Right Of Triangle (Front)
    c.glColor3f(1.0, 0.0, 0.0);                 // Red
    c.glVertex3f(0.0, 1.0, 0.0);                // Top Of Triangle (Right)
    c.glColor3f(0.0, 0.0, 1.0);                 // Blue
    c.glVertex3f(1.0, -1.0, 1.0);               // Left Of Triangle (Right)
    c.glColor3f(0.0, 1.0, 0.0);                 // Green
    c.glVertex3f(1.0, -1.0, -1.0);              // Right Of Triangle (Right)
    c.glColor3f(1.0, 0.0, 0.0);                 // Red
    c.glVertex3f(0.0, 1.0, 0.0);                // Top Of Triangle (Back)
    c.glColor3f(0.0, 1.0, 0.0);                 // Green
    c.glVertex3f(1.0, -1.0, -1.0);              // Left Of Triangle (Back)
    c.glColor3f(0.0, 0.0, 1.0);                 // Blue
    c.glVertex3f(-1.0, -1.0, -1.0);             // Right Of Triangle (Back)
    c.glColor3f(1.0, 0.0, 0.0);                 // Red
    c.glVertex3f(0.0, 1.0, 0.0);                // Top Of Triangle (Left)
    c.glColor3f(0.0, 0.0, 1.0);                 // Blue
    c.glVertex3f(-1.0, -1.0, -1.0);             // Left Of Triangle (Left)
    c.glColor3f(0.0, 1.0, 0.0);                 // Green
    c.glVertex3f(-1.0, -1.0, 1.0);              // Right Of Triangle (Left)
    c.glEnd();                                  // Finished Drawing The Triangle

    c.glLoadIdentity();                         // Reset The Current Modelview Matrix
    c.glTranslatef(1.5, 0.0, -6.0);             // Move Right 3 Units
    c.glRotatef(rquad, 1.0, 0.0, 0.0);          // Rotate The Quad On The X axis (NEW )

    c.glBegin(c.GL_QUADS);                      // Draw A Quad
    c.glColor3f(0.0, 1.0, 0.0);                 // Set The Color To Green
    c.glVertex3f( 1.0, 1.0, -1.0);              // Top Right Of The Quad (Top)
    c.glVertex3f(-1.0, 1.0, -1.0);              // Top Left Of The Quad (Top)
    c.glVertex3f(-1.0, 1.0, 1.0);               // Bottom Left Of The Quad (Top)
    c.glVertex3f( 1.0, 1.0, 1.0);               // Bottom Right Of The Quad (Top)
    c.glColor3f(1.0, 0.5, 0.0);                 // Set The Color To Orange
    c.glVertex3f( 1.0, -1.0, 1.0);              // Top Right Of The Quad (Bottom)
    c.glVertex3f(-1.0, -1.0, 1.0);              // Top Left Of The Quad (Bottom)
    c.glVertex3f(-1.0, -1.0, -1.0);             // Bottom Left Of The Quad (Bottom)
    c.glVertex3f( 1.0, -1.0, -1.0);             // Bottom Right Of The Quad (Bottom)
    c.glColor3f(1.0, 0.0, 0.0);                 // Set The Color To Red
    c.glVertex3f( 1.0, 1.0, 1.0);               // Top Right Of The Quad (Front)
    c.glVertex3f(-1.0, 1.0, 1.0);               // Top Left Of The Quad (Front)
    c.glVertex3f(-1.0, -1.0, 1.0);              // Bottom Left Of The Quad (Front)
    c.glVertex3f( 1.0, -1.0, 1.0);              // Bottom Right Of The Quad (Front)
    c.glColor3f(1.0, 1.0, 0.0);                 // Set The Color To Yellow
    c.glVertex3f( 1.0, -1.0, -1.0);             // Bottom Left Of The Quad (Back)
    c.glVertex3f(-1.0, -1.0, -1.0);             // Bottom Right Of The Quad (Back)
    c.glVertex3f(-1.0, 1.0, -1.0);              // Top Right Of The Quad (Back)
    c.glVertex3f( 1.0, 1.0, -1.0);              // Top Left Of The Quad (Back)
    c.glColor3f(0.0, 0.0, 1.0);                 // Set The Color To Blue
    c.glVertex3f(-1.0, 1.0, 1.0);               // Top Right Of The Quad (Left)
    c.glVertex3f(-1.0, 1.0, -1.0);              // Top Left Of The Quad (Left)
    c.glVertex3f(-1.0, -1.0, -1.0);             // Bottom Left Of The Quad (Left)
    c.glVertex3f(-1.0, -1.0, 1.0);              // Bottom Right Of The Quad (Left)
    c.glColor3f(1.0, 0.0, 1.0);                 // Set The Color To Violet
    c.glVertex3f( 1.0, 1.0, -1.0);              // Top Right Of The Quad (Right)
    c.glVertex3f( 1.0, 1.0, 1.0);               // Top Left Of The Quad (Right)
    c.glVertex3f( 1.0, -1.0, 1.0);              // Bottom Left Of The Quad (Right)
    c.glVertex3f( 1.0, -1.0, -1.0);             // Bottom Right Of The Quad (Right)
    c.glEnd();                                  // Done Drawing The Quad

    c.glLoadIdentity();                         // Reset The Current Modelview Matrix

    rtri += 0.6;                                // Increase The Rotation Variable For The Triangle
    rquad -= 0.45;                              // Decrease The Rotation Variable For The Quad
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
