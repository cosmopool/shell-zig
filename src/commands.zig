const std = @import("std");

pub const CommandInput = struct {
    command: BuiltinCommands,
    arguments: [][]const u8,
};

pub const BuiltinCommands = enum {
    unknown,
    exit,
    echo,
    type,
};
