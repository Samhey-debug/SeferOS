const io = @import("../../arch/x86_64/io.zig");

const COM1 = 0x3F8;

// The implementation will probably change

pub fn init(port: ?u16) bool {
    const default = port orelse COM1;
    io.outb(default + 1, 0x00);
    io.outb(default + 3, 0x80);
    io.outb(default, 0x01);
    io.outb(default + 1, 0x00);
    io.outb(default + 3, 0x03);
    io.outb(default + 2, 0xC7);
    io.outb(default + 4, 0x0B);
    io.outb(default + 4, 0x1E);
    io.outb(default, 0xAE);

    if (io.inb(default) != 0xAE) {
        return false;
    }

    io.outb(default + 4, 0x0F);
    return true;
}

pub fn write(string: []const u8, port: ?u16) void {
    for (string) |byte| {
        writeByte(byte, port orelse COM1);
    }
}

pub fn writeByte(byte: u8, port: ?u16) void {
    if (byte == '\n') {
        io.outb(port orelse COM1, '\r');
    }
    io.outb(port orelse COM1, byte);
}
