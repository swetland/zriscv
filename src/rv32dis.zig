// Copyright 2023, Brian Swetland <swetland@frotz.net>
// Licensed under the Apache License, Version 2.0.

const std = @import("std");
const heap = std.heap.page_allocator;
const stdout = std.io.getStdOut().writer();
const stderr = std.io.getStdErr().writer();

const rv32 = @import("rv32.zig");

fn disassembleFile(name: []const u8, addr: u32) !void {
    const file = try std.fs.cwd().openFile(name, .{});
    defer file.close();

    const stat = try file.stat();
    var count = stat.size / 4;

    const data : []u32 = try heap.alloc(u32, count + 1);
    defer heap.free(data);

    const data8 = @ptrCast([*]u8, data.ptr)[0..stat.size];
    _ = try file.readAll(data8);

    var n : usize = 0; 
    while (n < count) : (n += 1) {
        var buf: [128]u8 = undefined;
        try stdout.print("{x:0>8}: {x:0>8} {s}\n", .{
            addr + n * 4, data[n],
            rv32.disassemble(&buf, addr, data[n])
        });
    }
}

pub fn main() !void {
    var addr : u32 = 0x80000000;

    var args = std.process.args();
    _ = args.skip();
    while (args.next()) |arg| {
        try disassembleFile(arg, addr);
    }    

}

