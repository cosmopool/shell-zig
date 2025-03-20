const std = @import("std");
const testing = @import("std").testing;
const Strings = @import("../strings.zig");

pub fn run(allocator: std.mem.Allocator, input: [][]const u8, stdout: *std.io.AnyWriter) !void {
    std.debug.assert(input.len > 0);
    std.debug.assert(std.mem.eql(u8, input[0], "echo"));

    const toPrint = try Strings.join(allocator, input[1..]);
    defer allocator.free(toPrint);
    try stdout.print("{s}\n", .{toPrint});
}
