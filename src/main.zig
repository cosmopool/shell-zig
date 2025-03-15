const std = @import("std");

pub fn main() !void {
    const stderr = std.io.getStdErr().writer();
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();
    var buffer: [1024]u8 = undefined;

    var shouldExit: bool = false;
    while (!shouldExit) {
        try stdout.print("$ ", .{});

        const user_input = try stdin.readUntilDelimiter(&buffer, '\n');

        if (std.mem.eql(u8, user_input, "exit")) {
            shouldExit = true;
        } else {
            try stderr.print("{s}: command not found\n", .{user_input});
        }
    }

    std.process.exit(0);
}
