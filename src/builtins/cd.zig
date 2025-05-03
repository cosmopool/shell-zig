const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;
const AnyWriter = std.io.AnyWriter;
const CommandInput = @import("core").CommandInput;
const Environment = @import("core").Environment;
const strings = @import("core").strings;

pub fn run(allocator: std.mem.Allocator, user_input: [][]const u8, stderr: *AnyWriter, environment: *Environment) !void {
    assert(user_input.len > 0);
    assert(user_input.len <= 2);
    assert(std.mem.eql(u8, user_input[0], "cd"));

    var new_path: []const u8 = undefined;
    const is_absolute_path = user_input[1][0] == std.fs.path.sep;
    if (is_absolute_path) {
        new_path = user_input[1];
    } else {
        const paths_to_join = [2][]const u8{ environment.pwd, user_input[1] };
        const paths_joined = try std.fs.path.join(allocator, &paths_to_join);
        new_path = try std.fs.realpathAlloc(allocator, paths_joined);
    }

    std.fs.accessAbsolute(new_path, .{ .mode = .read_only }) catch {
        return printBadDir(stderr, new_path);
    };

    try environment.setPwd(new_path);
}

fn printBadDir(stderr: *AnyWriter, dir: []const u8) !void {
    return try stderr.print("cd: {s}: No such file or directory\n", .{dir});
}

test ".. to get to parent dir" {
    var stderr: std.io.AnyWriter = std.io.getStdErr().writer().any();
    var environ = try Environment.init(testing.allocator);
    const command_input = try CommandInput.parse(testing.allocator, "cd ..");

    try run(testing.allocator, command_input.arguments, &stderr, &environ);
    environ.reset();

    try run(testing.allocator, command_input.arguments, &stderr, &environ);
    environ.reset();
}
