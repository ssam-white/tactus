const blocking_queue = @import("blocking_queue.zig");

pub const BlockingQueue = blocking_queue.BlockingQueue;

test {
    @import("std").testing.refAllDecls(@This());
}
