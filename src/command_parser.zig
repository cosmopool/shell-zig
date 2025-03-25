const std = @import("std");
const testing = @import("std").testing;
const Allocator = std.mem.Allocator;
const BuiltinCommands = @import("commands.zig").BuiltinCommands;
const CommandInput = @import("commands.zig").CommandInput;
const strings = @import("strings.zig");

/// Parse user input string into an command and it's arguments
pub fn Parse(allocator: Allocator, input_string: []const u8) !CommandInput {
    const input = try strings.split(allocator, input_string, ' ');
    errdefer allocator.free(input);
    if (input.len == 0) {
        return CommandInput{ .command = .unknown, .arguments = &.{} };
    }

    const builtin_command = std.meta.stringToEnum(BuiltinCommands, input[0]) orelse .unknown;
    return CommandInput{ .command = builtin_command, .arguments = input };
}

test Parse {
    {
        const output = try Parse(testing.allocator, "exit 0");
        defer testing.allocator.free(output.arguments);
        try testing.expectEqual(.exit, output.command);
        try testing.expectEqual(2, output.arguments.len);
    }

    // {
    //     // TODO: fix this memory leak
    //     const output = try parse(testing.allocator, "singleWord");
    //     defer testing.allocator.free(output.arguments);
    //     try testing.expectEqual(.unknown, output.command);
    //     try testing.expectEqual(0, output.arguments.len);
    // }

    {
        const output = try Parse(testing.allocator, "");
        defer testing.allocator.free(output.arguments);
        try testing.expectEqual(.unknown, output.command);
        try testing.expectEqual(0, output.arguments.len);
    }

    {
        const output = try Parse(testing.allocator, " ");
        defer testing.allocator.free(output.arguments);
        try testing.expectEqual(.unknown, output.command);
        try testing.expectEqual(0, output.arguments.len);
    }
}
