const limine = @import("./boot/limine.zig");
const std = @import("std");
const cpu = @import("./kernel/cpu.zig");
const kernel = @import("./kernel/kernel.zig");

export var start_marker: limine.RequestsStartMarker linksection(".limine_requests_start") = .{};
export var end_marker: limine.RequestsEndMarker linksection(".limine_requests_end") = .{};

export var base_revision: limine.BaseRevision linksection(".limine_requests") = .init(6);

pub export fn _start() noreturn {
    cpu.disableInterrupts();

    if (!base_revision.isSupported()) {
        @panic("unsupported base revision");
    }

    kernel.kernel_main();

    unreachable;
}

pub fn panic(msg: []const u8, trace: ?*std.builtin.StackTrace, ret_addr: ?usize) noreturn {
    cpu.disableInterrupts();

    _ = msg;
    _ = trace;
    _ = ret_addr;

    cpu.halt();
}
