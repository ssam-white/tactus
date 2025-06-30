const std = @import("std");
const Component = @import("../component.zig").Component;
const Surface = @import("../Surface.zig");
const App = @import("../../App.zig");

const Allocator = std.mem.Allocator;

pub fn create(alloc: Allocator) !*Surface {
    const menu_surface = try Surface.create(alloc);
    errdefer menu_surface.destroy(alloc);

    const menu = try Component.create(alloc);
    errdefer menu.destroy(alloc);
    
    menu.* = .{
        .menu = .{
            .items = &.{
                "Applications",
                "Settings",
                "Quit"
            }
        }
    };
    try menu_surface.addComponent(alloc, menu);

    return menu_surface;
}
