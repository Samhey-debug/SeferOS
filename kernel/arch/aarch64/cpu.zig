pub inline fn disableInterrupts() void {
    asm volatile ("msr daifset, #2");
}

pub inline fn halt() noreturn {
    while (true) {
        asm volatile ("wfi");
    }
}
