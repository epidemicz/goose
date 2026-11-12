// Goose compiler — the builtin function table. Builtins are ordinary
// functions reachable both as f(a, b) and, per UFCS, as a.f(b); the entries
// flagged BF_MEMBER are the array operations (§3.3, §5.4), which resolution
// tries before user functions at a.f() sites (§7.1) — their receiver is
// simply the first argument. BF_PROPERTY entries (.len/.cap) are field-like
// accesses, not calls.
//
// The table is one X-macro so the enum, name, arity, receiver rules,
// signature and the arrays a builtin grows or shrinks can never drift apart.
// The checking code in typecheck_builtins.h (CheckBuiltin) works from all of
// them; an entry whose arguments or result a signature cannot express
// (polymorphic arguments, explicit type arguments, kind-dependent forms) has
// "" for that part and gets dedicated code there, dispatched on the enum.
//
// Signature characters, applying to the arguments after the receiver for
// members: i int, e construct one element of the receiver's element type, a
// an array/slice of that element type; an e or an a also gives a pending
// `var x = []` receiver its element type (§4.2). Return characters: i int,
// e element value, r reference to an element, s slice of elements (a slice
// pool's, rooted at the receiver like r).
//
// `grows` is what the builtin does to the array it grows, as a diagnostic
// about the growth says it (§1.3(4)) -- "push into" for push -- or "" where
// it grows none. That array is the receiver, or under BF_OUTARG the `out`
// array a call may pass as its second argument.
#pragma once

namespace goose {

enum BuiltinFlags {
    BF_MEMBER    = 1 << 0,  // First argument is an array receiver.
    BF_PROPERTY  = 1 << 1,  // .name access, not a call.
    BF_TYARGS    = 1 << 2,  // Takes an explicit <T> list.
    BF_WRITE     = 1 << 3,  // Receiver needs writable provenance (§9.5).
    BF_REUSABLE  = 1 << 4,  // Receiver must be a reusable pool of slots (§5.4).
    BF_SHRINKS   = 1 << 5,  // May shrink its receiver (§5.1, §5.2).
    BF_SLICEPOOL = 1 << 6,  // Receiver must be a reusable[] pool of slices (§5.4).
    BF_OUTARG    = 1 << 7,  // Grows its second argument, an `out` array.
};

// Receiver kind masks (members only): which array flavors have the member.
enum BuiltinRecv {
    BR_FIXED = 1 << 0, BR_VAR = 1 << 1, BR_LIMITED = 1 << 2,
    BR_GROW = 1 << 3, BR_GROWSHRINK = 1 << 4, BR_SLICE = 1 << 5,
    BR_ANY = BR_FIXED | BR_VAR | BR_LIMITED | BR_GROW | BR_GROWSHRINK | BR_SLICE,
    BR_GROWABLE = BR_LIMITED | BR_GROW | BR_GROWSHRINK,
    // Array kinds `index_of` accepts (§3.3): fixed strides once the element
    // type is fixed-size, which the check requires on top of this.
    BR_INDEXABLE = BR_FIXED | BR_LIMITED | BR_GROW | BR_GROWSHRINK,
    // A grow-only array shrinks too, where the checker can see that nothing is
    // rooted in it (§5.1, CheckGrowShrink in typecheck_builtins.h).
    BR_SHRINKABLE = BR_LIMITED | BR_GROWSHRINK | BR_GROW,
};

// The receiver kind of a (dereferenced) type: one BR_ bit for an array
// or slice, nothing for any other type.
inline int RecvKindOf(TypeExpr *t) {
    if (t->kind == TY_SLICE) return BR_SLICE;
    if (t->kind != TY_ARRAY) return 0;
    switch (t->arr->akind) {
        case A_FIXED:      return BR_FIXED;
        case A_VAR:        return BR_VAR;
        case A_LIMITED:    return BR_LIMITED;
        case A_GROW:       return BR_GROW;
        case A_GROWSHRINK: return BR_GROWSHRINK;
    }
    return 0;
}

// `params` are the display labels after the receiver, ", "-separated
// ("args…" is the variadic tail); `ty` the type parameters, e.g. "<T>";
// `doc` is one sentence, the reference's own wording (docs/reference.md
// §25, §5, §22, §23, §14) where it gives one, "" where the name and the
// signature already say it. All three are display only: the checker works
// from args/rets, and a checked call's return from its own rettypes, so
// they can never change checking.
//
//        enum            name                min max  args  rets recv            grows          flags                                     params, ty, doc
#define BUILTINS \
    F(B_PRINT,            "print",            0, 99,   "",   "",  0,              "",            0, "args…", "", "the arguments' text and a newline, as one write") \
    F(B_STR,              "str",              0, 99,   "",   "",  0,              "",            0, "args…", "", "the text as a fresh string, built at its destination") \
    F(B_FORMAT,           "format",           1, 99,   "",   "",  BR_GROWABLE,    "format into", BF_MEMBER | BF_WRITE, "args…", "", "the text appended to `out`, any growable `u8` array") \
    F(B_ASSERT,           "assert",           1,  1,   "",   "",  0,              "",            0, "c", "", "aborts unless `c`, a `bool` or an optional, which it narrows") \
    F(B_ABORT,            "abort",            1,  1,   "",   "",  0,              "",            0, "msg: u8[:]", "", "") \
    F(B_EXIT,             "exit",             1,  1,   "",   "",  0,              "",            0, "code: i64", "", "") \
    F(B_HARDWARE_THREADS, "hardware_threads", 0,  0,   "",   "i", 0,              "",            0, "", "", "") \
    F(B_THREAD_SPAWN,     "thread_spawn",     1, 99,   "",   "i", 0,              "",            0, "worker, args…", "", "starts a worker; its id, never reused") \
    F(B_THREAD_SPAWN_CONTAINED, "thread_spawn_contained", 1, 99, "", "i", 0,       "",            0, "worker, args…", "", "starts a worker whose aborts end only that worker") \
    F(B_THREAD_WAIT,      "thread_wait",      1,  2,   "",   "",  0,              "append to",   BF_OUTARG, "id: i64, msg: u8[>..]", "", "blocks until that worker has ended and its storage is released; `false` if it was contained and aborted; with `msg`, the first such wait appends a contained worker's abort message to it") \
    F(B_QPUT,             "qput",             1,  1,   "",   "",  0,              "",            0, "v", "", "puts `v` on the queue for its type; `false`, at once, if the queue is full") \
    F(B_QGET,             "qget",             0,  1,   "",   "",  0,              "",            BF_TYARGS, "ms: i64", "<T>", "takes the next `T`, blocking; with `ms`, waits at most that many milliseconds, else `T`'s zero value and `false`") \
    F(B_QPOLL,            "qpoll",            0,  0,   "",   "",  0,              "",            BF_TYARGS, "", "<T>", "takes one if there is one; else `T`'s zero value and `false`") \
    F(B_QLIMIT,           "qlimit",           1,  1,   "",   "",  0,              "",            BF_TYARGS, "n: i64", "<T>", "lets the queue for `T` hold at most `n` messages") \
    F(B_DEFAULT,          "default",          0,  0,   "",   "",  0,              "",            BF_TYARGS, "", "<T>", "the value a fixed-size `T` has before anything is written to it, declared defaults applied") \
    F(B_COPY,             "copy",             1,  1,   "",   "",  0,              "",            0, "x", "", "a fresh copy of the stored value `x` names") \
    F(B_MOVE_FROM,        "move_from",        2,  2,   "",   "",  BR_SLICE,       "",            BF_MEMBER | BF_WRITE, "src: T[:]", "", "copies equal-length slices with overlap-safe ordering") \
    F(B_TO_BYTES,         "to_bytes",         1,  2,   "",   "",  BR_ANY,         "append to",   BF_MEMBER | BF_OUTARG, "out: u8[>..]", "", "a framed image of the array: a varint byte count, then its element region; fresh, or appended to `out`") \
    F(B_BYTES_OF,         "bytes_of",         1,  1,   "",   "",  BR_ANY,         "",            BF_MEMBER, "", "", "the element region alone, as a read-only view: nothing copied") \
    F(B_FROM_BYTES,       "from_bytes",       1,  1,   "",   "",  0,              "",            BF_TYARGS, "b: u8[:]", "<A>", "a **verified** array from an untrusted image; `false` and an empty array if it is not one") \
    F(B_EMBED_SHADER,     "embed_shader",     1, 99,   "",   "",  0,              "",            0, "args…", "", "a compiled shader, read at compile time") \
    F(B_EMBED_FILE,       "embed_file",       1,  1,   "",   "",  0,              "",            0, "path", "", "a file's bytes, read at compile time") \
    F(B_FILE,             "src_file",         0,  0,   "",   "",  0,              "",            0, "", "", "") \
    F(B_LINE,             "src_line",         0,  0,   "",   "i", 0,              "",            0, "", "", "") \
    F(B_LEN,              "len",              1,  1,   "",   "i", BR_ANY,         "",            BF_MEMBER | BF_PROPERTY, "", "", "") \
    F(B_CAP,              "cap",              1,  1,   "",   "i", BR_LIMITED,     "",            BF_MEMBER | BF_PROPERTY, "", "", "") \
    F(B_INDEX_OF,         "index_of",         2,  2,   "",   "i", BR_INDEXABLE,   "",            BF_MEMBER, "r: T&", "", "the index of the element `r` refers to") \
    F(B_RANGE_INDEX,      "range_index",      2,  3,   "",   "i", BR_INDEXABLE,   "",            BF_MEMBER, "s: T[:], msg: u8[:]", "", "the start of a wholly contained slice; checked when provenance does not prove it") \
    F(B_CHECK_LENGTH,     "check_length",     2,  3,   "i",  "i", BR_GROW | BR_GROWSHRINK, "",     BF_MEMBER, "n: i64, msg: u8[:]", "", "validates a count against the data-stack reservation; returns it without changing the array") \
    F(B_PUSH,             "push",             2,  2,   "e",  "r", BR_GROWABLE,    "push into",   BF_MEMBER | BF_WRITE, "v: T", "", "one element, constructed in place; returns a reference to it") \
    F(B_APPEND,           "append",           2,  2,   "a",  "",  BR_GROWABLE,    "append to",   BF_MEMBER | BF_WRITE, "src", "", "the elements of an array, slice or array literal, copied in") \
    F(B_POP,              "pop",              1,  1,   "",   "e", BR_SHRINKABLE,  "",            BF_MEMBER | BF_WRITE | BF_SHRINKS, "", "", "") \
    F(B_POP_N,            "pop_n",            2,  2,   "i",  "",  BR_SHRINKABLE,  "",            BF_MEMBER | BF_WRITE | BF_SHRINKS, "n: i64", "", "") \
    F(B_RESIZE,           "resize",           2,  3,   "",   "",  BR_SHRINKABLE,  "resize",      BF_MEMBER | BF_WRITE | BF_SHRINKS, "n: i64, v: T", "", "grows with copies of `v`, or shrinks") \
    F(B_CLEAR,            "clear",            1,  1,   "",   "",  BR_SHRINKABLE,  "",            BF_MEMBER | BF_WRITE | BF_SHRINKS, "", "", "") \
    F(B_ALLOC_INDEX,      "alloc_index",      2,  2,   "e",  "i", BR_GROW,        "allocate in", BF_MEMBER | BF_WRITE | BF_REUSABLE, "v: T", "", "Deprecated: use `slot_pool`. The index of a slot holding `v`: a freed slot if there is one, else a fresh push") \
    F(B_ALLOC_REF,        "alloc_ref",        2,  2,   "e",  "r", BR_GROW,        "allocate in", BF_MEMBER | BF_WRITE | BF_REUSABLE, "v: T", "", "Deprecated: use `slot_pool`. The same, as a reference") \
    F(B_FREE,             "free",             2,  2,   "i",  "",  BR_GROW,        "",            BF_MEMBER | BF_WRITE | BF_REUSABLE, "i: i64", "", "Deprecated: use `slot_pool`. Records slot `i` for reuse; aborts if `i` is out of range") \
    F(B_ALLOC_SLICE,      "alloc_slice",      2,  2,   "",   "s", BR_GROW,        "allocate in", BF_MEMBER | BF_WRITE | BF_SLICEPOOL, "n: i64", "", "Deprecated: use `slice_pool`. `n` elements from the first free span that holds them, else from the end of the array, which grows; every returned element is reset to its default") \
    F(B_REALLOC_SLICE,    "realloc_slice",    3,  3,   "",   "s", BR_GROW,        "allocate in", BF_MEMBER | BF_WRITE | BF_SLICEPOOL, "s: T[:], n: i64", "", "Deprecated: use `slice_pool`. `s` resized to `n` elements, in place where it can be, else freed and copied to where `alloc_slice(n)` puts it") \
    F(B_FREE_SLICE,       "free_slice",       2,  2,   "",   "",  BR_GROW,        "",            BF_MEMBER | BF_WRITE | BF_SLICEPOOL, "s: T[:]", "", "Deprecated: use `slice_pool`. Records the run `s` for reuse")

enum BuiltinKind {
    #define F(k, n, lo, hi, a, r, rv, gr, fl, p, t, d) k,
    BUILTINS
    #undef F
    B_COUNT
};

struct BuiltinDef {
    BuiltinKind kind;
    const char *name;
    int minargs, maxargs;      // Receiver included for members.
    const char *args;          // Post-receiver argument signature; "" = none/custom.
    const char *rets;          // Return signature; "" = void or custom.
    int recv;                  // BuiltinRecv mask for members.
    const char *grows;         // What a growth by it is called; "" = grows nothing.
    int flags;
    const char *params;        // Display labels after the receiver; "" = none.
    const char *ty;            // Display type parameters; "" = none.
    const char *doc;           // One sentence for hover and completion; "" = none.
};

inline const BuiltinDef builtindefs[] = {
    #define F(k, n, lo, hi, a, r, rv, gr, fl, p, t, d) { k, n, lo, hi, a, r, rv, gr, fl, p, t, d },
    BUILTINS
    #undef F
};

// The first definition of that name. Every call and member access asks.
inline const BuiltinDef *LookupBuiltin(string_view name) {
    static const auto byname = [] {
        unordered_map<string_view, const BuiltinDef *> m;
        for (auto &d : builtindefs) m.emplace(d.name, &d);
        return m;
    }();
    auto it = byname.find(name);
    return it == byname.end() ? nullptr : it->second;
}

// The definition of a kind a checked Call records (Call::builtin).
inline const BuiltinDef &BuiltinByKind(int kind) {
    assert(kind >= 0 && kind < (int)(sizeof(builtindefs) / sizeof(builtindefs[0])) &&
           builtindefs[kind].kind == kind);
    return builtindefs[kind];
}

}  // namespace goose
