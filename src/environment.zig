const std = @import("std");
const testing = std.testing;
const strings = @import("strings.zig");
const Directory = @import("directory.zig");

const Environment = @This();
pub const Error = error{
    PathNotSet,
};

/// `PATH` environmental variable already splited and in order
paths: std.mem.SplitIterator(u8, .scalar),

/// All environmental variable store as a HashMap
envs: std.process.EnvMap,

/// Returns an Environment with all environmental variables.
pub fn init(allocator: std.mem.Allocator) !Environment {
    const envs = try std.process.getEnvMap(allocator);
    const path_from_env = envs.get("PATH") orelse return Error.PathNotSet;
    const paths = std.mem.splitScalar(u8, path_from_env, ':');

    return .{
        .envs = envs,
        .paths = paths,
    };
}

pub fn reset(self: *Environment) void {
    self.paths.reset();
}

fn splitEnvIntoKeyValue(env: [*:0]u8) struct { key: []const u8, value: []const u8 } {
    var i: isize = -1;
    var char: u8 = env[0];
    var separator: isize = -1;
    while (char != 0) {
        i += 1;
        char = env[@intCast(i)];
        if (char != '=') continue;
        if (separator > -1) continue;
        separator = i;
    }
    if (separator < 0 and i > 0) return .{ .key = env[0..@as(usize, @intCast(i))], .value = "" };
    const key: []const u8 = env[0..@intCast(separator)];
    const value = env[@as(usize, @intCast(separator)) + 1 .. @as(usize, @intCast(i))];
    return .{ .key = key, .value = value };
}

test splitEnvIntoKeyValue {
    // split key value with separator in the middle
    {
        const str: [*:0]u8 = @constCast("hello=world");
        const result = splitEnvIntoKeyValue(str);
        try testing.expectEqualStrings("hello", result.key);
        try testing.expectEqualStrings("world", result.value);
    }

    // split key value with multiple separators
    {
        const str: [*:0]u8 = @constCast("hello=world====asdf");
        const result = splitEnvIntoKeyValue(str);
        try testing.expectEqualStrings("hello", result.key);
        try testing.expectEqualStrings("world====asdf", result.value);
    }

    // split key value with separator at the begining
    {
        const str: [*:0]u8 = @constCast("=hello");
        const result = splitEnvIntoKeyValue(str);
        try testing.expectEqualStrings("", result.key);
        try testing.expectEqualStrings("hello", result.value);
    }

    // split key value with seprator at the end
    {
        const str: [*:0]u8 = @constCast("hello=");
        const result = splitEnvIntoKeyValue(str);
        try testing.expectEqualStrings("hello", result.key);
        try testing.expectEqualStrings("", result.value);
    }

    // split key value with no separator
    {
        const str: [*:0]u8 = @constCast("helloworld");
        const result = splitEnvIntoKeyValue(str);
        try testing.expectEqualStrings("helloworld", result.key);
        try testing.expectEqualStrings("", result.value);
    }
}
