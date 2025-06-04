const std = @import("std");

pub const Action = union(enum) {
    quit: void,

    pub const Key = std.meta.Tag(Action);

    pub fn Value(key: Key) type {
        return std.meta.TagPayload(Action, key);
    }
};
