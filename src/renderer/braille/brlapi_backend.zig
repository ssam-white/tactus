const App = @import("../../App.zig");
const std = @import("std");
const log = std.log.scoped(.brlapi_backend);
const brlapi = @import("brlapi.zig");

pub fn start() !void {
    log.info("opening brltty connection", .{});
    _ = try brlapi.openConnection(.{});
    log.info("entering tty mode", .{});
    _ = try brlapi.enterTtyMode(1, null);
}

pub fn display(app: *App) brlapi.BrlapiError!void {
    _ = app;
    try brlapi.writeText(0, "test");
}
