const mmio = @import("../../arch/common/mmio.zig");
const barrier = @import("../../arch/aarch64/barrier.zig");

const UART_BASE_ADDRESS = 0x09000000;

const UARTDR = UART_BASE_ADDRESS + 0x000;
const UARTFR = UART_BASE_ADDRESS + 0x018;
const UARTIBRD = UART_BASE_ADDRESS + 0x024;
const UARTFBRD = UART_BASE_ADDRESS + 0x028;
const UARTLCR_H = UART_BASE_ADDRESS + 0x02C;
const UARTCR = UART_BASE_ADDRESS + 0x030;

pub fn init() bool {
    mmio.mmioWrite(u32, UARTCR, 0); // Disable UART.
    while ((mmio.mmioRead(u32, UARTFR) & (1 << 3)) != 0) {} // Wait for the end of transmission or reception of the current character.
    mmio.mmioWrite(u32, UARTLCR_H, (1 << 4)); // Flush the transmit FIFO.
    // 48MHz, 115200 baud rate
    // 48000000 / (16 * 115200) = 26.04166666666666667
    // 0.04166666666666667 * 64 + 0.5 = ~3
    mmio.mmioWrite(u32, UARTIBRD, 26);
    mmio.mmioWrite(u32, UARTFBRD, 3);

    mmio.mmioWrite(u32, UARTLCR_H, (1 << 4) | (1 << 5) | (1 << 6)); // Enable FIFO and set 8-bit word length.
    mmio.mmioWrite(u32, UARTCR, (1 << 0) | (1 << 8) | (1 << 9)); // Enable UART.
    barrier.dsb();

    return true;
}

pub fn write(string: []const u8) void {
    for (string) |byte| {
        writeByte(byte);
    }
}

pub fn writeByte(byte: u8) void {
    if (byte == '\n') {
        // Wait for the transmit FIFO to empty.
        while ((mmio.mmioRead(u32, UARTFR) & (1 << 5)) != 0) {}
        mmio.mmioWrite(u32, UARTDR, @as(u32, '\r'));
    }
    while ((mmio.mmioRead(u32, UARTFR) & (1 << 5)) != 0) {}
    mmio.mmioWrite(u32, UARTDR, @as(u32, byte));
}
