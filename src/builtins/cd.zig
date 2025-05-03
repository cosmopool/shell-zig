const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;
const AnyWriter = std.io.AnyWriter;
const CommandInput = @import("core").CommandInput;
const Environment = @import("core").Environment;
const strings = @import("core").strings;

pub fn run(user_input: [][]const u8, stderr: *AnyWriter, environment: *Environment) !void {
    assert(user_input.len > 0);
    assert(user_input.len <= 2);
    assert(std.mem.eql(u8, user_input[0], "cd"));

    std.fs.accessAbsolute(user_input[1], .{ .mode = .read_only }) catch {
        return printBadDir(stderr, user_input[1]);
    };

    try environment.setPwd(user_input[1]);
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
