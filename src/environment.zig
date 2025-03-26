const std = @import("std");
const testing = std.testing;
const strings = @import("strings.zig");

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
