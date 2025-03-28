const std = @import("std");

// Learn more about this file here: https://ziglang.org/learn/build-system
pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const exe = b.addExecutable(.{
        .name = "main",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(exe);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(exe);

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // tests
    const parser_tests = b.addTest(.{
        .root_source_file = b.path("src/command_parser.zig"),
        .optimize = optimize,
        .target = target,
    });
    const strings_tests = b.addTest(.{
        .root_source_file = b.path("src/strings.zig"),
        .optimize = optimize,
        .target = target,
    });
    const exit_tests = b.addTest(.{
        .root_source_file = b.path("src/commands/exit.zig"),
        .optimize = optimize,
        .target = target,
    });
    const environment_tests = b.addTest(.{
        .root_source_file = b.path("src/environment.zig"),
        .optimize = optimize,
        .target = target,
    });

    const run_parser_tests = b.addRunArtifact(parser_tests);
    const run_strings_tests = b.addRunArtifact(strings_tests);
    const run_exit_tests = b.addRunArtifact(exit_tests);
    const run_environment_tests = b.addRunArtifact(environment_tests);

    const test_step = b.step("test", "Runs the test suite.");
    test_step.dependOn(&run_parser_tests.step);
    test_step.dependOn(&run_strings_tests.step);
    test_step.dependOn(&run_exit_tests.step);
    test_step.dependOn(&run_environment_tests.step);
}
