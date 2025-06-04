const braille = @import("apprt/braille.zig");
const action = @import("apprt/action.zig");

const Action = action.Action;

const Runtime = enum {
    braille,

    pub const default = .braille;
};

pub const runtime = braille;

pub const App = runtime.App;
pub const Surface = runtime.Surface;
