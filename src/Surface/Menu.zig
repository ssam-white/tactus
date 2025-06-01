const Menu = @This();
const Surface = @import("../Surface.zig");


text: []const u8,
renderer: *apprt.Renderer,

pub fn create(alloc: Allocator) !*Menu {
    return try alloc.create(Menu);
}

pub fn init(self: *Menu, text: []const u8) *Menu {
    self.* = .{
        .text = text
    };
    return self;
}

pub fn display(self: Menu) void {
    self.renderer.display(self.text);
}

pub fn surface(self: Menu) Surface {
    return Surface.init(&self);
}
