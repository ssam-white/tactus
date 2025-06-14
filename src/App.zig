const App = @This();
const std = @import("std");
const posix = std.posix;
const log = std.log.scoped(.App);
const apprt = @import("apprt.zig");
const Surface = @import("ui/Surface.zig");
const BlockingQueue = @import("datastruct/main.zig").BlockingQueue;
const ui = @import("ui/main.zig");
const main_menu = ui.surfaces.main_menu;

const Allocator = std.mem.Allocator;

const SurfaceList = std.ArrayListUnmanaged(*Surface);

alloc: Allocator,
surfaces: SurfaceList,
focused: bool = true,
focused_surface: ?*Surface = null,
mailbox: Mailbox.Queue,

pub fn create(alloc: Allocator) !*App {
    const app_ptr = try alloc.create(App);
    errdefer alloc.destroy(app_ptr);

    app_ptr.* = .{
        .alloc = alloc,
        .surfaces = .{},
        .mailbox = .{},
    };
    errdefer app_ptr.surfaces.deinit(alloc);
    
    return app_ptr;
}

pub fn destroy(self: *App) void {
    log.debug("destroying app", .{});
    for (self.surfaces.items) |surface| surface.destroy(self.alloc);
    self.surfaces.deinit(self.alloc);

    self.alloc.destroy(self);
}

pub fn addSurface(self: *App, surface: *Surface) !void {
    try self.surfaces.append(self.alloc, surface);
    _ = self.mailbox.push(.{ .redraw_surface = surface }, .{ .forever = {} });
}

pub fn setup(self: *App, rt_app: *apprt.App) !void {
    const new_surface = try main_menu.create(self.alloc, rt_app, self);
    _ = self.mailbox.push(.{ .new_surface = new_surface }, .{ .instant = {} });
    _ = self.mailbox.push(.{ .redraw_surface = new_surface }, .{ .instant = {}});
    _ = self.mailbox.push(.{ .quit = {}}, .{ .instant = {}});
    
}

pub fn tick(self: *App, rt_app: *apprt.App) !void {
    try self.drainMailbox(rt_app);
}

fn drainMailbox(self: *App, rt_app: *apprt.App) !void {
    while (self.mailbox.pop()) |message| {
        log.debug("mailbox message = {s}", .{ @tagName(message) });
        switch (message) {
            .new_surface => |surface| try self.addSurface(surface),
            .redraw_surface => |surface| self.redrawSurface(rt_app, surface),
            .quit => {
                log.info("quit message recieved", .{});
                self.quit(rt_app);
                return;
            }
        }
    }
}

fn redrawSurface(self: *App, rt_app: *apprt.App, surface: *Surface) void {
    _ = self; _ = rt_app;
    apprt.Surface.redrawSurface(surface);
}

pub const Message = union(enum) {
    new_surface: *Surface,
    redraw_surface: *Surface,
    quit: void,
};

pub fn quit(self: *App, rt_app: *apprt.App) void {
    _ = self;
    rt_app.quit();
}
// pub fn performAction(
//     self: *App,
//     rt_app: *apprt.App,
//     action: input.Binding.Action.Scoped(.app)
// ) !void {
//         switch (action) {
//         }
// }

pub const Mailbox = struct {
    pub const Queue = BlockingQueue(Message, 64);

    rt_app: *apprt.App,
    mailbox: *Queue,

    pub fn push(self: Mailbox, msg: Message, timeout: Queue.Timeout) !Queue.Size {
        const result = self.mailbox.push(msg, timeout);
        self.rt_app.wakeup();
        return result;
    }
};
