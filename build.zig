const std = @import("std");

const flash = @import("zig_flash");
const microzig = @import("microzig");

const MicroBuild = microzig.MicroBuild(.{
    .rp2xxx = true,
});

pub fn build(b: *std.Build) void {
    const mz_dep = b.dependency("microzig", .{});
    const mb = MicroBuild.init(b, mz_dep) orelse return;

    const target = mb.ports.rp2xxx.boards.raspberrypi.pico.*; //  b.standardTargetOptions(.{});
    const optimize: std.builtin.OptimizeMode = .ReleaseSafe; //b.standardOptimizeOption(.{});

    const zigmkay_dep = b.dependency("zigmkay", .{});
    const zigmkay_mod = zigmkay_dep.module("zigmkay");

    const firmware = mb.add_firmware(.{
        .name = "zigmkay-sample",
        .target = &target,
        .optimize = optimize,
        .root_source_file = b.path("src/main.zig"),
        // TOOD: Move back to normal imports once working
        // .imports = &.{
        //     .{ .name = "zigmkay", .module = zigmkay_mod },
        // },
    });

    firmware.add_app_import("zigmkay", zigmkay_mod, .{ .depend_on_microzig = true });

    // We call this twice to demonstrate that the default binary output for
    // RP2040 is UF2, but we can also output other formats easily
    mb.install_firmware(firmware, .{});

    const flash_dep = b.dependency("zig_flash", .{});
    const flash_exe = flash_dep.artifact("zig_flash");
    _ = flash.addFlashStep(b, flash_exe, .{.input_name="zigmkay-sample.uf2"});
}
