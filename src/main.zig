const std = @import("std");
const CommandParser = @import("command_parser.zig");
const ExitCommand = @import("commands/exit.zig");
const EchoCommand = @import("commands/echo.zig");

pub fn main() !void {
    var stderr: std.io.AnyWriter = std.io.getStdErr().writer().any();
    var stdout: std.io.AnyWriter = std.io.getStdOut().writer().any();
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
            .echo => try EchoCommand.run(allocator, commandInput.arguments, &stdout),
            .unknown => try stderr.print("{s}: command not found\n", .{user_input}),
        }
    }
}
