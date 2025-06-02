const braille = @import("apprt/braille.zig");

const Runtime = enum {
    braille,

    pub const default = .braille;
};

pub const runtime = braille;

pub const App = runtime.App;
