# ~/.pythonrc

import sys

# enable syntax completion via tab
try:
    import readline
except ImportError:
    print "Module readline not available."
else:
    import rlcompleter
    readline.parse_and_bind("tab: complete")
    readline.parse_and_bind("bind ^I rl_complete") # for Mac OS X

try:
    import pprint
except:
    pass

import re
import sys
import os
import math
import random
import uuid
import hashlib
import datetime
import time
import getpass
import socket



def concat(*props):
    return ';'.join([ str(i) for i in props ])




class Prompt(object):

    CTRL_BASE = '\001\033[%sm\002'
    CTRL_RESET = '\001\033[0m\002'

    RE_PARSER_COLOR = re.compile(r'<([a-zA-Z]+)>')
    RE_PARSER_ATTRIB = re.compile('\{([a-zA-Z\_\-]+)\}')

    CODE_BOLD = 1
    CODE_DIM = 2
    CODE_UNDERLINE = 4
    CODE_BLINK = 5
    CODE_INVERT = 7
    CODE_HIDDEN = 8

    CODE_RESET_ALL = 0
    CODE_RESET_OFFSET = 20
    CODE_BACKGROUND_OFFSET = 10

    COLOR_DEFAULT = 39
    COLOR_BLACK = 30
    COLOR_RED = 31
    COLOR_GREEN = 32
    COLOR_YELLOW = 33
    COLOR_BLUE = 34
    COLOR_MAGENTA = 35
    COLOR_CYAN = 36
    COLOR_GRAY_LIGHT = 37
    COLOR_GRAY_DARK = 90
    COLOR_RED_LIGHT = 91
    COLOR_GREEN_LIGHT = 92
    COLOR_YELLOW_LIGHT = 93
    COLOR_BLUE_LIGHT = 94
    COLOR_MAGENTA_LIGHT = 95
    COLOR_CYAN_LIGHT = 96
    COLOR_WHITE = 97

    KEYWORDS = {
        "ERROR": (CTRL_BASE % (concat(COLOR_RED, CODE_BOLD, CODE_BLINK))),
        "red": (CTRL_BASE % (COLOR_RED)),
        "cyan": (CTRL_BASE % (COLOR_CYAN)),
        "yellow": (CTRL_BASE % (COLOR_YELLOW)),
        "green": (CTRL_BASE % (COLOR_GREEN)),
        "blue": (CTRL_BASE % (COLOR_BLUE)),
        "lightblue": (CTRL_BASE % (COLOR_BLUE_LIGHT)),
        "boldlightblue": (CTRL_BASE % (concat(COLOR_BLUE_LIGHT, CODE_BOLD))),
        "bold": (CTRL_BASE % (CODE_BOLD)),
        "reset": (CTRL_RESET)
    }


    @classmethod
    def colorize(cls, text):
        return cls.RE_PARSER_COLOR.sub(lambda m: cls.KEYWORDS.get(m.group(1), ''), text)


    @property
    def user(self):
        return getpass.getuser()

    @property
    def host(self):
        return socket.gethostname()

    @property
    def path(self):
        rel = os.path.relpath(os.curdir, os.path.expanduser('~'))
        if rel.startswith('..'):
            return os.path.abspath(os.curdir)
        elif rel == '.':
            return '~'
        else:
            return (rel or '~')

    @property
    def time(self):
        return datetime.datetime.now().time().strftime('%H:%M:%S')

    @property
    def pyversion(self):
        info = sys.version_info
        return '%d.%d' % info[0:2]

    def __init__(self, prompt_format):
        self.__format_spec__ = prompt_format

    @property
    def __format_props__(self):
        for n in dir(self):
            if (not (n.startswith('_'))) and (n[0].lower() == n[0]):
                temp = getattr(self, n)
                if isinstance(temp, basestring):
                    yield n, temp

    def __str__(self):
        spec = self.__format_spec__
        props = dict(self.__format_props__)
        basetext = self.colorize(spec.format(**props))
        return basetext + self.CTRL_RESET


print Prompt.colorize('You are in <cyan>python.<reset>\n') + Prompt.CTRL_RESET

def status():
    print Prompt("<green>{user}<reset>@<yellow>{host} <bold><lightblue>{path}<reset>")


sys.ps1 = Prompt("<cyan>py<reset><red>{pyversion} <yellow>{time} <green>{user}<reset> > ")
sys.ps2 = '<yellow>..><reset> '

#sys.ps1 = '\001\033[96m\002py> \001\033[0m\002'
#sys.ps2 = '\001\033[96m\002..> \001\033[0m\002'


# vim: ft=python
