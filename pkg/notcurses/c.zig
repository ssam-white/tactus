pub const c = @cImport({
    @cInclude("notcurses/notcurses.h");
    // @cInclude("notcurses/render.h");    // for ncpile_render, ncpile_rasterize
});
