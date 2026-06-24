pub inline fn mmioWrite(comptime T: type, addr: usize, value: T) void {
    @as(*volatile T, @ptrFromInt(addr)).* = value;
}

pub inline fn mmioRead(comptime T: type, addr: usize) T {
    return @as(*volatile T, @ptrFromInt(addr)).*;
}
