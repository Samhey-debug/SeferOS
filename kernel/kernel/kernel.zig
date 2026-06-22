const cpu = @import("cpu.zig");

pub fn kernel_main() noreturn {
    while (true) {
        cpu.halt();
    }
}
