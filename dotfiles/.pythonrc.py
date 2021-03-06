# ~/.pythonrc

from __future__ import print_function

import atexit
import datetime
import getpass
import hashlib
import math
import os
import random
import re
import socket
import sys
import time
import uuid


try:
    # NOTE: on Mac OS X 10.10, readline must be installed/updated.
    # Version readline==6.2.4.1 seems to be known-good.
    # In some earlier version there seems to be a bug that breaks
    # text wrapping using the history UP/DOWN methods.
    import readline
except ImportError:
    print("Module 'readline' not available.")
    readline = None

try:
    import pprint
except:
    pass

__pyversion__ = sys.version_info[0:2]



def enable_history(path = None):
    if path is None:
        path = os.path.expanduser('~/.python-history')

    hist_length = int(os.environ.get('PYTHON_HISTLEN', 1000))

    @atexit.register
    def save_history():
        import readline
        readline.write_history_file(path)

    if readline:
        readline.set_history_length(hist_length)
        if os.path.exists(path):
            readline.read_history_file(path)



def enable_completion():
    if readline:
        # Enable syntax completion via tab
        import rlcompleter
        if 'libedit' in readline.__doc__:
            readline.parse_and_bind("bind ^I rl_complete") # for Mac OS X
        else:
            readline.parse_and_bind("tab: complete")



def concat(*props):
    return ';'.join([ str(i) for i in props ])


class Prompt(object):

    CTRL_BASE = '\001\033[%sm\002'
    CTRL_RESET = '\001\033[0m\002'

    RE_PARSER_COLOR = re.compile(r'<([a-zA-Z]+)>')
    RE_PARSER_ATTRIB = re.compile('\{([a-zA-Z\_\-]+)\}')

    TERMINALS_SUPPORTED = [ 'xterm', 'xterm-color',
                            'xterm-256color', 'linux',
                            'screen', 'screen-256color', 'screen-bce' ]


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
    def interactive(cls):
        return globals().get('RUN_INTERACTIVE', -1)

    @classmethod
    def _print(cls, text):
            print(str(cls(text)) + cls.CTRL_RESET)

    @classmethod
    def term_supported(cls):
        return os.environ.get('TERM') in cls.TERMINALS_SUPPORTED


    @classmethod
    def colorize(cls, text):
        resolver = lambda m: cls.KEYWORDS.get(m.group(1), '')
        if not cls.term_supported():
            resolver = lambda m: ''
        return cls.RE_PARSER_COLOR.sub(resolver, text)


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
    def pathbase(self):
        return os.path.basename(self.path)


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
                if isinstance(temp, str):
                    yield n, temp

    def __str__(self):
        spec = self.__format_spec__
        props = dict(self.__format_props__)
        basetext = self.colorize(spec.format(**props))
        return basetext



def status():
    Prompt._print("<green>{user}<reset>@<yellow>{host} <bold><lightblue>{path}<reset>\n")

if __pyversion__ < (3, 4):
    # Evidently Python 3.4 enables tab completion and history automatically.
    # https://docs.python.org/3/whatsnew/3.4.html#other-improvements
    enable_history()
    enable_completion()


if Prompt.interactive() == -1:
    Prompt._print('You are in <cyan>python <red>{pyversion}<reset>\n')




sys.ps1 = Prompt("<cyan>py<reset><red>{pyversion} <cyan>{time} <lightblue>{pathbase}<reset>> ")
sys.ps2 = Prompt('<yellow>..<reset>> ')

#sys.ps1 = '\001\033[96m\002py> \001\033[0m\002'
#sys.ps2 = '\001\033[96m\002..> \001\033[0m\002'


# vim: ft=python
