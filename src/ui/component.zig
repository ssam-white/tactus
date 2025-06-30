const std = @import("std");
const rendererpkg = @import("../renderer.zig");
const Menu = @import("components/Menu.zig");

const Allocator = std.mem.Allocator;
const Renderer = rendererpkg.Renderer;

pub const Component = union(enum) {
    menu: Menu,

    pub fn create(alloc: Allocator) !*Component {
        const component_ptr = try alloc.create(Component);
        errdefer alloc.destroy(component_ptr);
        return component_ptr;
    }

    pub fn destroy(self: *Component, alloc: Allocator) void {
        alloc.destroy(self);
    }

    pub fn render(self: Component) !void {
        switch (self) {
            .menu => |m| try Renderer.renderMenu(m),
        }
    }
};
