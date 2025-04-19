const std = @import("std");
const testing = @import("std").testing;
const strings = @import("../strings.zig");
const BuiltinCommands = @import("../command_input.zig").BuiltinCommands;
const Environment = @import("../environment.zig");
const assert = std.debug.assert;
const AnyWriter = std.io.AnyWriter;

pub fn run(allocator: std.mem.Allocator, input: [][]const u8, stdout: *AnyWriter, stderr: *AnyWriter, environment: *Environment) !void {
    assert(input.len > 1);
    assert(std.mem.eql(u8, input[0], "type"));

    const command = std.meta.stringToEnum(BuiltinCommands, input[1]) orelse .unknown;
    if (command != .unknown) {
        return try stdout.print("{s} is a shell builtin\n", .{input[1]});
    }

    defer environment.paths.reset();
    while (environment.paths.next()) |dir_path| {
        const full_path = try std.fs.path.join(allocator, &[_][]const u8{ dir_path, input[1] });
        // check if file exists at 'full_path'
        std.fs.accessAbsolute(full_path, .{ .mode = .read_only }) catch continue;
        return try stdout.print("{s} is {s}\n", .{ input[1], full_path });
    }

    try stderr.print("{s}: not found\n", .{input[1]});
}
