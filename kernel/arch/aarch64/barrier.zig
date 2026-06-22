pub inline fn dsb() void {
    asm volatile ("dsb sy");
}

pub inline fn isb() void {
    asm volatile ("isb");
}
