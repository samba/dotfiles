#!/usr/bin/env python

# NOTE this code is wrapped in a class (closure) to minimize pollution
#  of global namespace after it executes.


import os
import sys

try:
    import __main__ as main
except ImportError:
    main = None

class _UserCustom(object):
    __startup__ = os.environ.get('PYTHONSTARTUP', None)

    @classmethod
    def interactive(cls):
        filepath = main and getattr(main, '__file__', None)

        # Somehow it was being loaded "interactively" by AppEngine and other SDKs
        # and throwing errors, so now we'll validate that it's loading via terminal.
        terminal = os.isatty(sys.stdin.fileno()) and os.isatty(sys.stdout.fileno())

        if terminal and (sys.flags.interactive > 0): # invoked with -i
            return 1 if (not filepath) else 2

        # NOTE: other cases here removed;
        # In practice we really only want our shell features applied
        # when python is loaded as a REPL (`python`, no args), or
        # when python is loaded wit interactive mode "-i".

        else:
            return 0

    @classmethod
    def valid_startup(cls):
        result = cls.__startup__ and os.path.expanduser(cls.__startup__)
        return result if (os.path.isfile(result)) else None

    @classmethod
    def _import(cls):
        _interactive = cls.interactive()
        _path = (_interactive in (1, 2)) and cls.valid_startup()

        # print >>sys.stderr, "<%s> Interactive mode %r" % (__file__, _interactive)
        # print "<%s> Interactive mode %r" % (__file__, _interactive)
        
        if _path:
            execfile(_path, { 'RUN_INTERACTIVE': _interactive })




# OK, run.
_UserCustom._import()



