const std = @import("std");
const testing = @import("std").testing;
const Strings = @import("../strings.zig");

pub fn run(allocator: std.mem.Allocator, input: [][]const u8, stdout: std.io.AnyWriter) !void {
    std.debug.assert(input.len > 0);
    std.debug.assert(std.mem.eql(u8, input[0], "echo"));

    const toPrint = try Strings.join(allocator, input[1..]);
    defer allocator.free(toPrint);
    try stdout.print("{s}\n", .{toPrint});
}

// test "echo command finishes without error" {
//     var input = [_][]const u8{ "exit", "0" };
//     // const writer = std.io.GenericWriter(comptime Context: type, comptime WriteError: type, comptime writeFn: fn(context:Context, bytes:[]const u8)WriteError!usize)
//     // const writer = std.fs.File.writer(file: File);
//     try run(testing.allocator, &input, writer);
// }
