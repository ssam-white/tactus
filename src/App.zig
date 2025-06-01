const App = @This();
const std = @import("std");
const posix = std.posix;
const log = std.log.scoped(.App);
const apprt = @import("apprt.zig");
const Surface = @import("Surface.zig");

const Renderer = apprt.Renderer;

const Allocator = std.mem.Allocator;

const SurfaceList = std.ArrayListUnmanaged(*Surface);

alloc: Allocator,
surfaces: SurfaceList,
focused: bool = true,
focused_surface: ?*Surface = null,
renderer: *apprt.Renderer,

pub fn init(alloc: Allocator) !*App {
    const app_ptr = try create(alloc);
    const renderer_ptr = try alloc.create(Renderer);
    renderer_ptr.* = Renderer.init(alloc, app_ptr);

    app_ptr.* = .{
        .alloc = alloc,
        .surfaces = .{},
        .renderer = renderer_ptr,
    };
    
    return app_ptr;
}
pub fn create(alloc: Allocator) !*App {
    const app_ptr = try alloc.create(App);
    // errdefer alloc.destroy(app_ptr);
    return app_ptr;
}

pub fn destroy(self: *App) void {
    self.surfaces.destroy();
    self.alloc.destroy(self);
}

pub fn render(self: App) void {
    self.renderer.*.display() catch {
        log.err("failed to write to display", .{});
        posix.exit(1);
    };
}
