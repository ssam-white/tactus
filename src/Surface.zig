const std = @import("std");
const Surface = @This();
const apprt = @import("apprt.zig");
const Component = @import("component.zig").Component;
const max_components: usize = 64;

const Allocator = std.mem.Allocator;

components: [max_components]*Component,
num_components: usize = 0,
focused_component: *Component,
focused_component_index: usize,


pub fn create(alloc: Allocator) !*Surface {
    const surface_ptr = try alloc.create(Surface);
    errdefer alloc.destroy(surface_ptr);
    return surface_ptr;
}
pub fn display(self: Surface) void {
    apprt.Surface.display(self);
}

pub fn addComponent(self: *Surface, component: *Component) void {
    if (self.num_components >= max_components) return;
    self.components[self.num_components] = component;
    self.focused_component = component;
    self.focused_component_index = self.num_components;
    self.num_components += 1;
    
}
