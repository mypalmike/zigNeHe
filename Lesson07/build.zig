const std = @import("std");
const currentTarget = @import("builtin").target;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "Lesson07",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    exe.addCSourceFile(.{
        .file = .{ .path = "stb_image-2.23/stb_image_impl.c" },
        .flags = &[_][]const u8{"-std=c99"},
    });

    switch (currentTarget.os.tag) {
        .macos => {
            exe.addFrameworkPath(.{ .path = "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks" });
            exe.addIncludePath("/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/OpenGL.framework/Headers");
            exe.linkFramework("OpenGL");
        },
        .freebsd => {
            exe.addIncludePath(.{ .path = "/usr/local/include/GL" });
            exe.linkSystemLibrary("gl");
            exe.linkSystemLibrary("glu");
        },
        .linux => {
            exe.addLibraryPath(.{ .path = "/usr/lib/x86_64-linux-gnu" });
            exe.linkSystemLibrary("c");
            exe.linkSystemLibrary("GL");
            exe.linkSystemLibrary("GLU");
        },
        else => {
            @panic("don't know how to build on your system");
        },
    }
    exe.addIncludePath(.{ .path = "stb_image-2.23" });
    exe.addIncludePath(.{ .path = "/usr/local/include" });
    exe.linkSystemLibrary("glfw");

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
