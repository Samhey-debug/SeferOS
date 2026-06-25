const limine = @import("./boot/limine.zig");
const std = @import("std");
const cpu = @import("./kernel/cpu.zig");
const kernel = @import("./kernel/kernel.zig");
const serial = @import("./drivers/uart/serial.zig");

export var start_marker: limine.RequestsStartMarker linksection(".limine_requests_start") = .{};
export var end_marker: limine.RequestsEndMarker linksection(".limine_requests_end") = .{};

export var base_revision: limine.BaseRevision linksection(".limine_requests") = .init(6);
export var framebuffer_request: limine.Framebuffer.Request linksection(".limine_requests") = .{};

pub export fn _start() noreturn {
    cpu.disableInterrupts();

    if (!base_revision.isSupported()) {
        @panic("unsupported base revision");
    }

    const debug: serial.Serial = .init(null);
    if (debug.initialized) debug.write("\n\nSerial has been initialized!\n");

    if (debug.initialized) debug.write("Calling the kernel...\n");
    kernel.kernel_main(framebuffer_request);

    unreachable;
}

pub fn panic(msg: []const u8, trace: ?*std.builtin.StackTrace, ret_addr: ?usize) noreturn {
    cpu.disableInterrupts();

    const debug = serial.getSerial(null) catch serial.Serial{ .port_or_dummy = null, .initialized = false };
    debug.write("Panic!");
    _ = msg;
    _ = trace;
    _ = ret_addr;

    cpu.halt();
}
