const std = @import("std");
const testing = @import("std").testing;
const Allocator = std.mem.Allocator;
const BuiltinCommands = @import("commands.zig").BuiltinCommands;
const CommandInput = @import("commands.zig").CommandInput;

/// Parse user input string into an command and it's arguments
pub fn parse(allocator: Allocator, inputString: []const u8) !CommandInput {
    const input = try splitInput(allocator, inputString);
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

/// Returns `true` if a string is compose of only spaces
fn hasOnlySpaces(input: []const u8) bool {
    for (input) |char| {
        if (char != ' ') return false;
    }
    return true;
}

fn splitInput(allocator: Allocator, input: []const u8) Allocator.Error![][]const u8 {
    if (input.len == 0) return try allocator.alloc([]const u8, 0);
    if (hasOnlySpaces(input)) return try allocator.alloc([]const u8, 0);
    if (input.len == 1) {
        var result = try allocator.alloc([]const u8, 1);
        result[0] = input;
        return result;
    }

    var input_splited = std.ArrayList([]const u8).init(allocator);
    errdefer input_splited.deinit();

    var startIndex: usize = 0;
    for (input, 0..) |char, i| {
        if (char != ' ') continue;
        if (i == 0 or input[i - 1] == ' ') {
            startIndex = i + 1;
            continue;
        }
        try input_splited.append(input[startIndex..i]);
        startIndex = i + 1;
    }

    if (startIndex != input.len) {
        try input_splited.append(input[startIndex..input.len]);
    }

    return try input_splited.toOwnedSlice();
}

test "split input string on spaces" {
    {
        const it = try splitInput(testing.allocator, "exit 0");
        defer testing.allocator.free(it);

        const expect = [_][]const u8{ "exit", "0" };
        try testing.expectEqual(2, it.len);
        try testing.expectEqualStrings(expect[0], it[0]);
        try testing.expectEqualStrings(expect[1], it[1]);
    }

    {
        const it = try splitInput(testing.allocator, "exit    ");
        defer testing.allocator.free(it);

        const expect = [_][]const u8{ "exit", "0" };
        try testing.expectEqual(1, it.len);
        try testing.expectEqualStrings(expect[0], it[0]);
    }

    {
        const it = try splitInput(testing.allocator, "abc def ghi");
        defer testing.allocator.free(it);

        const expect = [_][]const u8{ "abc", "def", "ghi" };
        try testing.expectEqual(3, it.len);
        try testing.expectEqualStrings(expect[0], it[0]);
        try testing.expectEqualStrings(expect[1], it[1]);
        try testing.expectEqualStrings(expect[2], it[2]);
    }

    {
        const it = try splitInput(testing.allocator, "abc  def ghi");
        defer testing.allocator.free(it);

        const expect = [_][]const u8{ "abc", "def", "ghi" };
        try testing.expectEqualSlices(u8, expect[0], it[0]);
        try testing.expectEqualSlices(u8, expect[1], it[1]);
        try testing.expectEqualSlices(u8, expect[2], it[2]);
        try testing.expectEqual(3, it.len);
    }

    {
        const it = try splitInput(testing.allocator, "    abc def ghi");
        defer testing.allocator.free(it);

        const expect = [_][]const u8{ "abc", "def", "ghi" };
        try testing.expectEqualSlices(u8, expect[0], it[0]);
        try testing.expectEqualSlices(u8, expect[1], it[1]);
        try testing.expectEqualSlices(u8, expect[2], it[2]);
        try testing.expectEqual(3, it.len);
    }

    {
        const it = try splitInput(testing.allocator, "abc          def     ghi");
        defer testing.allocator.free(it);

        const expect = [_][]const u8{ "abc", "def", "ghi" };
        try testing.expectEqualSlices(u8, expect[0], it[0]);
        try testing.expectEqualSlices(u8, expect[1], it[1]);
        try testing.expectEqualSlices(u8, expect[2], it[2]);
        try testing.expectEqual(3, it.len);
    }

    {
        const it = try splitInput(testing.allocator, "");
        defer testing.allocator.free(it);

        var expect = [_][]const u8{};
        try testing.expectEqual(0, it.len);
        try testing.expectEqualSlices([]const u8, &expect, it);
    }

    {
        const it = try splitInput(testing.allocator, " ");
        defer testing.allocator.free(it);

        var expect = [_][]const u8{};
        try testing.expectEqual(0, it.len);
        try testing.expectEqualSlices([]const u8, &expect, it);
    }

    {
        const it = try splitInput(testing.allocator, "    ");
        defer testing.allocator.free(it);

        var expect = [_][]const u8{};
        try testing.expectEqual(0, it.len);
        try testing.expectEqualSlices([]const u8, &expect, it);
    }

    {
        const it = try splitInput(testing.allocator, "|");
        defer testing.allocator.free(it);

        var expect = [_][]const u8{"|"};
        try testing.expectEqual(1, it.len);
        try testing.expectEqualSlices([]const u8, &expect, it);
    }

    {
        const it = try splitInput(testing.allocator, "hello");
        defer testing.allocator.free(it);

        var expect = [_][]const u8{"hello"};
        try testing.expectEqualSlices([]const u8, &expect, it);
        try testing.expectEqual(1, it.len);
    }
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

test "check if a string has only spaces" {
    try testing.expectEqual(true, hasOnlySpaces(" "));
    try testing.expectEqual(true, hasOnlySpaces("  "));
    try testing.expectEqual(true, hasOnlySpaces("   "));
    try testing.expectEqual(true, hasOnlySpaces("    "));

    try testing.expectEqual(false, hasOnlySpaces("    ."));
    try testing.expectEqual(false, hasOnlySpaces("."));
    try testing.expectEqual(false, hasOnlySpaces(".  "));

    try testing.expectEqual(false, hasOnlySpaces("    a"));
    try testing.expectEqual(false, hasOnlySpaces("a"));
    try testing.expectEqual(false, hasOnlySpaces("a  "));

    try testing.expectEqual(false, hasOnlySpaces("    0"));
    try testing.expectEqual(false, hasOnlySpaces("0"));
    try testing.expectEqual(false, hasOnlySpaces("0  "));
}
