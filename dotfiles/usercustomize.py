#!/usr/bin/env python

import os, sys
import __main__ as main

from ctypes import cast, c_int, c_char_p, POINTER, pythonapi

__startup__ = os.environ.get('PYTHONSTARTUP', None)


def _is_interactive(startup_file):
    startup_valid = (startup_file and os.path.isfile(startup_file))
    interactive_flag = sys.flags.interactive 
    terminal = os.isatty(sys.stdout.fileno()),

    if not terminal:
        return 0

    elif interactive_flag: # -i was invoked.
        return (startup_valid) and 1

    elif not hasattr(main, '__file__'): # called as "-c <command>" (or with no args).
        return startup_valid and 2 

    else:
        return 0 


if __startup__:
    __startup__ = os.path.expanduser(__startup__)
    _interactive_mode = _is_interactive(__startup__)
    if _interactive_mode: 
        execfile(__startup__, {'interactive': _interactive_mode})
