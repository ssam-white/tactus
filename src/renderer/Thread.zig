const Thread = @This();
const std = @import("std");
const log = std.log.scoped(.renderer_thread);
const App = @import("../App.zig");
const xev = @import("xev");
const rendererpkg = @import("../renderer.zig");

const Allocator = std.mem.Allocator;

alloc: Allocator,
loop: xev.Loop,
wakeup: xev.Async,
wakeup_c: xev.Completion = .{},
stop: xev.Async,
stop_c: xev.Completion = .{},
app_mailbox: App.Mailbox,

pub fn init(
    alloc: Allocator,
    app_mailbox: App.Mailbox
) !Thread {
    var loop = try xev.Loop.init(.{});
    errdefer loop.deinit();

    var wakeup_h = try xev.Async.init();
    errdefer wakeup_h.deinit();

    var stop_h = try xev.Async.init();
    errdefer stop_h.deinit();

    return .{
        .alloc = alloc,
        .loop = loop,
        .wakeup  = wakeup_h,
        .stop = stop_h,
        .app_mailbox = app_mailbox,
    };
}

pub fn deinit(self: *Thread) void {
    self.wakeup.deinit();
    self.stop.deinit();
    self.loop.deinit();
}

pub fn threadMain(self: *Thread) void {
    self.threadMain_() catch {
        log.warn("error in input thread", .{});
    };
}

fn threadMain_(self: *Thread) !void {
    defer log.debug("renderer thread exited", .{});

    self.wakeup.wait(&self.loop, &self.wakeup_c, Thread, self, wakeupCallback);
    self.stop.wait(&self.loop, &self.stop_c, Thread, self, stopCallback);

    try self.wakeup.notify();
    
    log.debug("starting renderer thread", .{});
    defer log.debug("shutting down renderer thread", .{});
    _ = try self.loop.run(.until_done);
}

fn wakeupCallback(
    self_: ?*Thread,
    _: *xev.Loop,
    _: *xev.Completion,
    r: xev.Async.WaitError!void
) xev.CallbackAction {
    _ = r catch |err| {
        log.err("error in wakup err={}", .{ err });
        return .rearm;
    };

    var t = self_.?;
    
    // _ = renderCallback(t, undefined, undefined, {});
    t.render() catch log.err("error rendering", .{});
    
    return .rearm;
}

    
fn stopCallback(
    self_: ?*Thread,
    _: *xev.Loop,
    _: *xev.Completion,
    r: xev.Async.WaitError!void
) xev.CallbackAction {
    _ = r catch {
        log.err("unexpected error with the renderer thread", .{});
    };
    self_.?.loop.stop();
    return .disarm;
}

fn rendererCallback(
    self_: ?*Thread,
    _: *xev.Loop,
    _: *xev.Completion,
    r: xev.Async.WaitError!void
) xev.CallbackAction {
    _ = r catch {
        log.err("unexpected error in renderer thread rendererCallback", .{});
    };
    const t: *Thread = self_ orelse {
        log.warn("render callback fired without data set", .{});
        return .disarm;
    };


    t.render() catch log.err("error rendering");
    
    return .disarm;
}

fn render(self: *Thread) !void {
    // _ = try self.app_mailbox.push(.{ .render }, .{ .instant });
    try self.app_mailbox.app.render();
}
