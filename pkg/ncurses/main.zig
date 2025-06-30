const c = @import("c.zig").c;

const Error = error {
    Initscr,
    Endwin,
    Clear,
    Refresh,
    CursSet,
    Move,
    Printw,
};

pub fn initscr() Error!*c.struct__win_st {
    if (c.initscr()) |window|
        return window
    else
        return Error.Initscr;
}

pub fn endwin() Error!void {
    if (c.endwin() < 0) {
        return Error.Endwin;
    }
}

pub fn clear() Error!void {
    if (c.clear() < 0) {
        return Error.Clear;
    }
}

pub fn refresh() Error!void {
    if (c.refresh() < 0) {
        return Error.Refresh;
    }
}

pub fn cursSet(show_cursor: bool) Error!void {
    const show: c_int = if (show_cursor) 1 else 0;
    if (c.curs_set(show) < 0) {
        return Error.CursSet;
    }
}

pub fn move(x: i32, y: i32) Error!void {
    const x_c_int: c_int = @intCast(x);
    const y_c_int: c_int = @intCast(y);
    if (c.move(x_c_int, y_c_int) < 0) {
        return Error.Move;
    }
}

pub fn printw(text: []const u8) Error!void {
    const c_text: [*c]const u8 = &text[0];
    if (c.printw(c_text) < 0) {
        return Error.Printw;
    }
}
