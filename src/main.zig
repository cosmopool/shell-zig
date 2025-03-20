const std = @import("std");
const command_parser = @import("command_parser.zig");
const exit_cmd = @import("commands/exit.zig");
const echo_cmd = @import("commands/echo.zig");
const type_cmd = @import("commands/type.zig");

pub fn main() !void {
    var stderr: std.io.AnyWriter = std.io.getStdErr().writer().any();
    var stdout: std.io.AnyWriter = std.io.getStdOut().writer().any();
    const stdin = std.io.getStdIn().reader();
    var buffer: [1024]u8 = undefined;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    while (true) {
        defer _ = arena.reset(.{ .retain_with_limit = 1024 * 1024 });

        try stdout.print("$ ", .{});

        const user_input = try stdin.readUntilDelimiter(&buffer, '\n');
        const command_input = try command_parser.Parse(allocator, user_input);
        defer allocator.free(command_input.arguments);

        switch (command_input.command) {
            .exit => try exit_command.run(command_input.arguments),
            .echo => try echo_command.run(allocator, command_input.arguments, &stdout),
            .type => try type_command.run(command_input.arguments, &stdout, &stderr),
            .unknown => try stderr.print("{s}: command not found\n", .{user_input}),
        }
    }
}
