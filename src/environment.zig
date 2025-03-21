const std = @import("std");
const testing = std.testing;
const strings = @import("strings.zig");
const Directory = @import("directory.zig");

const Environment = @This();
pub const Error = error{
    PathNotSet,
};

/// `PATH` environmental variable already splited and in order
paths: std.MultiArrayList(Directory),

/// All environmental variable store as a HashMap
envs: std.StringHashMap([]const u8),

/// Returns a HashMap([]const u8, []const u8) with all environmental variables.
/// Caller owns the memory.
pub fn init(allocator: std.mem.Allocator) !Environment {
    var environ = std.StringHashMap([]const u8).init(allocator);
    for (std.os.environ) |env| {
        const pair = splitEnvIntoKeyValue(env);
        try environ.put(pair.key, pair.value);
    }
    const path_from_env = environ.get("PATH");
    if (path_from_env == null) return Error.PathNotSet;

    const env_path = try strings.split(allocator, path_from_env.?, ':');

    var paths = std.MultiArrayList(Directory){};
    for (env_path, 0..) |path, i| {
        const dir: std.fs.Dir = std.fs.openDirAbsolute(path, .{ .iterate = true }) catch |err| switch (err) {
            std.fs.File.OpenError.FileNotFound => continue,
            else => return err,
        };
        try paths.append(allocator, .{ .dir = dir, .path = env_path[i] });
    }

    return .{
        .envs = environ,
        .paths = paths,
    };
}

pub fn deinit(self: Environment, allocator: std.mem.Allocator) void {
    for (0..self.paths.len) |i| {
        const dir = self.paths.get(i);
        dir.deinit();
    }
    var paths = self.paths;
    paths.deinit(allocator);
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
