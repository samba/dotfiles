#!/usr/bin/env python

import os, sys
__startup__ = os.environ.get('PYTHONSTARTUP', None)

if __startup__ and os.isatty(sys.stdout.fileno()):
    __startup__ = os.path.expanduser(__startup__)
    if os.path.isfile(__startup__):
        execfile(__startup__)
