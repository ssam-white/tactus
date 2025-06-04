const std = @import("std");
const apprt = @import("../apprt.zig");
const App = @import("../App.zig");
const Surface = @This();
const Component = @import("component.zig").Component;
const input = @import("../input.zig");

const Allocator = std.mem.Allocator;
const log = std.log.scoped(.ui_surface);

const ComponentList = std.ArrayListUnmanaged(*Component);
const max_components: usize = 64;

components: ComponentList = .{},
num_components: usize = 0,
focused_component: ?*Component = null,
focused_component_index: ?usize = null,
input_thread: input.Thread,
input_thr: std.Thread,


pub fn create(alloc: Allocator, rt_app: *apprt.App, app: *App) !*Surface {
    const surface_ptr = try alloc.create(Surface);
    errdefer alloc.destroy(surface_ptr);
    
    const app_mailbox: App.Mailbox = .{ .rt_app = rt_app, .mailbox = &app.mailbox };
    var input_thread = try input.Thread.init(alloc, app_mailbox);
    errdefer input_thread.deinit();

    const input_thr = try std.Thread.spawn(
        .{},
        input.Thread.threadMain,
        .{ &surface_ptr.input_thread }
    );

    surface_ptr.* = .{
        .input_thread = input_thread,
        .input_thr = input_thr,
    };
    
    return surface_ptr;
}
pub fn display(self: Surface) void {
    apprt.Surface.display(self);
}

pub fn destroy(self: *Surface, alloc: Allocator) void {
    for (self.components.items) |component| component.destroy(alloc);
    self.components.deinit(alloc);

    self.input_thread.stop.notify() catch |err|
        log.err("error stopping the input thread err={}", .{err});
    self.input_thr.join();
    alloc.destroy(self);
}

pub fn addComponent(self: *Surface, alloc: Allocator, component: *Component) !void {
    try self.components.append(alloc, component);
    self.focused_component = component;
    self.num_components += 1;
    self.focused_component_index = self.num_components - 1;
}
