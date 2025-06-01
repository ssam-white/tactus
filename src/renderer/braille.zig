const Braille = @This();
const std = @import("std");
const posix = std.posix;
const log = std.log.scoped(.brlapi_backend);
const App = @import("../App.zig");
const brlapi = @import("braille/brlapi_backend.zig");

const Allocator = std.mem.Allocator;

const Impl = enum {
    brlapi,

    pub const default: Impl = .brlapi;
};

pub const Backend = switch (Impl.default) {
    .brlapi => brlapi
};

alloc: Allocator,
app: *App,

pub fn init(alloc: Allocator, app: *App) Braille {
    Backend.start() catch {
        log.err("somthing went wrong initialising brlapo", .{});
        posix.exit(1);
    };
    return .{
        .alloc = alloc,
        .app = app,
    };
}

pub fn display (self: Braille) !void {
    try Backend.display(self.app);
}


pub fn main() !void {
    _ = try brlapi.openConnection(.{});
    defer brlapi.closeConnection();

    var buf: [brlapi.max_name_length + 1]u8 = undefined;
    try brlapi.getDriverName(&buf);
    std.debug.print("Driver name: {s}\n", .{std.mem.sliceTo(buf[0..], 0)});

    const x, const y = try brlapi.getDisplaySize();
    std.debug.print("Braille display has {} line{s} of {} column{s}\n", .{ y, if (y > 1) "s" else "", x, if (x > 1) "s" else "" });

    std.debug.print("Trying to enter raw mode... ", .{});
    if (brlapi.enterRawMode(buf)) {
        std.debug.print("Ok, leaving raw mode immediately\n", .{});
        try brlapi.leaveRawMode();
    } else |_| {}

    std.debug.print("Taking control of the tty... ", .{});
    const tty = try brlapi.enterTtyMode(1, null);
    _ = tty;
    std.debug.print("Ok\n", .{});

    std.debug.print("Writing to braille display... ", .{});
    try brlapi.writeText(0, "Press a braille key to continue...");
    std.debug.print("Ok\n", .{});

    std.debug.print("Waiting for a braille key... ", .{});
    const key = try brlapi.readKey(true);
    std.debug.print("\nGot key! code = {x}\n", .{key});

    const ekey = try brlapi.expandKeyCode(key);
    std.debug.print("expanded key: type {x}, command {x}, argument {x}, flags {x}\n", .{ ekey.type, ekey.command, ekey.argument, ekey.flags });

    const dkey = try brlapi.describeKeyCode(key);
    std.debug.print("descried key: type {s}, command {s}, argument {x}, flags:", .{ dkey.type, dkey.command, dkey.argument });
    for (0..dkey.flags) |i| {
        std.debug.print(" {s}", .{dkey.flag[i]});
    }
    std.debug.print("\n", .{});

    std.debug.print("Leaving tty... ", .{});
    try brlapi.leaveTtyMode();
    std.debug.print("Ok\n", .{});
}
