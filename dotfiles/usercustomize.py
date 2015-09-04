#!/usr/bin/env python

# NOTE this code is wrapped in a class (closure) to minimize pollution
#  of global namespace after it executes.


import os
import sys
import __main__ as main

class _UserCustom(object):
    __startup__ = os.environ.get('PYTHONSTARTUP', None)



    @classmethod
    def interactive(cls):
        filepath = getattr(main, '__file__', None)

        if sys.flags.interactive: # invoked with -i
            return 1 if (not filepath) else 2

        # NOTE: other cases here removed;
        # In practice we really only want our shell features applied
        # when python is loaded as a REPL (`python`, no args), or
        # when python is loaded wit interactive mode "-i".
        # We do not need to infer other states from the TTY status of
        # sys.stdout, or really any other components.

        else:
            return 0

    @classmethod
    def valid_startup(cls):
        result = os.path.expanduser(cls.__startup__)
        return result if (os.path.isfile(result)) else None

    @classmethod
    def _import(cls):
        _path = cls.valid_startup()
        _interactive = cls.interactive()
        # print >>sys.stderr, "Interactive mode %r" % _interactive
        if _path and (_interactive in (1,2)):
            execfile(_path, { 'RUN_INTERACTIVE': _interactive })




# OK, run.
_UserCustom._import()



