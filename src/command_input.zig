const std = @import("std");
const testing = @import("std").testing;
const Allocator = std.mem.Allocator;
const strings = @import("strings.zig");

pub const BuiltinCommands = enum {
    unknown,
    exit,
    echo,
    type,
};

pub const CommandInput = @This();

command: BuiltinCommands,
arguments: [][]const u8,

/// Parse user input string into an command and it's arguments
pub fn parse(allocator: Allocator, input_string: []const u8) !CommandInput {
    const input = try strings.split(allocator, input_string, ' ');
    errdefer allocator.free(input);

    if (input.len == 0) return .{ .command = .unknown, .arguments = &.{} };

    const builtin_command = std.meta.stringToEnum(BuiltinCommands, input[0]) orelse .unknown;
    return .{ .command = builtin_command, .arguments = input };
}

test parse {
    {
        const output = try parse(testing.allocator, "exit 0");
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
        const output = try parse(testing.allocator, "");
        defer testing.allocator.free(output.arguments);
        try testing.expectEqual(.unknown, output.command);
        try testing.expectEqual(0, output.arguments.len);
    }

    {
        const output = try parse(testing.allocator, " ");
        defer testing.allocator.free(output.arguments);
        try testing.expectEqual(.unknown, output.command);
        try testing.expectEqual(0, output.arguments.len);
    }
}
