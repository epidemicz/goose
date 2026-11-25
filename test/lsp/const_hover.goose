// lsp: fixture for test/lsp_protocol.py: const initializer hover values
// (docs/design/language_server.md §6). Covers scalars, strings, aliases,
// optimizer isolation, writable-ref invalidation, float precision/overflow,
// and UTF-8 boundary truncation. Lines and columns are 1-based.
fn inline_candidate(x: i64) -> i64 { x * 2 + 1 }

const HEX = 0xFF;
const B = true;
const G_TYPED: i64 = 10;
const G_ALIAS = G_TYPED;
const G_HEX_ALIAS = HEX;
const G_MILLION = 1_000_000;
const G_U8_NOT:     u8  = ~4;
const G_U64_NOT:    u64 = ~4;
const G_F_FROM_HEX: f64 = 0xFF;
const G_F_FROM_INT: f64 = 5;
const G_F_TYPED:    f64 = 1.5;
const G_F_ALIAS = G_F_TYPED;
const G_INF = 1.0 / 0.0;
const G_B_NOT = !B;
const G_B_ALIAS = B;
const G_STR = "hello";
const G_STR_ALIAS = G_STR;
const G_PNG = "\x89PNG\r\n\x1a\n";
const G_UNI_EXACT2 = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaébbb";
const G_UNI_MID3 = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa€bbb";
const G_UNI_EXACT4 = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa🦆bbb";
const G_UNI_MID4 = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa🦆bbb";
const G_INL = inline_candidate(3);

let M_INT = 4;
let UNMUT_G = 12;
fn bump_i(r: i64&) { r = 99; }
fn bump_f(r: f64&) { r = 9.5; }
const G_NAN2 = (0.0 / 0.0) / 0.0;
const G_NINF = -1.0 / 0.0;
const G_SHL = 1 << 8;
const G_AND = 0xFF & 0x0F;
const G_F32_P1: f32 = 0.1;
const G_F32_ALIAS = G_F32_P1;
const G_F32_WIDEN: f64 = G_F32_P1;
const G_F32_OVF:   f32 = 1e300;
const G_F32_UND:   f32 = 1e-50;
const C_UNMUT = UNMUT_G + 3;

const G_F32_OVF2: f32 = 1e400;
const G_F32_UND2: f32 = 1e-400;
const G_F64_OVF = 1e400;
const G_F64_UND = 1e-400;
const G_F32_PREC: f32 = 16777217.0;
const G_F32_PREC_AL = G_F32_PREC;
const G_F32_PI:    f32 = 3.14159265358979323846;
const G_BIG_I:     i64 = 18014401730707455;
const G_BIG_F_DIR: f32 = 18014401730707455;
const G_BIG_F_AL:  f32 = G_BIG_I;
const G_BIG_NOT:   f32 = ~18014401730707454;

const G_F64_PREC = 9007199254740993.0;
const G_F64_PREC_AL = G_F64_PREC;
const G_F64_PI = 3.14159265358979323846;
const G_F64_HEX = 0x1.8p3;
const G_NEG_ZERO = -0.0;
const G_I64_MIN = -9223372036854775808;
const G_U64_SRC: u64 = 9223372586610720769;
const G_U64_F32: f32 = G_U64_SRC;
const G_STR_64 = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
const G_DONT = "don't";

fn const_hover_edges(x: i64, y: f64) {
    var rv: i64[>..] = [];
    rv.push(x);
    const L_RT_LEN = rv.len;
    const L_RT_INT = x + 1;
    const L_RT_FLT = y * 2.0;
    const L_INL = inline_candidate(3);
    const L1 = 10;
    const L2 = L1;
    const LF1: f64 = 1.5;
    const LF2 = LF1;
    const LB1 = true;
    const LB2 = LB1;
    const LB3 = !LB1;
    const LS1 = "abc";
    const LS2 = LS1;
    const LU8: u8  = ~4;
    const LHF: f64 = 0xFF;
    const for <CS> in ["alpha", "beta"] {
        const CF = CS;
        print(CF);
    }
    print(G_TYPED);
    print(G_ALIAS);
    print(G_HEX_ALIAS);
    print(G_MILLION);
    print(G_U8_NOT);
    print(G_U64_NOT);
    print(G_F_FROM_HEX);
    print(G_F_FROM_INT);
    print(G_F_ALIAS);
    print(G_INF);
    print(G_B_NOT);
    print(G_B_ALIAS);
    print(G_STR_ALIAS);
    print(G_PNG);
    print(G_UNI_EXACT2);
    print(G_UNI_MID3);
    print(G_UNI_EXACT4);
    print(G_UNI_MID4);
    print(G_INL);
    print(L_RT_LEN);
    print(L_RT_INT);
    print(L_RT_FLT);
    print(L_INL);
    print(L2);
    print(LF2);
    print(LB2);
    print(LB3);
    print(LS2);
    print(LU8);
    print(LHF);
}

fn early_mut_check() {
    const C_EARLY = M_INT;
    print(C_EARLY);
}

fn const_hover_mut_and_edges() {
    bump_i(M_INT);
    const C_M_DIRECT = M_INT;
    const C_M_ADD = M_INT + 1;
    const C_M_OR = M_INT | 2;
    const C_M_SHL = M_INT << 1;
    const C_M_NEG = -M_INT;
    const C_M_NOT = ~M_INT;
    const C_M_FLT:   f64 = M_INT;
    const C_M_FNOT:  f64 = ~M_INT;
    const C_M_TYPED: i64 = C_M_DIRECT;
    const C_M_ALIAS = C_M_TYPED;
    let mf_a = 1.5;
    bump_f(mf_a);
    let mf_b = mf_a;
    const C_MF_CHAIN = mf_b;
    const C_MF_NEG = -mf_a;
    const C_MF_ADD = mf_a + 1.0;
    print(G_NAN2);
    print(G_NINF);
    print(G_SHL);
    print(G_AND);
    print(G_F32_P1);
    print(G_F32_ALIAS);
    print(G_F32_WIDEN);
    print(G_F32_OVF);
    print(G_F32_UND);
    print(C_UNMUT);
    print(C_M_DIRECT);
    print(C_M_ADD);
    print(C_M_OR);
    print(C_M_SHL);
    print(C_M_NEG);
    print(C_M_NOT);
    print(C_M_FLT);
    print(C_M_FNOT);
    print(C_M_ALIAS);
    print(C_MF_CHAIN);
    print(C_MF_NEG);
    print(C_MF_ADD);
}

fn const_hover_round2() {
    const for <KF> in [G_F32_OVF] {
        const CF_OVF = KF;
        print(CF_OVF);
    }
    const for <KU> in [G_F32_UND] {
        const CF_UND = KU;
        print(CF_UND);
    }
    print(G_F32_OVF2);
    print(G_F32_UND2);
    print(G_F64_OVF);
    print(G_F64_UND);
    print(G_F32_PREC);
    print(G_F32_PREC_AL);
    print(G_F32_PI);
    print(G_BIG_F_DIR);
    print(G_BIG_F_AL);
    print(G_BIG_NOT);
}

fn const_hover_round3() {
    print(G_F64_PREC);
    print(G_F64_PREC_AL);
    print(G_F64_PI);
    print(G_F64_HEX);
    print(G_NEG_ZERO);
    print(G_I64_MIN);
    print(G_U64_F32);
    print(G_STR_64);
    print(G_DONT);
    const TRAIL_ZERO = 1.50;
    print(TRAIL_ZERO);
}

fn main() {
    const_hover_edges(1, 2.5);
    early_mut_check();
    const_hover_mut_and_edges();
    const_hover_round2();
    const_hover_round3();
}

// lsp: hover 9:7 "const G_TYPED: const i64 = 10\n```"
// lsp: hover 10:7 "const G_ALIAS: const i64 = 10\n```"
// lsp: hover 11:7 "const G_HEX_ALIAS: const i64 = 255\n```"
// lsp: hover 12:7 "const G_MILLION: const i64 = 1_000_000\n```"
// lsp: hover 13:7 "const G_U8_NOT: const u8 = 251\n```"
// lsp: hover 14:7 "const G_U64_NOT: const u64 = 18446744073709551611\n```"
// lsp: hover 15:7 "const G_F_FROM_HEX: const f64 = 255.0\n```"
// lsp: hover 16:7 "const G_F_FROM_INT: const f64 = 5.0\n```"
// lsp: hover 18:7 "const G_F_ALIAS: const f64 = 1.5\n```"
// lsp: hover 19:7 "const G_INF: const f64 = inf\n```"
// lsp: hover 20:7 "const G_B_NOT: const bool = false\n```"
// lsp: hover 21:7 "const G_B_ALIAS: const bool = true\n```"
// lsp: hover 23:7 "const G_STR_ALIAS: const u8[:] = \"hello\"\n```"
// lsp: hover 24:7 "const G_PNG: const u8[:] = \"\\x89PNG\\r\\n\\x1a\\n\"\n```"
// lsp: hover 25:7 "const G_UNI_EXACT2: const u8[:] = \"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaé...\"\n```"
// lsp: hover 26:7 "const G_UNI_MID3: const u8[:] = \"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa...\"\n```"
// lsp: hover 27:7 "const G_UNI_EXACT4: const u8[:] = \"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa🦆...\"\n```"
// lsp: hover 28:7 "const G_UNI_MID4: const u8[:] = \"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa...\"\n```"
// lsp: hover 29:7 "const G_INL: const i64\n```"
// lsp: hover 35:7 "const G_NAN2: const f64 = nan\n```"
// lsp: hover 36:7 "const G_NINF: const f64 = -inf\n```"
// lsp: hover 37:7 "const G_SHL: const i64 = 256\n```"
// lsp: hover 38:7 "const G_AND: const i64 = 15\n```"
// lsp: hover 39:7 "const G_F32_P1: const f32 = 0.1\n```"
// lsp: hover 40:7 "const G_F32_ALIAS: const f32 = 0.1\n```"
// lsp: hover 41:7 "const G_F32_WIDEN: const f64 = 0.10000000149011612\n```"
// lsp: hover 42:7 "const G_F32_OVF: const f32 = inf\n```"
// lsp: hover 43:7 "const G_F32_UND: const f32 = 0.0\n```"
// lsp: hover 44:7 "const C_UNMUT: const i64 = 15\n```"
// lsp: hover 46:7 "const G_F32_OVF2: const f32 = inf\n```"
// lsp: hover 47:7 "const G_F32_UND2: const f32 = 0.0\n```"
// lsp: hover 48:7 "const G_F64_OVF: const f64 = inf\n```"
// lsp: hover 49:7 "const G_F64_UND: const f64 = 0.0\n```"
// lsp: hover 50:7 "const G_F32_PREC: const f32 = 16777216.0\n```"
// lsp: hover 51:7 "const G_F32_PREC_AL: const f32 = 16777216.0\n```"
// lsp: hover 52:7 "const G_F32_PI: const f32 = 3.1415927\n```"
// lsp: hover 53:7 "const G_BIG_I: const i64 = 18014401730707455\n```"
// lsp: hover 54:7 "const G_BIG_F_DIR: const f32 = 1.80144e+16\n```"
// lsp: hover 55:7 "const G_BIG_F_AL: const f32 = 1.80144e+16\n```"
// lsp: hover 56:7 "const G_BIG_NOT: const f32 = -1.80144e+16\n```"
// lsp: hover 58:7 "const G_F64_PREC: const f64 = 9007199254740992.0\n```"
// lsp: hover 59:7 "const G_F64_PREC_AL: const f64 = 9007199254740992.0\n```"
// lsp: hover 60:7 "const G_F64_PI: const f64 = 3.141592653589793\n```"
// lsp: hover 61:7 "const G_F64_HEX: const f64 = 12.0\n```"
// lsp: hover 62:7 "const G_NEG_ZERO: const f64 = -0.0\n```"
// lsp: hover 63:7 "const G_I64_MIN: const i64 = -9223372036854775808\n```"
// lsp: hover 64:7 "const G_U64_SRC: const u64 = 9223372586610720769\n```"
// lsp: hover 65:7 "const G_U64_F32: const f32 = 9.223373e+18\n```"
// lsp: hover 66:7 "const G_STR_64: const u8[:] = \"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\"\n```"
// lsp: hover 67:7 "const G_DONT: const u8[:] = \"don't\"\n```"
// lsp: hover 72:11 "const L_RT_LEN: const i64\n```"
// lsp: hover 73:11 "const L_RT_INT: const i64\n```"
// lsp: hover 74:11 "const L_RT_FLT: const f64\n```"
// lsp: hover 75:11 "const L_INL: const i64\n```"
// lsp: hover 77:11 "const L2: const i64 = 10\n```"
// lsp: hover 79:11 "const LF2: const f64 = 1.5\n```"
// lsp: hover 81:11 "const LB2: const bool = true\n```"
// lsp: hover 82:11 "const LB3: const bool = false\n```"
// lsp: hover 84:11 "const LS2: const u8[:] = \"abc\"\n```"
// lsp: hover 85:11 "const LU8: const u8 = 251\n```"
// lsp: hover 86:11 "const LHF: const f64 = 255.0\n```"
// lsp: hover 88:15 "const CF: const u8[:] = \"alpha\"\n```"
// lsp: hover 89:15 "const CF: const u8[:] = \"alpha\"\n```"
// lsp: hover 91:11 "const G_TYPED: const i64 = 10\n```"
// lsp: hover 92:11 "const G_ALIAS: const i64 = 10\n```"
// lsp: hover 93:11 "const G_HEX_ALIAS: const i64 = 255\n```"
// lsp: hover 94:11 "const G_MILLION: const i64 = 1_000_000\n```"
// lsp: hover 95:11 "const G_U8_NOT: const u8 = 251\n```"
// lsp: hover 96:11 "const G_U64_NOT: const u64 = 18446744073709551611\n```"
// lsp: hover 97:11 "const G_F_FROM_HEX: const f64 = 255.0\n```"
// lsp: hover 98:11 "const G_F_FROM_INT: const f64 = 5.0\n```"
// lsp: hover 99:11 "const G_F_ALIAS: const f64 = 1.5\n```"
// lsp: hover 100:11 "const G_INF: const f64 = inf\n```"
// lsp: hover 101:11 "const G_B_NOT: const bool = false\n```"
// lsp: hover 102:11 "const G_B_ALIAS: const bool = true\n```"
// lsp: hover 103:11 "const G_STR_ALIAS: const u8[:] = \"hello\"\n```"
// lsp: hover 104:11 "const G_PNG: const u8[:] = \"\\x89PNG\\r\\n\\x1a\\n\"\n```"
// lsp: hover 105:11 "const G_UNI_EXACT2: const u8[:] = \"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaé...\"\n```"
// lsp: hover 106:11 "const G_UNI_MID3: const u8[:] = \"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa...\"\n```"
// lsp: hover 107:11 "const G_UNI_EXACT4: const u8[:] = \"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa🦆...\"\n```"
// lsp: hover 108:11 "const G_UNI_MID4: const u8[:] = \"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa...\"\n```"
// lsp: hover 109:11 "const G_INL: const i64\n```"
// lsp: hover 110:11 "const L_RT_LEN: const i64\n```"
// lsp: hover 111:11 "const L_RT_INT: const i64\n```"
// lsp: hover 112:11 "const L_RT_FLT: const f64\n```"
// lsp: hover 113:11 "const L_INL: const i64\n```"
// lsp: hover 114:11 "const L2: const i64 = 10\n```"
// lsp: hover 115:11 "const LF2: const f64 = 1.5\n```"
// lsp: hover 116:11 "const LB2: const bool = true\n```"
// lsp: hover 117:11 "const LB3: const bool = false\n```"
// lsp: hover 118:11 "const LS2: const u8[:] = \"abc\"\n```"
// lsp: hover 119:11 "const LU8: const u8 = 251\n```"
// lsp: hover 120:11 "const LHF: const f64 = 255.0\n```"
// lsp: hover 124:11 "const C_EARLY: const i64\n```"
// lsp: hover 125:11 "const C_EARLY: const i64\n```"
// lsp: hover 130:11 "const C_M_DIRECT: const i64\n```"
// lsp: hover 131:11 "const C_M_ADD: const i64\n```"
// lsp: hover 132:11 "const C_M_OR: const i64\n```"
// lsp: hover 133:11 "const C_M_SHL: const i64\n```"
// lsp: hover 134:11 "const C_M_NEG: const i64\n```"
// lsp: hover 135:11 "const C_M_NOT: const i64\n```"
// lsp: hover 136:11 "const C_M_FLT: const f64\n```"
// lsp: hover 137:11 "const C_M_FNOT: const f64\n```"
// lsp: hover 138:11 "const C_M_TYPED: const i64\n```"
// lsp: hover 139:11 "const C_M_ALIAS: const i64\n```"
// lsp: hover 143:11 "const C_MF_CHAIN: const f64\n```"
// lsp: hover 144:11 "const C_MF_NEG: const f64\n```"
// lsp: hover 145:11 "const C_MF_ADD: const f64\n```"
// lsp: hover 146:11 "const G_NAN2: const f64 = nan\n```"
// lsp: hover 147:11 "const G_NINF: const f64 = -inf\n```"
// lsp: hover 148:11 "const G_SHL: const i64 = 256\n```"
// lsp: hover 149:11 "const G_AND: const i64 = 15\n```"
// lsp: hover 150:11 "const G_F32_P1: const f32 = 0.1\n```"
// lsp: hover 151:11 "const G_F32_ALIAS: const f32 = 0.1\n```"
// lsp: hover 152:11 "const G_F32_WIDEN: const f64 = 0.10000000149011612\n```"
// lsp: hover 153:11 "const G_F32_OVF: const f32 = inf\n```"
// lsp: hover 154:11 "const G_F32_UND: const f32 = 0.0\n```"
// lsp: hover 155:11 "const C_UNMUT: const i64 = 15\n```"
// lsp: hover 156:11 "const C_M_DIRECT: const i64\n```"
// lsp: hover 157:11 "const C_M_ADD: const i64\n```"
// lsp: hover 158:11 "const C_M_OR: const i64\n```"
// lsp: hover 159:11 "const C_M_SHL: const i64\n```"
// lsp: hover 160:11 "const C_M_NEG: const i64\n```"
// lsp: hover 161:11 "const C_M_NOT: const i64\n```"
// lsp: hover 162:11 "const C_M_FLT: const f64\n```"
// lsp: hover 163:11 "const C_M_FNOT: const f64\n```"
// lsp: hover 164:11 "const C_M_ALIAS: const i64\n```"
// lsp: hover 165:11 "const C_MF_CHAIN: const f64\n```"
// lsp: hover 166:11 "const C_MF_NEG: const f64\n```"
// lsp: hover 167:11 "const C_MF_ADD: const f64\n```"
// lsp: hover 172:15 "const CF_OVF: const f32 = inf\n```"
// lsp: hover 173:15 "const CF_OVF: const f32 = inf\n```"
// lsp: hover 176:15 "const CF_UND: const f32 = 0.0\n```"
// lsp: hover 177:15 "const CF_UND: const f32 = 0.0\n```"
// lsp: hover 179:11 "const G_F32_OVF2: const f32 = inf\n```"
// lsp: hover 180:11 "const G_F32_UND2: const f32 = 0.0\n```"
// lsp: hover 181:11 "const G_F64_OVF: const f64 = inf\n```"
// lsp: hover 182:11 "const G_F64_UND: const f64 = 0.0\n```"
// lsp: hover 183:11 "const G_F32_PREC: const f32 = 16777216.0\n```"
// lsp: hover 184:11 "const G_F32_PREC_AL: const f32 = 16777216.0\n```"
// lsp: hover 185:11 "const G_F32_PI: const f32 = 3.1415927\n```"
// lsp: hover 186:11 "const G_BIG_F_DIR: const f32 = 1.80144e+16\n```"
// lsp: hover 187:11 "const G_BIG_F_AL: const f32 = 1.80144e+16\n```"
// lsp: hover 188:11 "const G_BIG_NOT: const f32 = -1.80144e+16\n```"
// lsp: hover 192:11 "const G_F64_PREC: const f64 = 9007199254740992.0\n```"
// lsp: hover 193:11 "const G_F64_PREC_AL: const f64 = 9007199254740992.0\n```"
// lsp: hover 194:11 "const G_F64_PI: const f64 = 3.141592653589793\n```"
// lsp: hover 195:11 "const G_F64_HEX: const f64 = 12.0\n```"
// lsp: hover 196:11 "const G_NEG_ZERO: const f64 = -0.0\n```"
// lsp: hover 197:11 "const G_I64_MIN: const i64 = -9223372036854775808\n```"
// lsp: hover 198:11 "const G_U64_F32: const f32 = 9.223373e+18\n```"
// lsp: hover 199:11 "const G_STR_64: const u8[:] = \"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\"\n```"
// lsp: hover 200:11 "const G_DONT: const u8[:] = \"don't\"\n```"
// lsp: hover 201:11 "const TRAIL_ZERO: const f64 = 1.5\n```"
// lsp: hover 202:11 "const TRAIL_ZERO: const f64 = 1.5\n```"
