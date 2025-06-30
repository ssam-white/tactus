const Surface = @This();
const std = @import("std");
const App = @import("App.zig");
const apprt = @import("../../apprt.zig");
const vaxis = @import("vaxis");
const ui = @import("../../ui/main.zig");
const CoreSurface = ui.Surface;
const Menu = ui.components.Menu;

const Allocator = std.mem.Allocator;

app: *App,

pub fn init(app: *App) Surface {
    return .{
        .app = app
    };
}

pub fn create(alloc: Allocator, app: *App) !*Surface {
    const surface_ptr = try alloc.create(Surface);
    surface_ptr.* = .init(app);
    return surface_ptr;
}


pub fn redraw(self: *Surface) void {        
    _ = self;
}

