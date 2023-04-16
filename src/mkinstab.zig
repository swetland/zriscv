// Copyright 2023, Brian Swetland <swetland@frotz.net>
// Licensed under the Apache License, Version 2.0.

const std = @import("std");
const stdin = std.io.getStdIn().reader();
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    try stdout.print("const ITE = @import(\"rv32-internal.zig\").InsTabEntry;\n", .{});
    try stdout.print("pub const instab = [_]ITE {{\n", .{});
    
    var buf: [1024]u8 = undefined;
    while (try stdin.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if ((line.len < 34) or (line[0] == '#') or (line[32] != ' ')) {
            continue;
        }
        var mask: u32 = 0;
        var bits: u32 = 0;
        var n: u32 = 0;
        while (n < 32) : (n += 1) {
            var bit: u32 = std.math.shl(u32, 1, 31 - n);
            switch (line[n]) {
                '0' => {
                    mask |= bit;
                },
                '1' => {
                    mask |= bit;
                    bits |= bit;
                },
                else => {
                    // dontcare
                }
            }
        }
        try stdout.print(
            "    ITE{{ .mask = 0x{x:0>8}, .bits = 0x{x:0>8}, .fmt = \"{s}\" }},\n",
            .{mask, bits, line[33..]});
    }
    try stdout.print("}};\n", .{});
}

