const std = @import("std");
const testing = @import("std").testing;
const Allocator = std.mem.Allocator;
const BuiltinCommands = @import("commands.zig").BuiltinCommands;
const CommandInput = @import("commands.zig").CommandInput;
const Strings = @import("strings.zig");

/// Parse user input string into an command and it's arguments
pub fn parse(allocator: Allocator, inputString: []const u8) !CommandInput {
    const input = try Strings.split(allocator, inputString, ' ');
    errdefer allocator.free(input);
    if (input.len == 0) {
        return CommandInput{ .command = .unknown, .arguments = &.{} };
    }

    const builtinCommand = std.meta.stringToEnum(BuiltinCommands, input[0]) orelse {
        const args = try allocator.alloc([]const u8, 0);
        return CommandInput{ .command = .unknown, .arguments = args };
    };
    return CommandInput{ .command = builtinCommand, .arguments = input };
}

test "parsing input string" {
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
