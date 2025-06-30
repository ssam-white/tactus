const std = @import("std");
const App = @import("App.zig");
// const apprt = @import("apprt.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var app = try App.create(alloc);
    defer app.destroy();
    try app.run();

    // var app_runtime = try apprt.App.init(app, .{});
    // defer app_runtime.terminate();

    // try app_runtime.run();
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
    // const level_txt = comptime level.asText();
    _ = level; _ = scope; _ = format; _ = args;
    // const prefix = if (scope == .default) ": " else "(" ++ @tagName(scope) ++ "): ";
    // _ = prefix;

    // std.debug.lockStdErr();
    // defer std.debug.unlockStdErr();

    // switch (state.logging) {
        // .disabled => {},
        // .stderr => {
            // const stderr = std.io.getStdErr().writer();
            // nosuspend stderr.print(level_txt ++ prefix ++ format ++ "\n", args) catch return;
        // },
    // }
}

pub const std_options: std.Options = .{
    .logFn = logFn
};
