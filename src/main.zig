const std = @import("std");
const App = @import("App.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var app = try App.create(alloc);
    defer app.destroy();
    try app.run();
}

test {
    _ = @import("datastruct/main.zig");
}
fn logFn(
    comptime level: std.log.Level,
    comptime scope: @TypeOf(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    // _ = level; _ = scope; _ = format; _ = args;

    const level_txt = comptime level.asText();
    const prefix = if (scope == .default) ": " else "(" ++ @tagName(scope) ++ "): ";

    std.debug.lockStdErr();
    defer std.debug.unlockStdErr();

    // switch (state.logging) {
    //     .disabled => {},
    //     .stderr => {
            const stderr = std.io.getStdErr().writer();
            nosuspend stderr.print(level_txt ++ prefix ++ format ++ "\n", args) catch return;
    //     },
    // }
}

pub const std_options: std.Options = .{
    .logFn = logFn
};
