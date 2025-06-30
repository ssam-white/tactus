const std = @import("std");
const apprt = @import("../apprt.zig");
const App = @import("../App.zig");
const rendererpkg = @import("../renderer.zig");
const Surface = @This();
const Component = @import("component.zig").Component;
const input = @import("../input.zig");

const Allocator = std.mem.Allocator;
const Renderer = rendererpkg.Renderer;
const log = std.log.scoped(.ui_surface);

const ComponentList = std.ArrayListUnmanaged(*Component);
const max_components: usize = 64;

components: ComponentList = .{},
num_components: usize = 0,
focused_component: ?*Component = null,
focused_component_index: ?usize = null,

pub fn create(alloc: Allocator) !*Surface {
    const surface_ptr = try alloc.create(Surface);
    errdefer alloc.destroy(surface_ptr);
    
    surface_ptr.* = .{};
    
    return surface_ptr;
}

pub fn destroy(self: *Surface, alloc: Allocator) void {
    for (self.components.items) |component| component.destroy(alloc);
    self.components.deinit(alloc);
    alloc.destroy(self);
}

pub fn addComponent(self: *Surface, alloc: Allocator, component: *Component) !void {
    try self.components.append(alloc, component);
    self.focused_component = component;
    self.num_components += 1;
    self.focused_component_index = self.num_components - 1;
}
