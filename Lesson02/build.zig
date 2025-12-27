const std = @import("std");
const currentTarget = @import("builtin").target;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const translate_c = b.addTranslateC(.{
        .root_source_file = b.path("src/c.h"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const exe = b.addExecutable(.{
        .name = "Lesson02",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    exe.root_module.addImport("c", translate_c.createModule());

    switch (currentTarget.os.tag) {
        .macos => {
            exe.addFrameworkPath(.{ .cwd_relative = "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks" });
            exe.linkFramework("OpenGL");
        },
        .freebsd => {
            exe.addIncludePath(.{ .cwd_relative = "/usr/local/include/GL" });
            exe.linkSystemLibrary("gl");
            exe.linkSystemLibrary("glu");
        },
        .linux => {
            exe.addLibraryPath(.{ .cwd_relative = "/usr/lib/x86_64-linux-gnu" });
            exe.linkSystemLibrary("c");
            exe.linkSystemLibrary("GL");
        },
        else => {
            @panic("don't know how to build on your system");
        },
    }
    exe.addIncludePath(.{ .cwd_relative = "/usr/local/include" });
    exe.linkSystemLibrary("glfw");

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
