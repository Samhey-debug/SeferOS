const builtin = @import("builtin");
const cpu = switch (builtin.target.cpu.arch) {
    .x86_64 => @import("../arch/x86_64/cpu.zig"),
    .aarch64 => @import("../arch/aarch64/cpu.zig"),
    else => @compileError("unsupported arch"),
};

pub fn disableInterrupts() void {
    cpu.disableInterrupts();
}

pub fn halt() noreturn {
    cpu.halt();
}
