#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <pthread.h>

static void run_callbacks () {
    dTHX;
    ENTER;
    SAVETMPS;
    dSP;
    PUSHMARK(SP);
    mXPUSHs(newSVpv(PL_op ? OP_NAME(PL_op) : "(unknown)", 0));
    PUTBACK;
    call_pv("POSIX::AtFork::_run_callbacks", G_VOID | G_KEEPERR | G_DISCARD);
    FREETMPS;
    LEAVE;
}

MODULE = POSIX::AtFork    PACKAGE = POSIX::AtFork    PREFIX = posix_atfork_
BOOT:
{
    pthread_atfork(run_callbacks, run_callbacks, run_callbacks);
}
