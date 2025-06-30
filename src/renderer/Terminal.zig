const Terminl = @This();
const App = @import("../App.zig");
const std = @import("std");
const ncurses = @import("ncurses");
const ui = @import("../ui/main.zig");

const Surface = ui.Surface;
const Allocator = std.mem.Allocator;

pub fn start() void {
    _ = ncurses.c.initscr();
    _ = ncurses.c.clear();
    _ = ncurses.c.refresh();
}

pub fn stop() void {
    _ = ncurses.c.endwin();
}

pub fn render(app: *App) void {
    if (app.focused_surface) |surface| {
        renderSurface(surface);
    }
}

pub fn renderSurface(surface: *Surface) void {
    _ = ncurses.c.clear();
    if (surface.focused_component) |component| {
        component.render();
    }
    _ = ncurses.c.refresh();
}

pub fn renderMenu(menu: ui.components.Menu) void {
    _ = ncurses.c.curs_set(0);
    _ = ncurses.c.move(0, 0);
    for (menu.items) |item| {
        const c_text: [*c]const u8 = &item[0];
        _ = ncurses.c.printw(c_text);
        _ = ncurses.c.printw("\n");
    }
}
