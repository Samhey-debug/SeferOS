const cpu = @import("cpu.zig");
const serial = @import("../drivers/uart/serial.zig");

pub fn kernel_main() noreturn {
    const port: serial.Serial = .init(null);
    port.write("Hello! Nya..");

    while (true) {
        cpu.halt();
    }
}
