const std = @import("std");
const testing = @import("std").testing;
const strings = @import("../strings.zig");
const BuiltinCommands = @import("../commands.zig").BuiltinCommands;
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

    for (0..environment.paths.len - 1) |i| {
        const directory = environment.paths.get(i);
        var it = directory.dir.iterate();
        defer it.reset();

        while (try it.next()) |entry| {
            if (!std.mem.eql(u8, entry.name, input[1])) continue;
            const full_path = try directory.fullPath(allocator, entry.name);
            return try stdout.print("{s} is {s}\n", .{ input[1], full_path });
        }
    }

    try stderr.print("{s}: not found\n", .{input[1]});
}
