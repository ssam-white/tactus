const std = @import("std");
const Component = @import("../component.zig").Component;
const Surface = @import("../Surface.zig");

const Allocator = std.mem.Allocator;

pub fn create(alloc: Allocator) !*Surface {
    const menu_surface = try Surface.create(alloc);
    const menu = try Component.create(alloc);
    menu.* = .{
        .menu = .{
            .text = "L"
        }
    };
    menu_surface.* = .{};
    try menu_surface.addComponent(alloc, menu);
    return menu_surface;
}
