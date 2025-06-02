const std = @import("std");
const cdef = @cImport({
    @cInclude("brlapi.h");
});

pub const BrlapiError = error{ OpenConnection, GetDriverName, GetDisplaySize, EnterRawMode, LeaveRawMode, EnterTtyMode, WriteText, ReadKey, ExpandKeyCode, DescribeKeyCode, LeaveTtyMode };

const ConnectionSettings = extern struct {
    auth: ?[*:0]const u8 = null,
    host: ?[*:0]const u8 = null,
};

pub const max_name_length = cdef.BRLAPI_MAXNAMELENGTH;

pub fn perror(msg: []const u8) void {
    // if (log.levelIsMin(.err)) {
        const c_msg: [*c]const u8 = &msg[0];
        cdef.brlapi_perror(c_msg);
    // }
}

pub fn openConnection(connection_settings: ConnectionSettings) BrlapiError!ConnectionSettings {
    const raw_settings: *const cdef.brlapi_connectionSettings_t = @ptrCast(&connection_settings);
    var chosen_settings: cdef.brlapi_connectionSettings_t = undefined;

    if (cdef.brlapi_openConnection(raw_settings, &chosen_settings) < 0) {
        perror("brlapi.openConnection()");
        return BrlapiError.OpenConnection;
    }
    return @as(*ConnectionSettings, @ptrCast(&chosen_settings)).*;
}

pub fn closeConnection() void {
    cdef.brlapi_closeConnection();
}

pub fn getDriverName(buf: *[max_name_length + 1]u8) BrlapiError!void {
    const name: [*c]u8 = &buf[0];
    if (cdef.brlapi_getDriverName(name, buf.len) < 0) {
        perror("brlapi.getDriverName()");
        return BrlapiError.GetDriverName;
    }
}

pub fn getDisplaySize() BrlapiError!struct { i32, i32 } {
    var x: i32 = undefined;
    var y: i32 = undefined;
    if (cdef.brlapi_getDisplaySize(@ptrCast(&x), @ptrCast(&y)) < 0) {
        perror("brlapi.getDisplaySize()");
        return BrlapiError.GetDisplaySize;
    }
    return .{ x, y };
}

pub fn enterRawMode(name: [max_name_length + 1]u8) BrlapiError!void {
    if (cdef.brlapi_enterRawMode(&name[0]) < 0) {
        perror("brlapi.enterRawMode()");
        return BrlapiError.EnterRawMode;
    }
}

pub fn leaveRawMode() BrlapiError!void {
    if (cdef.brlapi_leaveRawMode() < 0) {
        perror("brlapi.LeaveRawMode()");
        return BrlapiError.LeaveRawMode;
    }
}

pub fn enterTtyMode(tty_number: i32, driver: ?[]const u8) BrlapiError!i32 {
    const tty_number_c_int: c_int = @intCast(tty_number);
    const driver_c_string: [*c]const u8 = if (driver) |d| &d[0] else null;
    const res: c_int = cdef.brlapi_enterTtyMode(tty_number_c_int, driver_c_string);
    return if (res < 0) blk: {
        perror("brlapi.enterTtyMode()");
        break :blk BrlapiError.EnterTtyMode;
    } else @intCast(res);
}

pub fn leaveTtyMode() BrlapiError!void {
    if (cdef.brlapi_leaveTtyMode() < 0) {
        perror("brlapi.leaveTtyMode()");
        return BrlapiError.LeaveTtyMode;
    }
}

pub fn writeText(cursor_pos: i32, text: []const u8) BrlapiError!void {
    const cursor_pos_c_int: c_int = @intCast(cursor_pos);
    const text_c_string: [*c]const u8 = &text[0];
    if (cdef.brlapi_writeText(cursor_pos_c_int, text_c_string) < 0) {
        perror("brlapi.writeText()");
        return BrlapiError.WriteText;
    }
}

pub const KeyCode = u54;

pub fn readKey(wait: bool) BrlapiError!KeyCode {
    var key: KeyCode = undefined;
    const wait_c_int: c_int = if (wait) 1 else 0;
    const keyCode_c: *cdef.brlapi_keyCode_t = @ptrCast(&key);
    if (cdef.brlapi_readKey(wait_c_int, keyCode_c) < 0) {
        perror("brlapi.readKey()");
        return BrlapiError.ReadKey;
    }
    return key;
}

pub const ExpandedKeyCode = extern struct {
    type: u32,
    command: u32,
    argument: u32,
    flags: u32,

    pub fn fromC(ekey: cdef.brlapi_expandedKeyCode_t) ExpandedKeyCode {
        return .{ .type = @intCast(ekey.type), .command = @intCast(ekey.command), .argument = @intCast(ekey.argument), .flags = @intCast(ekey.flags) };
    }
};

pub fn expandKeyCode(key_code: KeyCode) BrlapiError!ExpandedKeyCode {
    const key_code_c: cdef.brlapi_keyCode_t = @intCast(key_code);
    var ekey: cdef.brlapi_expandedKeyCode_t = undefined;
    if (cdef.brlapi_expandKeyCode(key_code_c, &ekey) < 0) {
        perror("brlapi.expandKeyCode()");
        return BrlapiError.ExpandKeyCode;
    }
    return ExpandedKeyCode.fromC(ekey);
}

const key_flags_shift = cdef.BRLAPI_KEY_FLAGS_SHIFT;

pub const DescribedKeyCode = struct {
    type: []const u8,
    command: []const u8,
    argument: u32,
    flags: u32,
    flag: [64 - key_flags_shift][]const u8,
    values: ExpandedKeyCode,
};

pub fn describeKeyCode(key: KeyCode) BrlapiError!DescribedKeyCode {
    const key_c: cdef.brlapi_keyCode_t = @intCast(key);
    var dkey: cdef.brlapi_describedKeyCode_t = undefined;
    if (cdef.brlapi_describeKeyCode(key_c, &dkey) < 0) {
        perror("brlapi.describeKeyCode()");
        return BrlapiError.DescribeKeyCode;
    }
    var flag: [64 - key_flags_shift][]const u8 = undefined;
    for (0..dkey.flags) |i| {
        flag[i] = std.mem.sliceTo(dkey.flag[i], 0);
    }
    return .{
        .type = std.mem.sliceTo(dkey.type, 0),
        .command = std.mem.sliceTo(dkey.command, 0),
        .argument = @intCast(dkey.argument),
        .flags = @intCast(dkey.flags),
        .flag = flag,
        .values = ExpandedKeyCode.fromC(dkey.values),
    };
}
