const std = @import("std");

pub const Level = enum {
    silent,
    err,
    warn,
    info,
    debug,

    pub fn toString(self: Level) []const u8 {
        return switch (self) {
            .silent => "silent",
            .err => "error",
            .warn => "warn",
            .info => "info",
            .debug => "debug",
        };
    }
};

var level: Level = .debug;

pub fn setLevel(new_level: Level) void {
    level = new_level;
}

pub fn getLevel() Level {
    return level;
}

pub fn log(min_level: Level, comptime fmt: []const u8, args: anytype) void {
    if (levelIsMin(min_level)) {
        std.debug.print("{s}: ", .{min_level.toString()});
        std.debug.print(fmt, .{args});
    }
}

pub fn levelIsMin(min_level: Level) bool {
    return @intFromEnum(min_level) <= @intFromEnum(getLevel());
}
