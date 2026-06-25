const std = @import("std");
const builtin = @import("builtin");

const serial = switch (builtin.target.cpu.arch) {
    .x86_64 => @import("ns16550.zig"),
    else => @compileError("unsupported arch"),
};

pub const Serial = struct {
    port_or_dummy: ?u16,
    initialized: bool,

    pub fn init(port_or_dummy: ?u16) @This() {
        return .{
            .port_or_dummy = port_or_dummy,
            .initialized = serial.init(port_or_dummy),
        };
    }

    pub fn write(self: @This(), string: []const u8) void {
        serial.write(string, self.port_or_dummy);
    }
};

pub fn getSerial(port_or_dummy: ?u16) error{SerialNotInitialized}!Serial {
    if (!serial.isInitialized(port_or_dummy)) return error.SerialNotInitialized;
    return Serial{ .port_or_dummy = port_or_dummy, .initialized = true };
}
