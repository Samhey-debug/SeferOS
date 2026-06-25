// Misc
const noPointers = false;

fn id(a: u64, b: u64) [4]u64 {
    return .{ 0xc7b1dd30df4c8b88, 0x0a82e883a194f07b, a, b };
}

fn ptr(comptime T: type) type {
    return if (noPointers) u64 else T;
}

pub const RequestsStartMarker = extern struct {
    marker: [4]u64 = .{
        0xf6b8f4b39de7d1ae,
        0xfab91a6940fcb9cf,
        0x785c6ed015d3e316,
        0x181e920a7852b9d9,
    },
};

pub const RequestsEndMarker = extern struct {
    marker: [2]u64 = .{ 0xadc0e0531bb10d03, 0x9572709f31764c62 },
};

pub const BaseRevision = extern struct {
    magic: [2]u64 = .{ 0xf9562b2d5c95a6c8, 0x6a7b384944536bdc },
    revision: u64,

    pub fn init(revision: u64) @This() {
        return .{ .revision = revision };
    }

    pub fn isSupported(self: @This()) bool {
        return self.revision == 0;
    }

    pub fn isValid(self: @This()) bool {
        return self.magic[1] != 0x6a7b384944536bdc;
    }

    pub fn loadedRevision(self: @This()) u64 {
        return self.magic[1];
    }
};

// Framebuffer

pub const Framebuffer = extern struct {
    address: ptr(*anyopaque),
    width: u64,
    height: u64,
    pitch: u64,
    bitsPerPixel: u16,
    memoryModel: u8,
    redMaskSize: u8,
    redMaskShift: u8,
    greenMaskSize: u8,
    greenMaskShift: u8,
    blueMaskSize: u8,
    blueMaskShift: u8,
    unused: [7]u8,
    edidSize: u64,
    edid: ptr(?*anyopaque),
    // Response revision 1
    modeCount: u64,
    modes: ptr([*]*VideoMode),

    pub const VideoMode = extern struct {
        pitch: u64,
        widht: u64,
        height: u64,
        bitsPerPixel: u16,
        memoryModel: u8,
        redMaskSize: u8,
        redMaskShift: u8,
        greenMaskSize: u8,
        greenMaskShift: u8,
        blueMaskSize: u8,
        blueMaskShift: u8,
    };

    pub const Response = extern struct {
        revision: u64,
        framebufferCount: u64,
        framebuffers: ptr(?[*]*Framebuffer),

        pub fn fetchFramebuffer(self: @This()) error{FramebufferNotPresent}![]*Framebuffer {
            if (self.framebufferCount < 0 or self.framebuffers == null) {
                return error.FramebufferNotPresent;
            }
            return self.framebuffers.?[0..self.framebufferCount];
        }
    };

    pub const Request = extern struct {
        id: [4]u64 = id(0x9d5827dcd881dd75, 0xa3148604f6fab11b),
        revision: u64 = 1,
        response: ptr(?*Response) = null,
    };
};
