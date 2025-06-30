const Terminl = @This();
const App = @import("../App.zig");
const std = @import("std");
const ncurses = @import("ncurses");
const ui = @import("../ui/main.zig");

const Surface = ui.Surface;
const Allocator = std.mem.Allocator;

pub fn start() !void {
    // _ = ncurses.c.initscr();
    _ = try ncurses.initscr();
    try ncurses.clear();
    try ncurses.refresh();
}

pub fn stop() !void {
    try ncurses.endwin();
}

pub fn render(app: *App) !void {
    if (app.focused_surface) |surface| {
        try renderSurface(surface);
    }
}

pub fn renderSurface(surface: *Surface) !void {
    try ncurses.clear();
    if (surface.focused_component) |component| {
        try component.render();
    }
    try ncurses.refresh();
}

pub fn renderMenu(menu: ui.components.Menu) !void {
    try ncurses.cursSet(false);
    try ncurses.move(0, 0);
    for (menu.items) |item| {
        try ncurses.printw(item);
        try ncurses.printw("\n");
    }
}
