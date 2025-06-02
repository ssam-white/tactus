const std = @import("std");
const Surface = @This();
const apprt = @import("../apprt.zig");
const Component = @import("component.zig").Component;

const max_components: usize = 64;

const Allocator = std.mem.Allocator;

const ComponentList = std.ArrayListUnmanaged(*Component);

components: ComponentList = .{},
num_components: usize = 0,
focused_component: ?*Component = null,
focused_component_index: ?usize = null,


pub fn create(alloc: Allocator) !*Surface {
    const surface_ptr = try alloc.create(Surface);
    errdefer alloc.destroy(surface_ptr);
    return surface_ptr;
}
pub fn display(self: Surface) void {
    apprt.Surface.display(self);
}

pub fn addComponent(self: *Surface, alloc: Allocator, component: *Component) !void {
    try self.components.append(alloc, component);
    self.focused_component = component;
    self.num_components += 1;
    self.focused_component_index = self.num_components - 1;
}
