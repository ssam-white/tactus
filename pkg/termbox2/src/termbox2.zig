const std = @import("std");
const opts = @import("build_options");
const c = @cImport({
    // @cDefine("TB_IMPL", {});
    // @cDefine("TB_LIB_OPTS", {});
    if (opts.attr_w != 0) {
        @cDefine("TB_OPT_ATTR_W", std.fmt.comptimePrint("{}", .{opts.attr_w}));
    }
    if (opts.egc) {
        @cDefine("TB_OPT_EGC", {});
    }
    if (opts.printf_buf != 0) {
        @cDefine("TB_OPT_PRINTF_BUF", std.fmt.comptimePrint("{}", .{opts.printf_buf}));
    }
    if (opts.read_buf != 0) {
        @cDefine("TB_OPT_READ_BUF", std.fmt.comptimePrint("{}", .{opts.read_buf}));
    }
    @cInclude("termbox2.h");
});

pub const TermboxError = error{
    Ok,
    Err,
    NeedMore,
    InitAlready,
    InitOpen,
    Mem,
    NoEvent,
    NoTerm,
    NotInit,
    OutOfBounds,
    Read,
    ResizeIoctl,
    ResizePipe,
    ResizeSigaction,
    Poll,
    Tcgetattr,
    Tcsetattr,
    UnsupportedTerm,
    ResizeWrite,
    ResizePoll,
    ResizeRead,
    ResizeSscanf,
    CapCollision,
};

fn tbToError(tb: c_int) TermboxError {
    return switch (tb) {
        c.TB_OK => TermboxError.Ok,
        c.TB_ERR => TermboxError.Err,
        c.TB_ERR_NEED_MORE => TermboxError.NeedMore,
        c.TB_ERR_INIT_ALREADY => TermboxError.InitAlready,
        c.TB_ERR_INIT_OPEN => TermboxError.InitOpen,
        c.TB_ERR_MEM => TermboxError.Mem,
        c.TB_ERR_NO_EVENT => TermboxError.NoEvent,
        c.TB_ERR_NO_TERM => TermboxError.NoTerm,
        c.TB_ERR_NOT_INIT => TermboxError.NotInit,
        c.TB_ERR_OUT_OF_BOUNDS => TermboxError.OutOfBounds,
        c.TB_ERR_READ => TermboxError.Read,
        c.TB_ERR_RESIZE_IOCTL => TermboxError.ResizeIoctl,
        c.TB_ERR_RESIZE_PIPE => TermboxError.ResizePipe,
        c.TB_ERR_RESIZE_SIGACTION => TermboxError.ResizeSigaction,
        c.TB_ERR_POLL => TermboxError.Poll,
        c.TB_ERR_TCGETATTR => TermboxError.Tcgetattr,
        c.TB_ERR_TCSETATTR => TermboxError.Tcsetattr,
        c.TB_ERR_UNSUPPORTED_TERM => TermboxError.UnsupportedTerm,
        c.TB_ERR_RESIZE_WRITE => TermboxError.ResizeWrite,
        c.TB_ERR_RESIZE_POLL => TermboxError.ResizePoll,
        c.TB_ERR_RESIZE_READ => TermboxError.ResizeRead,
        c.TB_ERR_RESIZE_SSCANF => TermboxError.ResizeSscanf,
        c.TB_ERR_CAP_COLLISION => TermboxError.CapCollision,
        else => unreachable,
    };
}

fn errorToTB(err: TermboxError) c_int {
    return switch (err) {
        TermboxError.Ok => c.TB_OK,
        TermboxError.Err => c.TB_ERR,
        TermboxError.NeedMore => c.TB_ERR_NEED_MORE,
        TermboxError.InitAlready => c.TB_ERR_INIT_ALREADY,
        TermboxError.InitOpen => c.TB_ERR_INIT_OPEN,
        TermboxError.Mem => c.TB_ERR_MEM,
        TermboxError.NoEvent => c.TB_ERR_NO_EVENT,
        TermboxError.NoTerm => c.TB_ERR_NO_TERM,
        TermboxError.NotInit => c.TB_ERR_NOT_INIT,
        TermboxError.OutOfBounds => c.TB_ERR_OUT_OF_BOUNDS,
        TermboxError.Read => c.TB_ERR_READ,
        TermboxError.ResizeIoctl => c.TB_ERR_RESIZE_IOCTL,
        TermboxError.ResizePipe => c.TB_ERR_RESIZE_PIPE,
        TermboxError.ResizeSigaction => c.TB_ERR_RESIZE_SIGACTION,
        TermboxError.Poll => c.TB_ERR_POLL,
        TermboxError.Tcgetattr => c.TB_ERR_TCGETATTR,
        TermboxError.Tcsetattr => c.TB_ERR_TCSETATTR,
        TermboxError.UnsupportedTerm => c.TB_ERR_UNSUPPORTED_TERM,
        TermboxError.ResizeWrite => c.TB_ERR_RESIZE_WRITE,
        TermboxError.ResizePoll => c.TB_ERR_RESIZE_POLL,
        TermboxError.ResizeRead => c.TB_ERR_RESIZE_READ,
        TermboxError.ResizeSscanf => c.TB_ERR_RESIZE_SSCANF,
        TermboxError.CapCollision => c.TB_ERR_CAP_COLLISION,
    };
}

pub const InputMode = enum(u8) {
    current = c.TB_INPUT_CURRENT,
    esc = c.TB_INPUT_ESC,
    alt = c.TB_INPUT_ALT,
    mouse = c.TB_INPUT_MOUSE,
};

pub const OutputMode = if (c.TB_OPT_ATTR_W >= 32) enum(u8) {
    current = c.TB_OUTPUT_CURRENT,
    normal = c.TB_OUTPUT_NORMAL,
    m256 = c.TB_OUTPUT_256,
    m216 = c.TB_OUTPUT_216,
    grayscale = c.TB_OUTPUT_GRAYSCALE,
    truecolor = c.TB_OUTPUT_TRUECOLOR,
} else enum(u8) {
    current = c.TB_OUTPUT_CURRENT,
    normal = c.TB_OUTPUT_NORMAL,
    m256 = c.TB_OUTPUT_256,
    m216 = c.TB_OUTPUT_216,
    grayscale = c.TB_OUTPUT_GRAYSCALE,
};

pub const AttributeSet = struct {
    pub const Attribute = if (c.TB_OPT_ATTR_W == 64) enum(c.uintattr_t) {
        default = c.TB_DEFAULT,
        black = c.TB_BLACK,
        red = c.TB_RED,
        green = c.TB_GREEN,
        yellow = c.TB_YELLOW,
        blue = c.TB_BLUE,
        magenta = c.TB_MAGENTA,
        cyan = c.TB_CYAN,
        white = c.TB_WHITE,
        bold = c.TB_BOLD,
        underline = c.TB_UNDERLINE,
        reverse = c.TB_REVERSE,
        italic = c.TB_ITALIC,
        blink = c.TB_BLINK,
        hi_black = c.TB_HI_BLACK,
        bright = c.TB_BRIGHT,
        dim = c.TB_DIM,
        strikeout = c.TB_STRIKEOUT,
        underline_2 = c.TB_UNDERLINE_2,
        overline = c.TB_OVERLINE,
        invisible = c.TB_INVISIBLE,
    } else enum(c.uintattr_t) {
        default = c.TB_DEFAULT,
        black = c.TB_BLACK,
        red = c.TB_RED,
        green = c.TB_GREEN,
        yellow = c.TB_YELLOW,
        blue = c.TB_BLUE,
        magenta = c.TB_MAGENTA,
        cyan = c.TB_CYAN,
        white = c.TB_WHITE,
        bold = c.TB_BOLD,
        underline = c.TB_UNDERLINE,
        reverse = c.TB_REVERSE,
        italic = c.TB_ITALIC,
        blink = c.TB_BLINK,
        hi_black = c.TB_HI_BLACK,
        bright = c.TB_BRIGHT,
        dim = c.TB_DIM,
    };

    back: c.uintattr_t,

    pub fn init(attr: Attribute) AttributeSet {
        return .{ .back = @intFromEnum(attr) };
    }

    pub fn initRaw(raw: c.uintattr_t) AttributeSet {
        return .{ .back = raw };
    }

    pub fn add(self: AttributeSet, attr: Attribute) AttributeSet {
        return .{ .back = self.back | @intFromEnum(attr) };
    }

    pub fn addRaw(self: AttributeSet, raw: c.uintattr_t) AttributeSet {
        return .{ .back = self.back | raw };
    }
};

pub const Event = struct {
    pub const Kind = enum(u8) {
        key = c.TB_EVENT_KEY,
        resize = c.TB_EVENT_RESIZE,
        mouse = c.TB_EVENT_MOUSE,
    };

    pub const Mod = struct {
        pub const Kind = enum(u8) {
            none = 0,
            alt = c.TB_MOD_ALT,
            ctrl = c.TB_MOD_CTRL,
            shift = c.TB_MOD_SHIFT,
            motion = c.TB_MOD_MOTION,
        };

        back: u8,

        pub fn check(self: Mod, kinds: anytype) bool {
            var val: u8 = 0;
            inline for (kinds) |kind| {
                val |= @intFromEnum(kind);
            }
            return self.back == val;
        }
    };

    pub const Key = enum(u16) {
        none = 0,
        // ctrl_tilde = c.TB_KEY_CTRL_TILDE,
        // ctrl_2 = c.TB_KEY_CTRL_2,
        ctrl_a = c.TB_KEY_CTRL_A,
        ctrl_b = c.TB_KEY_CTRL_B,
        ctrl_c = c.TB_KEY_CTRL_C,
        ctrl_d = c.TB_KEY_CTRL_D,
        ctrl_e = c.TB_KEY_CTRL_E,
        ctrl_f = c.TB_KEY_CTRL_F,
        ctrl_g = c.TB_KEY_CTRL_G,
        backspace = c.TB_KEY_BACKSPACE,
        // ctrl_h = c.TB_KEY_CTRL_H,
        tab = c.TB_KEY_TAB,
        // ctrl_i = c.TB_KEY_CTRL_I,
        ctrl_j = c.TB_KEY_CTRL_J,
        ctrl_k = c.TB_KEY_CTRL_K,
        ctrl_l = c.TB_KEY_CTRL_L,
        enter = c.TB_KEY_ENTER,
        // ctrl_m = c.TB_KEY_CTRL_M,
        ctrl_n = c.TB_KEY_CTRL_N,
        ctrl_o = c.TB_KEY_CTRL_O,
        ctrl_p = c.TB_KEY_CTRL_P,
        ctrl_q = c.TB_KEY_CTRL_Q,
        ctrl_r = c.TB_KEY_CTRL_R,
        ctrl_s = c.TB_KEY_CTRL_S,
        ctrl_t = c.TB_KEY_CTRL_T,
        ctrl_u = c.TB_KEY_CTRL_U,
        ctrl_v = c.TB_KEY_CTRL_V,
        ctrl_w = c.TB_KEY_CTRL_W,
        ctrl_x = c.TB_KEY_CTRL_X,
        ctrl_y = c.TB_KEY_CTRL_Y,
        ctrl_z = c.TB_KEY_CTRL_Z,
        esc = c.TB_KEY_ESC,
        // ctrl_lsq_bracket = c.TB_KEY_CTRL_LSQ_BRACKET,
        // ctrl_3 = c.TB_KEY_CTRL_3,
        ctrl_4 = c.TB_KEY_CTRL_4,
        // ctrl_backslash = c.TB_KEY_CTRL_BACKSLASH,
        ctrl_5 = c.TB_KEY_CTRL_5,
        // ctrl_rsq_bracket = c.TB_KEY_CTRL_RSQ_BRACKET,
        ctrl_6 = c.TB_KEY_CTRL_6,
        ctrl_7 = c.TB_KEY_CTRL_7,
        // ctrl_slash = c.TB_KEY_CTRL_SLASH,
        // ctrl_underscore = c.TB_KEY_CTRL_UNDERSCORE,
        space = c.TB_KEY_SPACE,
        backspace2 = c.TB_KEY_BACKSPACE2,
        // ctrl_8 = c.TB_KEY_CTRL_8,
        f1 = c.TB_KEY_F1,
        f2 = c.TB_KEY_F2,
        f3 = c.TB_KEY_F3,
        f4 = c.TB_KEY_F4,
        f5 = c.TB_KEY_F5,
        f6 = c.TB_KEY_F6,
        f7 = c.TB_KEY_F7,
        f8 = c.TB_KEY_F8,
        f9 = c.TB_KEY_F9,
        f10 = c.TB_KEY_F10,
        f11 = c.TB_KEY_F11,
        f12 = c.TB_KEY_F12,
        insert = c.TB_KEY_INSERT,
        delete = c.TB_KEY_DELETE,
        home = c.TB_KEY_HOME,
        end = c.TB_KEY_END,
        pgup = c.TB_KEY_PGUP,
        pgdn = c.TB_KEY_PGDN,
        arrow_up = c.TB_KEY_ARROW_UP,
        arrow_down = c.TB_KEY_ARROW_DOWN,
        arrow_left = c.TB_KEY_ARROW_LEFT,
        arrow_right = c.TB_KEY_ARROW_RIGHT,
        back_tab = c.TB_KEY_BACK_TAB,
        mouse_left = c.TB_KEY_MOUSE_LEFT,
        mouse_right = c.TB_KEY_MOUSE_RIGHT,
        mouse_middle = c.TB_KEY_MOUSE_MIDDLE,
        mouse_release = c.TB_KEY_MOUSE_RELEASE,
        mouse_wheel_up = c.TB_KEY_MOUSE_WHEEL_UP,
        mouse_wheel_down = c.TB_KEY_MOUSE_WHEEL_DOWN,
    };

    kind: Kind,
    mod: Mod,
    key: Key,
    ch: u32,
    w: i32,
    h: i32,
    x: i32,
    y: i32,

    fn fromTB(tb_event: *c.tb_event) Event {
        return .{
            .kind = @enumFromInt(tb_event.type),
            .mod = .{ .back = tb_event.mod },
            .key = @enumFromInt(tb_event.key),
            .ch = tb_event.ch,
            .w = tb_event.w,
            .h = tb_event.h,
            .x = tb_event.x,
            .y = tb_event.y,
        };
    }

    fn toTB(self: *Event) c.tb_event {
        return c.tb_event{
            .type = @intFromEnum(self.kind),
            .mod = self.mod.back,
            .key = @intFromEnum(self.key),
            .ch = self.ch,
            .w = self.w,
            .h = self.h,
            .x = self.x,
            .y = self.y,
        };
    }
};

pub const FuncType = enum(u8) {
    extract_pre = c.TB_FUNC_EXTRACT_PRE,
    extract_post = c.TB_FUNC_EXTRACT_POST,
};

pub const Func = *const fn (*Event, *usize) void;

pub const Cell = c.tb_cell;

pub fn init() !void {
    const rv = c.tb_init();
    if (rv != c.TB_OK) {
        return tbToError(rv);
    }
}

pub fn initFile(path: [:0]const u8) !void {
    const rv = c.tb_init_file(path);
    if (rv != c.TB_OK) {
        return tbToError(rv);
    }
}

pub fn initFD(fd: c_int) !void {
    const rv = c.tb_init_fd(fd);
    if (rv != c.TB_OK) {
        return tbToError(rv);
    }
}

pub fn initRWFD(rfd: c_int, wfd: c_int) !void {
    const rv = c.tb_init_rwfd(rfd, wfd);
    if (rv != c.TB_OK) {
        return tbToError(rv);
    }
}

pub fn shutdown() !void {
    const rv = c.tb_shutdown();
    if (rv != c.TB_OK) {
        return tbToError(rv);
    }
}

pub fn width() !i32 {
    const w = c.tb_width();
    if (w < 0) {
        return tbToError(w);
    }
    return @intCast(w);
}

pub fn height() !i32 {
    const h = c.tb_height();
    if (h < 0) {
        return tbToError(h);
    }
    return @intCast(h);
}

pub fn clear() !void {
    const rv = c.tb_clear();
    if (rv != c.TB_OK) {
        return tbToError(rv);
    }
}

pub fn setClearAttrs(fg: AttributeSet, bg: AttributeSet) !void {
    const rv = c.tb_set_clear_attrs(fg.back, bg.back);
    if (rv != c.TB_OK) {
        return tbToError(rv);
    }
}

pub fn present() !void {
    const rv = c.tb_present();
    if (rv != c.TB_OK) {
        return tbToError(rv);
    }
}

pub fn invalidate() !void {
    const rv = c.tb_invalidate();
    if (rv != c.TB_OK) {
        return tbToError(rv);
    }
}

pub fn setCursor(cx: i32, cy: i32) !void {
    const rv = c.tb_set_cursor(cx, cy);
    if (rv != c.TB_OK) {
        return tbToError(rv);
    }
}

pub fn hideCursor() !void {
    const rv = c.tb_hide_cursor();
    if (rv != c.TB_OK) {
        return tbToError(rv);
    }
}

pub fn setCell(x: i32, y: i32, ch: u32, fg: AttributeSet, bg: AttributeSet) !void {
    const rv = c.tb_set_cell(x, y, ch, fg.back, bg.back);
    if (rv != c.TB_OK) {
        return tbToError(rv);
    }
}

pub fn setCellEX(x: i32, y: i32, ch: []u32, fg: AttributeSet, bg: AttributeSet) !void {
    const rv = c.tb_set_cell_ex(x, y, ch.ptr, ch.len, fg.back, bg.back);
    if (rv != c.TB_OK) {
        return tbToError(rv);
    }
}

pub fn extendCell(x: i32, y: i32, ch: u32) !void {
    const rv = c.tb_extend_cell(x, y, ch);
    if (rv != c.TB_OK) {
        return tbToError(rv);
    }
}

pub fn setInputMode(modes: anytype) !void {
    var val: u8 = 0;
    inline for (modes) |mode| {
        val |= @intFromEnum(mode);
    }
    const rv = c.tb_set_input_mode(val);
    if (rv != c.TB_OK) {
        return tbToError(rv);
    }
}

pub fn setOutputMode(mode: OutputMode) !void {
    const rv = c.tb_set_output_mode(@intFromEnum(mode));
    if (rv != c.TB_OK) {
        return tbToError(rv);
    }
}

pub fn peekEvent(timeout_ms: i32) !Event {
    var tb_event: c.tb_event = undefined;
    const rv = c.tb_peek_event(&tb_event, timeout_ms);
    if (rv != c.TB_OK) {
        return tbToError(rv);
    }
    return Event.fromTB(&tb_event);
}

pub fn pollEvent() !Event {
    var tb_event: c.tb_event = undefined;
    const rv = c.tb_poll_event(&tb_event);
    if (rv != c.TB_OK) {
        return tbToError(rv);
    }
    return Event.fromTB(&tb_event);
}

pub fn getFDs() !struct { tty_fd: c_int, resize_fd: c_int } {
    var tty_fd: c_int = undefined;
    var resize_fd: c_int = undefined;
    const rv = c.tb_get_fds(&tty_fd, &resize_fd);
    if (rv != c.TB_OK) {
        return tbToError(rv);
    }
    return .{
        .tty_fd = tty_fd,
        .resize_fd = resize_fd,
    };
}

pub fn print(x: i32, y: i32, fg: AttributeSet, bg: AttributeSet, str: [:0]const u8) !usize {
    var w: usize = undefined;
    const rv = c.tb_print_ex(x, y, fg.back, bg.back, &w, str);
    if (rv != c.TB_OK) {
        return tbToError(rv);
    }
    return w;
}

pub fn printf(
    x: i32,
    y: i32,
    fg: AttributeSet,
    bg: AttributeSet,
    comptime fmt: []const u8,
    args: anytype,
) !usize {
    var buf: [c.TB_OPT_PRINTF_BUF]u8 = undefined;
    const str = try std.fmt.bufPrintZ(&buf, fmt, args);
    return try print(x, y, fg, bg, str);
}

pub fn send(buf: []const u8) !void {
    const rv = c.tb_send(buf.ptr, buf.len);
    if (rv != c.TB_OK) {
        return tbToError(rv);
    }
}

pub fn sendf(comptime fmt: []const u8, args: anytype) !void {
    var buf: [c.TB_OPT_PRINTF_BUF]u8 = undefined;
    const raw = try std.fmt.bufPrint(&buf, fmt, args);
    return try send(raw);
}

var extract_pre_func: ?Func = null;
var extract_post_func: ?Func = null;
const Callback = *const fn (tb_event: [*c]c.tb_event, size: [*c]usize) callconv(.C) c_int;

fn extract_pre_callback(tb_event: [*c]c.tb_event, size: [*c]usize) callconv(.C) c_int {
    if (extract_pre_func) |func| {
        var event: Event = undefined;
        func(&event, size);
        tb_event.* = event.toTB();
    }
    return c.TB_OK;
}

fn extract_post_callback(tb_event: [*c]c.tb_event, size: [*c]usize) callconv(.C) c_int {
    if (extract_post_func) |func| {
        var event: Event = undefined;
        func(&event, size);
        tb_event.* = event.toTB();
    }
    return c.TB_OK;
}

pub fn setFunc(func_type: FuncType, func: ?Func) !void {
    switch (func_type) {
        .extract_pre => extract_pre_func = func,
        .extract_post => extract_post_func = func,
    }
    const rv = c.tb_set_func(@intFromEnum(func_type), if (func == null) null else switch (func_type) {
        .extract_pre => extract_pre_callback,
        .extract_post => extract_post_callback,
    });
    if (rv != c.TB_OK) {
        return tbToError(rv);
    }
}

pub fn utf8CharLength(ch: u8) i32 {
    return c.tb_utf8_char_length(ch);
}

pub fn utf8CharToUnicode(ch: [*]const u8) !struct { ch: u32, len: i32 } {
    var out: u32 = undefined;
    const rv = c.tb_utf8_char_to_unicode(&out, ch);
    if (rv < 0) {
        return tbToError(rv);
    }
    return .{
        .ch = out,
        .len = rv,
    };
}

pub fn utf8UnicodeToChar(out: [*]u8, ch: u32) i32 {
    const rv = c.tb_utf8_unicode_to_char(out, ch);
    return rv;
}

pub fn lastErrno() c_int {
    const rv = c.tb_last_errno();
    return rv;
}

pub fn strError(err: TermboxError) [*:0]const u8 {
    const tb = errorToTB(err);
    const rv = c.tb_strerror(tb);
    return rv;
}

pub fn cellBuffer() !?[]Cell {
    const rv = c.tb_cell_buffer();
    if (rv == null) {
        return null;
    }
    const len: usize = @intCast(try width() * try height());
    const slice = rv[0..len];
    return slice;
}

pub fn hasTruecolor() bool {
    const rv = c.tb_has_truecolor();
    return if (rv == 0) false else true;
}

pub fn hasEgc() bool {
    const rv = c.tb_has_egc();
    return if (rv == 0) false else true;
}

pub fn attrWidth() i32 {
    const rv = c.tb_attr_width();
    return rv;
}

pub fn version() [*:0]const u8 {
    const rv = c.tb_version();
    return rv;
}

test "require" {
    comptime {
        std.testing.refAllDecls(@This());
    }
}
