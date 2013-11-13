# ~/.pythonrc

# enable syntax completion via tab
try:
    import readline, sys
except ImportError:
    print "Module readline not available."
else:
    import rlcompleter
    readline.parse_and_bind("tab: complete")
    readline.parse_and_bind("bind ^I rl_complete") # for Mac OS X

print 'You are in python.\n'

sys.ps1 = 'py> '
sys.ps2 = '..> '

# vim: ft=python
