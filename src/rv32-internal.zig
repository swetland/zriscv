// Copyright 2023, Brian Swetland <swetland@frotz.net>
// Licensed under the Apache License, Version 2.0.

pub const InsTabEntry = struct {
    mask: u32,
    bits: u32,
    fmt: []const u8,
};

// helpers to extract values from instructions
pub inline fn getOC(ins: u32) u32 {
    return ins & 0x7f;
}
pub inline fn getRD(ins: u32) u32 {
    return (ins >> 7) & 0x1f;
}
pub inline fn getR1(ins: u32) u32 {
    return (ins >> 15) & 0x1f;
}
pub inline fn getR2(ins: u32) u32 {
    return (ins >> 20) & 0x1f;
}
pub inline fn getII(ins: u32) u32 {
    return @bitCast(u32, @bitCast(i32, ins) >> 20);
}
pub inline fn getIS(ins: u32) u32 {
    return (@bitCast(u32, (@bitCast(i32, ins) >> 20)) & 0xffffffe0) |
        ((ins >> 7) & 0x1f);
}
pub inline fn getIB(ins: u32) u32 {
    return ((ins >> 7) & 0x1e) |
        ((ins >> 20) & 0x7e0) |
        ((ins << 4) & 0x800) |
        @bitCast(u32, (@bitCast(i32, ins & 0x80000000) >> 19));
}
pub inline fn getIU(ins: u32) u32 {
    return ins & 0xFFFFF000;
}
pub inline fn getIJ(ins: u32) u32 {
    return @bitCast(u32, (@bitCast(i32, ins & 0x80000000) >> 11)) |
        (ins & 0xFF000) |
        ((ins >> 9) & 0x800) |
        ((ins >> 20) & 0x7fe);
}
pub inline fn getFN3(ins: u32) u32 {
    return (ins >> 12) & 7;
}
pub inline fn getFN7(ins: u32) u32 {
    return ins >> 25;
}
pub inline fn getIC(ins: u32) u32 {
    return (ins >> 15) & 0x1F;
}
pub inline fn getIX(ins: u32) u32 {
    return ins >> 20;
}

// helpers for register number to name conversion
const regnames_plain = [32][]const u8 {
    "x0", "x1", "x2", "x3", "x4", "x5", "x6", "x7",
    "x8", "x9", "x10", "x11", "x12", "x13", "x14", "x15",
    "x16", "x17", "x18", "x19", "x20", "x21", "x22", "x23",
    "x24", "x25", "x26", "x27", "x28", "x29", "x30", "x31",
};
const regnames_fancy = [32][]const u8 {
    "zero", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
    "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
    "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
    "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6",
};
pub fn getRegName(n: u32) []const u8 {
    if (n < 32) {
        return regnames_fancy[n];
    } else {
        return "??";
    }
}
