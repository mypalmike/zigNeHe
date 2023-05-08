const std = @import("std");
const currentTarget = @import("builtin").target;
const Builder = std.build.Builder;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("Lesson02", "src/main.zig");
    exe.setBuildMode(mode);

    exe.addIncludePath("/usr/local/include");
    switch (currentTarget.os.tag) {
        .macos => {
            exe.addFrameworkDir("/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks");
            exe.linkFramework("OpenGL");
        },
        .freebsd => {
            exe.addIncludePath("/usr/local/include/GL");
            exe.linkSystemLibrary("gl");
            exe.linkSystemLibrary("glu");
        },
        .linux => {
            exe.addLibraryPath("/usr/lib/x86_64-linux-gnu");
            exe.linkSystemLibrary("c");
            exe.linkSystemLibrary("gl");
        },
        else => {
            @panic("don't know how to build on your system");
        },
    }
    exe.linkSystemLibrary("glfw");

    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
