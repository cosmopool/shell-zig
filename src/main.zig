const std = @import("std");
const CommandParser = @import("parser.zig");
const ExitCommand = @import("commands/exit.zig");

pub fn main() !void {
    const stderr = std.io.getStdErr().writer();
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();
    var buffer: [1024]u8 = undefined;

    while (true) {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        const allocator = arena.allocator();
        defer arena.deinit();

        try stdout.print("$ ", .{});

        const user_input = try stdin.readUntilDelimiter(&buffer, '\n');
        const commandInput = try CommandParser.parse(allocator, user_input);
        defer allocator.free(commandInput.arguments);

        switch (commandInput.command) {
            .exit => try ExitCommand.run(commandInput.arguments),
            .unknown => try stderr.print("{s}: command not found\n", .{user_input}),
        }
    }
}
