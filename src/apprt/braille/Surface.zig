const Surface = @This();
const std = @import("std");
const CoreSurface = @import("../../ui/Surface.zig");
const ui = @import("../../ui/main.zig");
const Menu = ui.components.Menu;
const brlapi = @import("../../lib/brlapi.zig");

pub fn redrawSurface(core_surface: *CoreSurface) void {
    if (core_surface.focused_component) |component| {
        switch (component.*) {
            .menu => |surface| displayMenu(surface)
        }
    }
}

fn displayMenu(menu: Menu) void {
    brlapi.writeText(0, menu.text) catch std.posix.exit(1);
}
