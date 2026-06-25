const cpu = @import("cpu.zig");
const serial = @import("../drivers/uart/serial.zig");
const limine = @import("../boot/limine.zig");

pub fn kernel_main(framebufferRequest: limine.Framebuffer.Request) noreturn {
    const debug = serial.getSerial(null) catch serial.Serial{ .port_or_dummy = null, .initialized = false };
    if (debug.initialized) debug.write("Kernel took control!\n");
    if (framebufferRequest.response == null) @panic("framebuffer not present");

    const framebufferResponse: *limine.Framebuffer.Response = framebufferRequest.response.?;
    const framebuffer = (framebufferResponse.fetchFramebuffer() catch unreachable)[0];
    const fb_ptr: [*]volatile u32 = @ptrCast(@alignCast(framebuffer.address));
    const pitch_u32 = framebuffer.pitch / 4;
    var y: usize = 0;
    while (y < framebuffer.height) : (y += 1) {
        var x: usize = 0;
        while (x < framebuffer.width) : (x += 1) {
            const nX: u32 = @intCast(x * 255 / framebuffer.width);
            const nY: u32 = @intCast(y * 255 / framebuffer.height);

            fb_ptr[y * pitch_u32 + x] = (nY << 8) | nX;
        }
    }

    debug.write("Halting the CPU...");
    while (true) {
        cpu.halt();
    }
}
