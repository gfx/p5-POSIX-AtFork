#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <pthread.h>
void *__dso_handle __attribute__((__visibility__("hidden"))) __attribute__((weak)) = &__dso_handle;

static void run_callbacks () {
    dTHX;
    char* argv[2];
    // The cast is safe: call_argv accepts a char**, and iterates through the
    // array by incrementing the outer pointer, but the inner char* is just
    // supplied to newSV* functions that copy it rather than mutating.
    argv[0] = PL_op ? (char*)OP_NAME(PL_op) : "(unknown)";
    argv[1] = NULL;
    call_argv("POSIX::AtFork::_run_callbacks", G_VOID | G_KEEPERR | G_DISCARD, argv);
}

MODULE = POSIX::AtFork    PACKAGE = POSIX::AtFork    PREFIX = posix_atfork_
BOOT:
{
    // Without this, callbacks that try to die/exit the interpreter
    // hang on a futex lock. This is likely due to quirks in certain
    // glibc/GCC toolchains' implementations of __register_atfork.
    pthread_atfork(run_callbacks, run_callbacks, run_callbacks);
}
