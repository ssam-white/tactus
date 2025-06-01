const braille = @import("renderer/braille.zig");

pub const Impl = enum {
    braille,

    pub const default: Impl = .braille;
};

pub const Renderer = switch (Impl.default) {
    .braille => braille
};
