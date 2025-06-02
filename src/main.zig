const std = @import("std");
const App = @import("App.zig");
const apprt = @import("apprt.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var app = try App.create(alloc);
    defer app.destroy();

    var app_runtime = try apprt.App.init(app, .{});
    defer app_runtime.terminate();

    try app_runtime.run();
}
