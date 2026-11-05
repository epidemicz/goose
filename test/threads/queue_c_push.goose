// A foreign C thread pushes flat values into a typed queue (§11.2): the
// compiler emits gs_queue_push_Tick_g for the queue, and the C in
// queue_c_push.c calls it from a thread Goose did not start. No Goose
// code runs on that thread; the values arrive by copy, as qput would
// send them, and a blocked qget wakes for them. The burst phase shows
// the accessor's limit behaviour through the same call: with a limit of
// 2, 10 pushes queue 2 and drop 8, counted on the C side.
struct Tick { timer: i64, seq: i64 }

extern fn timer_start();
extern fn timer_burst();
extern fn timer_dropped() -> i64;

fn main() {
    print("phase 1: blocked qget, timer pushes 3 ticks at 100ms");
    timer_start();
    for i in 3 {
        let t = qget<Tick>();
        print("  got timer=", t.timer, " seq=", t.seq);
    }
    print("phase 2: limit 2, burst 10 while not consuming");
    qlimit<Tick>(2);
    timer_burst();
    var drained = 0;
    loop {
        let t, got = qpoll<Tick>();
        if !got { break; }
        print("  drained timer=", t.timer, " seq=", t.seq);
        drained += 1;
    }
    print("  drained=", drained, " dropped_on_c_side=", timer_dropped());
    print("done");
}
