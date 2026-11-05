/* The C side of queue_c_push.goose: a thread Goose did not start pushes
   flat Tick values into the program's Tick queue through the accessor the
   compiler emits for it (gs_queue_push_Tick_g, §11.2). No Goose code runs
   on this thread; the values arrive by copy, as qput would send them.
   timer_burst pushes from the calling thread instead, to show the
   accessor's limit behaviour: with a limit of 2, 10 pushes queue 2 and
   drop 8, counted here on the C side. */
#include <stdint.h>
#include <stdlib.h>

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include <windows.h>
#include <process.h>
#else
#include <pthread.h>
#include <time.h>
#endif

/* The image of struct Tick { timer: i64, seq: i64 } in the generated C:
   two int64_t, 16 bytes. The accessor's name is the type's mangled name. */
typedef struct { int64_t timer; int64_t seq; } tick_t;

uint8_t gs_queue_push_Tick_g(const void *data, int64_t size);

static int64_t dropped;

static void sleep_ms(long ms) {
#ifdef _WIN32
    Sleep((DWORD)ms);
#else
    struct timespec ts;
    ts.tv_sec = ms / 1000;
    ts.tv_nsec = (ms % 1000) * 1000000L;
    nanosleep(&ts, NULL);
#endif
}

#ifdef _WIN32
static unsigned __stdcall timer_thread(void *arg) {
    (void)arg;
    for (int64_t seq = 1; seq <= 3; seq++) {
        sleep_ms(100);
        tick_t tick = { 1, seq };
        gs_queue_push_Tick_g(&tick, sizeof(tick));
    }
    return 0;
}
#else
static void *timer_thread(void *arg) {
    (void)arg;
    for (int64_t seq = 1; seq <= 3; seq++) {
        sleep_ms(100);
        tick_t tick = { 1, seq };
        gs_queue_push_Tick_g(&tick, sizeof(tick));
    }
    return NULL;
}
#endif

void timer_start(void) {
#ifdef _WIN32
    uintptr_t h = _beginthreadex(NULL, 0, timer_thread, NULL, 0, NULL);
    if (h) CloseHandle((HANDLE)h);   /* detached: it ends on its own */
#else
    pthread_t th;
    if (pthread_create(&th, NULL, timer_thread, NULL) == 0) pthread_detach(th);
#endif
}

void timer_burst(void) {
    for (int64_t seq = 1; seq <= 10; seq++) {
        tick_t tick = { 1, seq };
        if (!gs_queue_push_Tick_g(&tick, sizeof(tick))) dropped++;
    }
}

int64_t timer_dropped(void) { return dropped; }
