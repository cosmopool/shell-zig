const std = @import("std");
const testing = @import("std").testing;
const Strings = @import("../strings.zig");
const BuiltinCommands = @import("../commands.zig").BuiltinCommands;

pub fn run(input: [][]const u8, stdout: *std.io.AnyWriter, stderr: *std.io.AnyWriter) !void {
    std.debug.assert(input.len > 0);
    std.debug.assert(std.mem.eql(u8, input[0], "type"));

    const command = std.meta.stringToEnum(BuiltinCommands, input[1]) orelse .unknown;
    if (command != .unknown) {
        try stdout.print("{s} is a shell builtin\n", .{input[1]});
    } else {
        try stderr.print("{s}: not found\n", .{input[1]});
    }
}
