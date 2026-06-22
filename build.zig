const std = @import("std");

const Architecture = enum {
    x86_64,
    aarch64,

    fn toStd(self: @This()) std.Target.Cpu.Arch {
        return switch (self) {
            .x86_64 => .x86_64,
            .aarch64 => .aarch64,
        };
    }
};

fn targetQuery(architecture: Architecture) std.Target.Query {
    var query: std.Target.Query = .{
        .cpu_arch = architecture.toStd(),
        .os_tag = .freestanding,
        .abi = .none,
    };

    switch (architecture) {
        .x86_64 => {
            query.cpu_features_add = std.Target.x86.featureSet(&.{ .popcnt, .soft_float });
            query.cpu_features_sub = std.Target.x86.featureSet(&.{ .avx, .avx2, .sse, .sse2, .mmx });
        },
        .aarch64 => {
            query.cpu_features_sub = std.Target.aarch64.featureSet(&.{ .fp_armv8, .crypto, .neon });
        },
    }

    return query;
}

pub fn build(b: *std.Build) void {
    const architecture = b.option(Architecture, "architecture", "The architecture to build the kernel  for.") orelse .x86_64;
    const query = targetQuery(architecture);

    const target = b.resolveTargetQuery(query);
    const optimize = b.standardOptimizeOption(.{});

    const kernel_module = b.createModule(.{
        .root_source_file = b.path("./kernel/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    if (architecture == .x86_64) {
        kernel_module.red_zone = false;
        kernel_module.code_model = .kernel;
    }

    const kernel = b.addExecutable(.{
        .name = "kernel",
        .root_module = kernel_module,
        .use_llvm = true,
    });

    kernel.setLinkerScript(b.path(b.fmt("./kernel/arch/{s}/linker.lds", .{@tagName(architecture)})));

    b.resolveInstallPrefix(null, .{ .exe_dir = b.fmt("bin-{s}", .{@tagName(architecture)}) });
    b.installArtifact(kernel);
}
