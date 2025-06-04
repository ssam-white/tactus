const std = @import("std");
const Component = @import("../component.zig").Component;
const Surface = @import("../Surface.zig");
const apprt = @import("../../apprt.zig");
const App = @import("../../App.zig");

const Allocator = std.mem.Allocator;

pub fn create(alloc: Allocator, rt_app: *apprt.App, app: *App) !*Surface {
    const menu_surface = try Surface.create(alloc, rt_app, app);
    const menu = try Component.create(alloc);
    menu.* = .{
        .menu = .{
            .text = "L"
        }
    };
    try menu_surface.addComponent(alloc, menu);
    return menu_surface;
}
