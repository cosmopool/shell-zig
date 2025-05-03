const std = @import("std");
const testing = std.testing;
const strings = @import("strings.zig");

const Environment = @This();
pub const Error = error{
    PathNotSet,
};

allocator: std.mem.Allocator,

/// `PATH` environmental variable already splited and in order
paths: std.mem.SplitIterator(u8, .scalar),

/// All environmental variable store as a HashMap
envs: std.process.EnvMap,

pwd: []u8,

/// Returns an Environment with all environmental variables.
pub fn init(allocator: std.mem.Allocator) !Environment {
    const envs = try std.process.getEnvMap(allocator);
    const path_from_env = envs.get("PATH") orelse return Error.PathNotSet;
    const paths = std.mem.splitScalar(u8, path_from_env, ':');

    const pwd = try std.fs.cwd().realpathAlloc(allocator, ".");

    return .{
        .envs = envs,
        .paths = paths,
        .pwd = pwd,
        .allocator = allocator,
    };
}

pub fn reset(self: *Environment) void {
    self.paths.reset();
}

pub fn setPwd(self: *Environment, new_pwd: []const u8) !void {
    self.allocator.free(self.pwd);
    self.pwd = try self.allocator.dupe(u8, new_pwd);
}
