const std = @import("std");
const testing = @import("std").testing;

pub fn run(input: [][]const u8) !void {
    std.debug.assert(std.mem.eql(u8, input[0], "exit"));
    std.debug.assert(input.len > 0);

    if (input.len == 1) std.process.exit(0);

    const code = try std.fmt.parseUnsigned(u8, input[1], 10);
    std.process.exit(code);
}

test "exit command finishes without error" {
    var input = [_][]const u8{ "exit", "0" };
    try run(&input);
}
