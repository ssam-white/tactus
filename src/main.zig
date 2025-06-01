const std = @import("std");
const App = @import("App.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var app = try App.init(alloc);
    defer app.destroy();

    app.render();

    while (true) {}
}
