const App = @This();
const std = @import("std");
const posix = std.posix;
const log = std.log.scoped(.App);
const BlockingQueue = @import("datastruct/main.zig").BlockingQueue;
const ui = @import("ui/main.zig");
const rendererpkg = @import("renderer.zig");

const Surface = ui.Surface;
const main_menu = ui.surfaces.main_menu;
const Renderer = rendererpkg.Renderer;
const SurfaceList = std.ArrayListUnmanaged(*Surface);
const Allocator = std.mem.Allocator;

alloc: Allocator,
surfaces: SurfaceList,
focused_surface: ?*Surface = null,
// the mailbox allows other threads to send messages to the main thread
mailbox: Mailbox.Queue,
running: bool = true,
// renderer fields
renderer_thread: rendererpkg.Thread,
renderer_thr: std.Thread,
// for sleeping and waking up the main thread
sleep_cond: std.Thread.Condition = .{},
sleep_mutex: std.Thread.Mutex = .{},

pub fn create(alloc: Allocator) !*App {
    const app_ptr = try alloc.create(App);
    errdefer alloc.destroy(app_ptr);



    app_ptr.* = .{
        .alloc = alloc,
        .surfaces = .{},
        .mailbox = .{},
        .renderer_thread = undefined,
        .renderer_thr = undefined,
    };
    errdefer app_ptr.surfaces.deinit(alloc);

    const app_mailbox: Mailbox = .{ .app = app_ptr, .mailbox = &app_ptr.mailbox };
    app_ptr.renderer_thread = try rendererpkg.Thread.init(alloc, app_mailbox);
    app_ptr.renderer_thr = try std.Thread.spawn(
        .{},
        rendererpkg.Thread.threadMain,
        .{ &app_ptr.renderer_thread },
    );
    app_ptr.renderer_thr.setName("renderer") catch {};

    return app_ptr;
}

pub fn destroy(self: *App) void {
    log.debug("destroying app", .{});
    for (self.surfaces.items) |surface| surface.destroy(self.alloc);
    self.surfaces.deinit(self.alloc);

    self.alloc.destroy(self);

    Renderer.stop();
}

pub fn addSurface(self: *App, surface: *Surface) !void {
    try self.surfaces.append(self.alloc, surface);
    self.focused_surface = surface;
}

pub fn setup(self: *App) !void {
    Renderer.start();
    
    const new_surface = try main_menu.create(self.alloc);
    errdefer new_surface.destroy(self.alloc);

    try self.addSurface(new_surface);
    self.render();
    
}

pub fn tick(self: *App) !void {
    try self.drainMailbox();
}

fn drainMailbox(self: *App) !void {
    while (self.mailbox.pop()) |message| {
        log.debug("mailbox message = {s}", .{ @tagName(message) });
        switch (message) {
            .new_surface => |surface| try self.addSurface(surface),
            .render => self.render(),
            .quit => {
                log.info("quit message recieved", .{});
                self.quit();
                return;
            }
        }
    }
}

pub const Message = union(enum) {
    new_surface: *Surface,
    render,
    quit,
};

pub fn quit(self: *App) void {
    self.running = false;
}

pub const Mailbox = struct {
    pub const Queue = BlockingQueue(Message, 64);

    app: *App,
    mailbox: *Queue,

    pub fn push(self: Mailbox, msg: Message, timeout: Queue.Timeout) !Queue.Size {
        const result = self.mailbox.push(msg, timeout);
        self.app.wakeup();
        return result;
    }
};

fn render(self: *App) void {
    log.debug("rendering", .{});
    Renderer.render(self);
}

pub fn run(self: *App) !void {
    try self.setup();
    while (self.running) {
        self.sleep();
        try self.tick();
    }
}

pub fn sleep(self: *App) void {
    self.sleep_mutex.lock();
    defer self.sleep_mutex.unlock();
    self.sleep_cond.wait(&self.sleep_mutex);
}

pub fn wakeup(self: *App) void {
    self.sleep_mutex.lock();
    defer self.sleep_mutex.unlock();
    self.sleep_cond.signal();
}
