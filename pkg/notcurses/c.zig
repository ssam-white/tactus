pub const c = @cImport({
    @cInclude("notcurses/notcurses.h");
    // @cInclude("notcurses/direct.h");    // for ncpile_render, ncpile_rasterize
});
