const std = @import("std");
const assert = std.debug.assert;
const AnyWriter = std.io.AnyWriter;

const BuiltinCommands = @import("command_input").BuiltinCommands;
const Environment = @import("core").Environment;
const strings = @import("core").strings;

pub fn run(allocator: std.mem.Allocator, user_input: [][]const u8, stderr: *AnyWriter, environment: *Environment) !void {
    assert(user_input.len > 0);

    defer environment.paths.reset();
    while (environment.paths.next()) |dir_path| {
        const full_path = try std.fs.path.join(allocator, &[_][]const u8{ dir_path, user_input[0] });
        // check if file exists at 'full_path'
        std.fs.accessAbsolute(full_path, .{ .mode = .read_only }) catch continue;

        var proc = std.process.Child.init(user_input, allocator);
        proc.stdin_behavior = .Inherit;
        proc.stdout_behavior = .Inherit;
        proc.stderr_behavior = .Inherit;

        try proc.spawn();
        _ = try proc.wait();
        return;
    }

    try stderr.print("{s}: command not found\n", .{user_input[0]});
}
