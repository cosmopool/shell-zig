const std = @import("std");

pub const BuiltinCommands = enum { exit, unknown };

pub const CommandInput = struct {
    command: BuiltinCommands,
    arguments: [][]const u8,
};
