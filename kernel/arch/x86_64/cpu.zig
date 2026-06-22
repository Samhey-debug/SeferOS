pub inline fn disableInterrupts() void {
    asm volatile ("cli");
}

pub inline fn halt() noreturn {
    while (true) {
        asm volatile ("hlt");
    }
}
