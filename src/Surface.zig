const Surface = @This();
const App = @import("App.zig");

self_ptr: *anyopaque,
v_table: VTable,

const VTable = struct {
    display: *const fn (ptr: *anyopaque) void,
};

pub fn init(ptr: anytype) Surface {
    const T = @TypeOf(ptr);
    const ptr_info = @typeInfo(T);

    const gen = struct {
        pub fn display(self_ptr: *anyopaque) void {
            const self: T = @ptrCast(self_ptr);
            ptr_info.pointer.Child.display(self);
        }
    };

    return .{
        .ptr = ptr,
        .vtable = .{
            .display = gen.display
        }
    };
}

pub fn display(self: Surface) void {
    self.vtable.display(self.ptr);
}
