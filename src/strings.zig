const std = @import("std");
const testing = @import("std").testing;
const Allocator = std.mem.Allocator;

/// Returns `true` if a string is compose of only spaces
pub fn hasOnlySpaces(input: []const u8) bool {
    for (input) |char| {
        if (char != ' ') return false;
    }
    return true;
}

pub fn split(allocator: Allocator, input: []const u8, separator: u8) Allocator.Error![][]const u8 {
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
        if (char != separator) continue;
        if (i == 0 or input[i - 1] == separator) {
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

pub fn join(allocator: Allocator, splitted: [][]const u8) ![]const u8 {
    var str = std.ArrayList(u8).init(allocator);
    errdefer str.deinit();

    for (splitted, 0..) |string, i| {
        for (string) |char| try str.append(char);
        if (i == splitted.len - 1) continue;
        try str.append(' ');
    }

    return try str.toOwnedSlice();
}

test "join input string" {
    {
        var splitted = [_][]const u8{ "hello", "world" };
        const expect = "hello world";
        const it = try join(testing.allocator, &splitted);
        defer testing.allocator.free(it);

        try testing.expectEqual(expect.len, it.len);
        try testing.expectEqualStrings(expect, it);
    }

    {
        var splitted = [_][]const u8{ "a", "b", "c", "d", "e" };
        const expect = "a b c d e";
        const it = try join(testing.allocator, &splitted);
        defer testing.allocator.free(it);

        try testing.expectEqual(expect.len, it.len);
        try testing.expectEqualStrings(expect, it);
    }
}

test "split input string on spaces" {
    {
        const it = try split(testing.allocator, "exit 0", ' ');
        defer testing.allocator.free(it);

        const expect = [_][]const u8{ "exit", "0" };
        try testing.expectEqual(2, it.len);
        try testing.expectEqualStrings(expect[0], it[0]);
        try testing.expectEqualStrings(expect[1], it[1]);
    }

    {
        const it = try split(testing.allocator, "exit    ", ' ');
        defer testing.allocator.free(it);

        const expect = [_][]const u8{ "exit", "0" };
        try testing.expectEqual(1, it.len);
        try testing.expectEqualStrings(expect[0], it[0]);
    }

    {
        const it = try split(testing.allocator, "abc def ghi", ' ');
        defer testing.allocator.free(it);

        const expect = [_][]const u8{ "abc", "def", "ghi" };
        try testing.expectEqual(3, it.len);
        try testing.expectEqualStrings(expect[0], it[0]);
        try testing.expectEqualStrings(expect[1], it[1]);
        try testing.expectEqualStrings(expect[2], it[2]);
    }

    {
        const it = try split(testing.allocator, "abc  def ghi", ' ');
        defer testing.allocator.free(it);

        const expect = [_][]const u8{ "abc", "def", "ghi" };
        try testing.expectEqualSlices(u8, expect[0], it[0]);
        try testing.expectEqualSlices(u8, expect[1], it[1]);
        try testing.expectEqualSlices(u8, expect[2], it[2]);
        try testing.expectEqual(3, it.len);
    }

    {
        const it = try split(testing.allocator, "    abc def ghi", ' ');
        defer testing.allocator.free(it);

        const expect = [_][]const u8{ "abc", "def", "ghi" };
        try testing.expectEqualSlices(u8, expect[0], it[0]);
        try testing.expectEqualSlices(u8, expect[1], it[1]);
        try testing.expectEqualSlices(u8, expect[2], it[2]);
        try testing.expectEqual(3, it.len);
    }

    {
        const it = try split(testing.allocator, "abc          def     ghi", ' ');
        defer testing.allocator.free(it);

        const expect = [_][]const u8{ "abc", "def", "ghi" };
        try testing.expectEqualSlices(u8, expect[0], it[0]);
        try testing.expectEqualSlices(u8, expect[1], it[1]);
        try testing.expectEqualSlices(u8, expect[2], it[2]);
        try testing.expectEqual(3, it.len);
    }

    {
        const it = try split(testing.allocator, "", ' ');
        defer testing.allocator.free(it);

        var expect = [_][]const u8{};
        try testing.expectEqual(0, it.len);
        try testing.expectEqualSlices([]const u8, &expect, it);
    }

    {
        const it = try split(testing.allocator, " ", ' ');
        defer testing.allocator.free(it);

        var expect = [_][]const u8{};
        try testing.expectEqual(0, it.len);
        try testing.expectEqualSlices([]const u8, &expect, it);
    }

    {
        const it = try split(testing.allocator, "    ", ' ');
        defer testing.allocator.free(it);

        var expect = [_][]const u8{};
        try testing.expectEqual(0, it.len);
        try testing.expectEqualSlices([]const u8, &expect, it);
    }

    {
        const it = try split(testing.allocator, "|", ' ');
        defer testing.allocator.free(it);

        var expect = [_][]const u8{"|"};
        try testing.expectEqual(1, it.len);
        try testing.expectEqualSlices([]const u8, &expect, it);
    }

    {
        const it = try split(testing.allocator, "hello", ' ');
        defer testing.allocator.free(it);

        var expect = [_][]const u8{"hello"};
        try testing.expectEqualSlices([]const u8, &expect, it);
        try testing.expectEqual(1, it.len);
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
