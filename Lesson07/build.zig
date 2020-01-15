const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("Lesson07", "src/main.zig");

    exe.addCSourceFile("stb_image-2.23/stb_image_impl.c", &[_][]const u8{"-std=c99"});

    exe.setBuildMode(mode);

    exe.addFrameworkDir("/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks");
    exe.addIncludeDir("/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/OpenGL.framework/Headers");
    exe.addIncludeDir("stb_image-2.23");
    exe.addIncludeDir("/usr/local/include");
    exe.linkSystemLibrary("glfw");
    exe.linkFramework("OpenGL");

    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
