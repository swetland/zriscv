// Copyright 2023, Brian Swetland <swetland@frotz.net>
// Licensed under the Apache License, Version 2.0.

const std = @import("std");

const rv = @import("rv32-internal.zig");
const instab = @import("rv32-instab.zig").instab;

fn fmtStr(dst: []u8, src: []const u8) usize {
    const r = std.fmt.bufPrint(dst, "{s}", .{src}) catch {
        return 0;
    };
    return r.len;
}
fn fmtI32(dst: []u8, val: u32) usize {
    const r = std.fmt.bufPrint(dst, "{d}", .{@bitCast(i32, val)}) catch {
        return 0;
    };
    return r.len;
}
fn fmtU32(dst: []u8, val: u32) usize {
    const r = std.fmt.bufPrint(dst, "0x{x}", .{val}) catch {
        return 0;
    };
    return r.len;
}
fn fmtCSR(dst: []u8, val: u32) usize {
    const r = std.fmt.bufPrint(dst, "0x{x:0>3}", .{ val & 0xfff }) catch {
        return 0;
    };
    return r.len;
}
fn fmtInsn(buf: []u8, pc: u32, ins: u32, fmt: []const u8) []u8 {
    var pos: usize = 0;
    var esc: bool = false;
    for (fmt) |c| { 
        if (esc) {
            var s = buf[pos..];
            pos += switch (c) {
                '1' => fmtStr(s, rv.getRegName(rv.getR1(ins))),
                '2' => fmtStr(s, rv.getRegName(rv.getR2(ins))),
                'd' => fmtStr(s, rv.getRegName(rv.getRD(ins))),
                'i' => fmtI32(s, rv.getII(ins)),
                'j' => fmtI32(s, rv.getIJ(ins)),
                'J' => fmtU32(s, pc +% rv.getIJ(ins)),
                'b' => fmtI32(s, rv.getIB(ins)),
                'B' => fmtU32(s, pc +% rv.getIB(ins)),
                's' => fmtI32(s, rv.getIS(ins)),
                'u' => fmtI32(s, rv.getIU(ins)),
                'U' => fmtU32(s, rv.getIU(ins)),
                'c' => fmtI32(s, rv.getIC(ins)),
                'x' => fmtI32(s, rv.getR2(ins)),
                'C' => fmtCSR(s, rv.getII(ins)),
                else => 0,
            };
            esc = false;
        } else if (c == '%') {
            esc = true;
        } else {
            if (pos < buf.len) {
                buf[pos] = c;
                pos += 1;
            }
        }
    }
    return buf[0..pos];
}

pub fn disassemble(buf: []u8, pc: u32, ins: u32) []u8 {
    var n: usize = 0;
    while (n < instab.len) : (n += 1) {
        if ((ins & instab[n].mask) == instab[n].bits) {
            return fmtInsn(buf, pc, ins, instab[n].fmt);
        }
    }
    return buf[fmtStr(buf, "unknown")..];
}
