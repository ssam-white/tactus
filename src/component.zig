const std = @import("std");
const Menu = @import("component/Menu.zig");

const Allocator = std.mem.Allocator;

pub const Component = union(enum) {
    menu: Menu,

    pub fn create(alloc: Allocator) !*Component {
        const component_ptr = try alloc.create(Component);
        errdefer alloc.destroy(component_ptr);
        return component_ptr;
    }

    pub fn display(self: Component) void {
        switch (self) {
            inline else => |c| c.display()
        }
    }
};
