const Surface = @This();
const CoreSurface = @import("../../Surface.zig");
const Menu = @import("../../component/Menu.zig");
const brlapi = @import("../../lib/brlapi.zig");

pub fn display(core_surface: CoreSurface) void {
    switch (core_surface.focused_component.*) {
        .Menu => |menu| displayMenu(menu)
    };
}

fn displayMenu(menu: Menu) void {
    brlapi.writeText(menu.text) catch unreachable;
}
