const apprt = @import("apprt.zig");
const BuildConfig = @import("build/Config.zig");
const config = BuildConfig.fromOptions();
pub const app_runtime: apprt.Runtime = config.app_runtime;
