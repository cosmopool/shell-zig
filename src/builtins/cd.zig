const std = @import("std");
const testing = @import("std").testing;
const strings = @import("../strings.zig");
const Environment = @import("../environment.zig");
const assert = std.debug.assert;
const AnyWriter = std.io.AnyWriter;

pub fn run(allocator: std.mem.Allocator, input: [][]const u8, stdout: *AnyWriter, stderr: *AnyWriter, environment: *Environment) !void {
    _ = allocator; // autofix
    _ = stdout; // autofix
    assert(input.len > 1);
    assert(std.mem.eql(u8, input[0], "cd"));

    const target_path = input[1];
    std.fs.accessAbsolute(target_path, .{ .mode = .read_only }) catch {
        return try stderr.print("cd: {s}: No such file or directory\n", .{target_path});
    };
    environment.pwd = input[1];
}
