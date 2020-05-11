from libcpp cimport bool
from libc.stdint cimport uint32_t
from libcpp.functional cimport function

from .exceptions cimport CPythonException, raise_py_error
from .glue cimport CPythonicCallbackWrapper


cdef extern from "kaacore/timers.h" nogil:
    ctypedef function[void()] CTimerCallback "kaacore::TimerCallback"

    cdef cppclass CTimer "kaacore::Timer":
        CTimer()
        CTimer(const uint32_t interval,
            const CTimerCallback callback, const bool single_shot
        )

        void start() except +raise_py_error
        bool is_running()
        void stop()

cdef extern from "extra/include/pythonic_callback.h":
    ctypedef void (*CythonTimerCallback)(CPythonException&, const CPythonicCallbackWrapper&)
    CythonTimerCallback bind_cython_timer_callback(
        const CythonTimerCallback cy_handler,
        const CPythonicCallbackWrapper callback
    )
