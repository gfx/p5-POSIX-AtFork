#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <pthread.h>
#include <errno.h>

// Without this, callbacks that try to die/exit the interpreter
// hang on a futex lock. This is likely due to quirks in certain
// glibc/GCC toolchains' implementations of __register_atfork. Alternatively,
// it might be due to conflicting libc versions used by pthread versus
// this library? Or something else? Some users that have encountered
// this issue suggest working around it using an "extern". This breaks
// (generates a bad binary that SIGBUSes) on non-glibc/non-GCC environments.
// Instead, this existing definition appears to hint at a reference count
// or similar that gets the right value into the __dso_handle reference
// wrangled by __register_atfork and the fork(2) implementation.
// Related reading:
// - https://github.com/genodelabs/genode/issues/437
// - https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=223110
// - https://bugs.launchpad.net/ubuntu/+source/perl/+bug/24406
// - http://stackoverflow.com/questions/28003587
void *__dso_handle __attribute__((__visibility__("hidden"))) __attribute__((weak)) = &__dso_handle;

static char* cbargs[3] = {NULL, NULL, NULL};

static void paf_run_callbacks (char* type) {
    cbargs[1] = type;
    dTHX;
    if ( strcmp(type, "child") == 0 ) {
        IV pid = PerlProc_getpid();    
        SV* pidsv = get_sv("$", GV_ADD);
        
        if (pid != sv_2iv_flags(pidsv, SV_GMAGIC)) {
            SvREADONLY_off(pidsv);
            sv_setiv(pidsv, (IV)pid);
            SvREADONLY_on(pidsv);
        }
    }

    // The cast is safe: call_argv accepts a char**, and iterates through the
    // array by incrementing the outer pointer, but the inner char* is just
    // supplied to newSV* functions that copy it rather than mutating.
    cbargs[0] = PL_op ? (char*)OP_NAME(PL_op) : "(unknown)";
    call_argv("POSIX::AtFork::_run_callbacks", G_VOID | G_KEEPERR | G_DISCARD, cbargs);
}

static void paf_child() {
    paf_run_callbacks("child");
}

static void paf_parent() {
    paf_run_callbacks("parent");
}

static void paf_prepare() {
    paf_run_callbacks("prepare");
}

MODULE = POSIX::AtFork    PACKAGE = POSIX::AtFork    PREFIX = posix_atfork_
BOOT:
pthread_atfork(paf_prepare, paf_parent, paf_child);
