const std = @import("std");
const CommandInput = @import("core").CommandInput;
const exit_cmd = @import("commands/exit.zig");
const echo_cmd = @import("commands/echo.zig");
const type_cmd = @import("commands/type.zig");
const cd_cmd = @import("commands/cd.zig");
const run_executable_cmd = @import("commands/run_executable.zig");
const Environment = @import("core").Environment;

const page_allocator = std.heap.page_allocator;

pub fn main() !void {
    // ----------------------------------------------
    // INIT
    // ----------------------------------------------
    var stderr: std.io.AnyWriter = std.io.getStdErr().writer().any();
    var stdout: std.io.AnyWriter = std.io.getStdOut().writer().any();
    const stdin = std.io.getStdIn().reader();
    var buffer: [1024]u8 = undefined;

    var arena = std.heap.ArenaAllocator.init(page_allocator);
    const allocator = arena.allocator();
    var environ = try Environment.init(page_allocator);

    // ----------------------------------------------
    // DEINIT
    // ----------------------------------------------
    defer arena.deinit();

    while (true) {
        defer _ = arena.reset(.{ .retain_with_limit = 1024 * 1024 });
        defer environ.reset();

        try stdout.print("$ ", .{});

        const user_input = try stdin.readUntilDelimiter(&buffer, '\n');
        const command_input = try CommandInput.parse(allocator, user_input);
        defer allocator.free(command_input.arguments);

        if (user_input.len == 0) {
            try stderr.print("\n", .{});
            continue;
        }

        switch (command_input.command) {
            .exit => try exit_cmd.run(command_input.arguments),
            .echo => try echo_cmd.run(allocator, command_input.arguments, &stdout),
            .type => try type_cmd.run(allocator, command_input.arguments, &stdout, &stderr, &environ),
            .pwd => try stdout.print("{s}\n", .{environ.pwd}),
            .cd => try cd_cmd.run(allocator, command_input.arguments, &stdout, &stderr, &environ),
            .unknown => try run_executable_cmd.run(allocator, command_input.arguments, &stderr, &environ),
        }
    }
}
