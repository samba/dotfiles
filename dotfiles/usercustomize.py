#!/usr/bin/env python

import os
__startup__ = os.environ.get('PYTHONSTARTUP', None) 
if __startup__:
    __startup__ = os.path.expanduser(__startup__)
    if os.path.isfile(__startup__):
        execfile(__startup__)
