const std = @import("std");

pub const Directory = @This();

dir: std.fs.Dir,
path: []const u8,

pub fn deinit(self: Directory) void {
    var dir = self.dir;
    dir.close();
}

pub fn fullPath(self: Directory, allocator: std.mem.Allocator, other: []const u8) ![]const u8 {
    return try std.fs.path.join(allocator, &[_][]const u8{ self.path, other });
}
