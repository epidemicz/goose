// lsp: fixture for test/lsp_protocol.py. The `lsp:` lines below it are the
// queries it asks of the server and what they must answer; lines and
// columns are 1-based, as the compiler counts them.
import std;
import helper;

// A point.
struct Point {
    // Its x.
    x: i64,
    y: i64,
}

// Adds two numbers.
fn add<T>(a: T, b: T) -> T { a + b }

enum Shape {
    Circle { r: i64 },
    Square,
}

fn area(s: Shape) -> i64 {
    match s {
        Circle c => c.r * c.r * 3,
        Square => 1,
    }
}

fn main() {
    let p = Point { x: 1, y: 2 };
    let sum = add(p.x, p.y);
    let f = add(1.5, 2.5);
    print(sum);
    print(f);
    print(area(Shape.Square)); const_hover_more(); const_hover_local();
    print(helper::twice(sum));
    var v: i64[>..] = [];
    v.push(sum);
    print(v.len);
}

// Called by nothing.
fn spare(x) { x }
// Const hover values: the initializer shows in the header.
const HEX = 0xFF;
const LONG = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";

fn const_hover() {
    const X, Y = 1, 2;
    print(X);
    print(Y);
    print(HEX);
    print(LONG);
}
// More const hover values: every literal kind, plus cases that show none.
const F = 1.5;
const B = true;
const CH = 'a';
const NEG = -5;
const BIG = 18446744073709551615;
const TEN = 10;
const ALIAS = TEN;
const E = Shape.Square;
const P = Point { x: 1, y: 2 };
const UNI = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaébbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";

fn const_hover_more() {
    print(ALIAS);
    print(UNI);
    let lit = 42;
    print(lit);
    print(NEG);
}
fn const_hover_local() {
    const LNEG = -5;
    const LALIAS = TEN;
    const M, N = 1, "s";
    print(LNEG);
    print(LALIAS);
    print(M);
    print(N);
}

// lsp: hover 31:15 "fn add<T>(a: T, b: T) -> T"
// lsp: hover 31:15 "Adds two numbers."
// lsp: hover 31:21 "x: i64"
// lsp: hover 31:21 "Its x."
// lsp: hover 30:13 "struct Point"
// lsp: hover 24:23 "r: i64"
// lsp: hover 15:30 "parameter a: i64"
// lsp: hover 15:30 "a: f64"
// lsp: hover 15:14 "type parameter T"
// lsp: hover 35:22 "Shape.Square"
// lsp: hover 33:11 "let sum: i64"
// lsp: hover 36:19 "fn helper::twice(x: i64) -> i64"
// lsp: hover 38:7 "builtin fn push(a, v: T) -> T&"
// lsp: hover 39:13 "builtin .len: i64"
// lsp: definition 31:15 -> 15:4
// lsp: definition 31:21 -> 10:5
// lsp: definition 30:13 -> 8:8
// lsp: definition 35:22 -> 19:5
// lsp: definition 33:11 -> 31:9
// lsp: definition 15:30 -> 15:11
// lsp: definition 36:19 -> helper.goose
// lsp: definition 5:3 -> helper.goose
// lsp: symbol Point struct
// lsp: symbol add function
// lsp: symbol Shape enum
// lsp: symbol main function
// lsp: signature 31:19 "fn add<T>(a: T, b: T) -> T" 0
// lsp: signature 31:24 "fn add<T>(a: T, b: T) -> T" 1
// lsp: token 15:4 function
// lsp: token 8:8 struct
// lsp: token 31:15 function
// lsp: token 31:21 property
// lsp: token 33:11 variable
// lsp: token 15:30 parameter
// lsp: token 30:21 property
// lsp: token 24:9 enumMember
// lsp: hover 30:21 "x: i64"
// lsp: hover 24:9 "Shape.Circle { r: i64 }"
// lsp: definition 30:21 -> 10:5
// lsp: definition 24:9 -> 18:5
// lsp: definition 24:21 -> 24:16
// lsp: definition 15:14 -> 15:8
// lsp: references 31:15 3
// lsp: references 15:8 4
// lsp: references 10:5 4
// lsp: references 18:5 2
// lsp: references 24:16 3
// lsp: references 22:9 2
// lsp: references 37:9 3
// lsp: references 36:19 2
// lsp: rename 31:15 plus -> 3
// lsp: rename 30:9 q -> 3
// lsp: rename 15:8 U -> 4
// lsp: rename 24:9 Disc -> 2
// lsp: rename 36:19 double -> 2
// lsp: rename 38:7 shove -> error
// lsp: rename 33:5 shout -> error
// lsp: rename 31:5 be -> error
// lsp: hint 30:10 ": Point"
// lsp: hint 31:12 ": i64"
// lsp: hint 32:10 ": f64"
// lsp: hint 31:19 "a:"
// lsp: hint 31:24 "b:"
// lsp: hint 32:17 "a:"
// lsp: hint 35:16 "s:"
// lsp: hint 36:25 "x:"
// lsp: folding 1-3
// lsp: folding 8-12
// lsp: folding 17-20
// lsp: folding 22-27
// lsp: folding 23-26
// lsp: folding 29-40
// lsp: selection 31:21 -> 31:21-31:22
// lsp: selection 31:21 -> 31:19-31:22
// lsp: selection 31:21 -> 31:15-31:28
// lsp: selection 31:21 -> 29:1-40:2
// lsp: lens 15 "2 instantiations"
// lsp: lens 29 "Run"
// lsp: lens 43 "not instantiated"
// lsp: incoming 15:4 -> main@31,32
// lsp: incoming 31:15 -> main@31,32
// lsp: incoming 36:19 -> main@36
// lsp: incoming 43:4 -> -
// lsp: outgoing 29:4 -> add@31,32 area@35 twice@36 const_hover_more@35 const_hover_local@35
// lsp: outgoing 22:4 -> -
// lsp: incoming 33:11 -> none
// lsp: hover 45:7 "const HEX: const i64 = 0xFF // 255"
// lsp: hover 46:7 "const LONG: const u8[:] = \"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa...\""
// lsp: hover 49:11 "const X: const i64 = 1"
// lsp: hover 49:14 "const Y: const i64 = 2"
// lsp: hover 50:11 "const X: const i64 = 1"
// lsp: hover 51:11 "const Y: const i64 = 2"
// lsp: hover 52:11 "const HEX: const i64 = 0xFF // 255"
// lsp: hover 53:11 "const LONG: const u8[:] = \"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa...\""
// lsp: hover 56:7 "const F: const f64 = 1.5"
// lsp: hover 57:7 "const B: const bool = true"
// lsp: hover 58:7 "const CH: const i64 = 'a' // 97"
// lsp: hover 59:7 "const NEG: const i64 = -5"
// lsp: hover 60:7 "const BIG: const u64 = 18446744073709551615"
// lsp: hover 61:7 "const TEN: const i64 = 10"
// lsp: hover 62:7 "const ALIAS: const i64 = 10"
// A hover want ending in \n``` pins the whole header: anything appended to it (like a value) fails the match.
// lsp: hover 63:7 "const E: const Shape\n```"
// lsp: hover 64:7 "const P: const Point\n```"
// lsp: hover 65:7 "const UNI: const u8[:] = \"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa...\""
// lsp: hover 68:11 "const ALIAS: const i64 = 10"
// lsp: hover 69:11 "const UNI: const u8[:] = \"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa...\""
// lsp: hover 72:11 "const NEG: const i64 = -5"
// lsp: hover 70:9 "let lit: i64\n```"
// lsp: hover 71:11 "let lit: i64\n```"
// lsp: hover 75:11 "const LNEG: const i64 = -5"
// lsp: hover 76:11 "const LALIAS: const i64 = 10"
// lsp: hover 77:11 "const M: const i64 = 1"
// lsp: hover 77:14 "const N: const u8[:] = \"s\""
// lsp: hover 78:11 "const LNEG: const i64 = -5"
// lsp: hover 79:11 "const LALIAS: const i64 = 10"
// lsp: hover 80:11 "const M: const i64 = 1"
// lsp: hover 81:11 "const N: const u8[:] = \"s\""
