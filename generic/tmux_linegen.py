#!/usr/bin/env python3

# Goal: replicate stylistically the `tmux-power` status line,
# but with statically encoded output for tmux to apply direction.
#
# Expected usage:  with input format, generate output config to be appended to
# user's tmux.conf

import sys
import re
import optparse
import math

from typing import List

cmdpat = re.compile(r'#\(([\w_]*)\)')
alias = re.compile(r'%([a-zA-Z]{1,3})')


type stringlist = list[string]

global parser
parser = optparse.OptionParser()
parser.add_option("-l", "--left", dest="leftstatus", action="append")
parser.add_option("-r", "--right", dest="rightstatus", action="append")
parser.add_option("--no-left", dest="noleft", default=False, action="store_true")
parser.add_option("--no-right", dest="noright", default=False, action="store_true")
parser.add_option("-w", "--win", dest="wintitle", action="store")
parser.add_option("-t", "--theme", dest="theme", default="default", action="store")

global gradients
# gradients = [
#    '#080808', '#121212', '#1c1c1c', '#262626', '#303030', '#3a3a3a',
#    '#444444', '#4e4e4e', '#585858', '#626262', '#6c6c6c', '#767676',
#]
gradients = [
    'colour236', 'colour237', 'colour238', 'colour239', 'colour240', 'colour241',
    'colour246', 'colour247', 'colour248', 'colour251', 'colour253', 'colour255',
]


# defaults...
REGULAR_BG = "terminal"
REGULAR_FG = gradients[4]
HIGHLIGHT_FG = gradients[7]
HIGHLIGHT_BG = gradients[11]
THEME_FG = gradients[0]

LEFT_TRIANGLE="◢"
RIGHT_TRIANGLE="◣"
LEFT_ANGLE_STEEP=""
RIGHT_ANGLE_STEEP=""
RIGHT_ARROW="▶"
LEFT_ARROW="◀"

LEFT_QUOTE_ANGLE="❮"
RIGHT_QUOTE_ANGLE="❯"



global config
config = dict(
    theme='default',
    date_format="%y-%m-%d",
    time_format="%T",
    right_arrow=RIGHT_QUOTE_ANGLE,
    left_arrow=LEFT_QUOTE_ANGLE,
    upload_icon='󰕒',
    download_icon='󰇚',
    memory_icon='🗋',
    window_list=True,
    window_title_inactive="%wn",
    window_title_active="%wn",
    default_leftstatus=["%uh", "%sn", "%pc", "%pt" ],
    default_rightstatus=[ "%ap",  "%nu", "%nd", "%sl", "%sm", "%T", "%D"],
    regular_bg=REGULAR_BG,
    regular_fg=REGULAR_FG,
    highlight_bg=HIGHLIGHT_BG,
    highlight_fg=HIGHLIGHT_FG,
)

global param_interpol
param_interpol = ({
        "wt": "#I:#W#F",  # removing pane_title here... it's already in the window list
        "wn": "#I#F",
        "pt": "#{pane_title}", # pane title
        "pc": "#{p8:#{=8:pane_current_command}}",
        "pp": "#{pane_current_path}",
        "ap": "#{s|([A-Za-z])[^/]*/|\\1/|:#{s|${HOME}|~|:pane_current_path}}",
        "uh": "#{client_user}@#h",  # Username @ Hostname
        "sn": "#S",  # session number
        "nu": "#(upload_icon) #(net_upload)",
        "nd": "#(download_icon) #(net_download)",
        "sl": "#(system_load)",
        "sm": "#(memory_icon) #(system_memory)",
        "D": "#(date_format)",
        "T": "#(time_format)",
        "r": "#(right_arrow)",
        "l": "#(left_arrow)",

})

global cmd_interpol
cmd_interpol = ({
    "system_load": "#(cat /proc/loadavg | cut -f 1-3 -d ' ')",
    "system_memory": "#(free -m | grep Mem | awk '{ printf(\"%.0f%%\", (100*\\$7/\\$2)) }')",
    "net_upload": "#{upload_speed}",
    "net_download": "#{download_speed}",
})


global output
output = dict(
    status="on",
    status_interval="1",
    status_left="",
    status_right="",
    status_style="bg=terminal,fg=terminal",
    status_left_length=60,
    status_right_length=60,
    status_attr="none",
    status_justify="centre",
    window_status_separator="",
    window_status_format=None,
    window_status_current_format=None,
    window_status_current_status="fg=TC,bg=BG",
    pane_border_style="fg=HF,bg=default",
    pane_active_border_style="fg=TC,bg=BG",
    display_panes_color="HF",
    display_panes_active_color="TC",
    clock_mode_colour="TC",
    clock_mode_style=24,
    message_style="fg=TC,bg=BG",
    message_command_style="fg=TC,bg=BG",
    mode_style="bg=TC,fg=FG",
)

global outvars
outvars = dict(
    themecolorbg="TC",  # default
    themecolorfg="TF",  # default
    themecolorhbg="HB", # default
    themecolorhfg="HF", # default
    themecolorrbg="BG", # default
    themecolorrfg="terminal", # default
    themelarr="LARR", # default
    themerarr="RARR", # default
    themeheadtxt="nobold"
)


global colorvarmap
colorvarmap = dict(
    TC="themecolorbg",
    TF="themecolorfg",
    BG="themecolorrbg",
    FG="themecolorrfg",
    HF="themecolorhfg",
    HB="themecolorhbg",
    TH="themeheadtxt",
    LARR="themelarr",
    RARR="themerarr"
)


# BUG/XXX: MacOS doesn't like hex colours.
# TODO convert these to number aliases. https://superuser.com/questions/285381/how-does-the-tmux-color-palette-work
global themecolor
themecolor = dict(
        amber="#FFBF00",
        gold="#ffb86c",
        redwine="#b34a47",
        moon="#00abab",
        forest="#228b22",
        violet="#9370db",
        snow="#fffafa",
        coral="#ff7f50",
        sky="#87ceeb",
        orange="color172",
        magenta="magenta",
        dullgreen="color64",
        darkgreen="color22",
        burntorange="colour166",
        default="colour3",
)

PAD_BEFORE = 1
PAD_AFTER = 2


TERM_WIDTH_MIN=120
TERM_CELL_WIDTH=10

def colorseq (index: int, val: str, arr: str, last: bool, pad_position=PAD_BEFORE):
    default_bg = REGULAR_BG
    theme_fg = THEME_FG
    theme_bg = themecolor.get(config.get('theme', 'default') or 'default')

    q = math.floor(len(gradients)/(2)) - (index)

    this_bg = gradients[max(0, q)]
    next_bg = gradients[max(0, q-1)]

    if last:
        next_bg = default_bg

    minwidth = TERM_WIDTH_MIN - ((index + 1) * TERM_CELL_WIDTH)

    beforepad = ""
    afterpad = ""

    if pad_position & PAD_BEFORE:
        beforepad = " "
    if pad_position & PAD_AFTER:
        afterpad = " "


    #fmt_primary = "#[fg=%(tb)s,bg=%(tc)s,bold]#{?#{e|<:#{client_width},%(mw)d},,%(pb)s%(val)s%(pa)s}"
    fmt_primary = "#[fg=TF,bg=TC,bold]%(pb)s%(val)s%(pa)s"
    #fmt_secondary = "#[fg=%(tc)s,bg=%(tb)s,nobold]#{?#{e|<:#{client_width},%(mw)d},,%(pb)s%(val)s%(pa)s}"
    fmt_secondary = "#[fg=TC,bg=%(tb)s,TH]%(pb)s%(val)s%(pa)s"

    if index == 0:
        # invert color scheme
        return (fmt_primary % dict(
                    val=val,
                    pa=afterpad,
                    pb=beforepad,
                    mw=minwidth),
                "#[fg=TC,bg={nb},nobold]{arr}".format(
                    tc=theme_bg, nb=next_bg, arr=arr))

    else:
        return (fmt_secondary % dict(
                    tb=this_bg,
                    val=val,
                    pa=afterpad,
                    pb=beforepad,
                    mw=minwidth),
                "#[fg={tc},bg={nb},nobold]{arr}".format(
                    tc=this_bg, nb=next_bg, arr=arr))


def wintab(pat: str, active: bool) -> str:
    if active:
        parts = ("#[fg=TC,bg=BG,us=TC,nobold]LARR#[fg=TF,bg=TC,bold,nounderscore]",  "#[fg=TC,bg=BG,nobold,us=BG]RARR")
    else:
        parts = ('#[fg=HB,bg=BG,TH]', '#[nobold]')

    return parts[0] + " " + fmt(pat) + " " + parts[1]


def left_status(sections: stringlist):
    arrow = config.get('right_arrow', '')
    last = len(sections) - 1
    for i, v in enumerate(sections):
        t, a = colorseq(i, v, arrow, (i == last), PAD_BEFORE)
        yield t + " " + a
    # and finally
    yield "#[default]"

def right_status(sections: stringlist):
    arrow = config.get('left_arrow', '')
    last = len(sections) - 1
    for i, v in reversed(list(enumerate(reversed(sections)))):
        t, a = colorseq(i, v, arrow, (i == last), (PAD_AFTER | PAD_BEFORE))
        yield a + t + " "
    # and finally
    yield "#[default]"


def inject(m: re.Match) -> str :
    """ Interpolate configuration and command injections """
    return cmd_interpol.get(m[1], config.get(m[1], m[0]))

def fmt(statusline: str) -> str :
    """ Render format parameters """
    s = alias.sub(r'{\1}', statusline)
    ##  print(repr(s))
    s = s.format(**param_interpol).replace("\\", "\\\\")
    return cmdpat.sub(inject, s)


def quoted(val: str) -> str:
    if val in ('on', 'off', 'none'):
        return val
    if re.match(r'^[0-9]+$', val):
        return val
    return '"' + val.replace('"', '\\"') + '"'

def render_output(**kwargs) -> str :
    result = [ "# BEGIN generated status line",
               "# this config is generated by tmux_linegen.py" ]

    for k, v in outvars.items():
        result.append("%s=\"%s\"" % (k, v))


    for k, v in kwargs.items():
        ka = k.replace('_', '-')
        ov = outvars.get(colorvarmap.get(v, None), None)
        q = quoted(str(ov or v))
        q = re.sub(r'\s+', ' ', q)
        q = q.replace('TC', "#{themecolorbg}")
        q = q.replace('TF', "#{themecolorfg}")
        q = q.replace('BG', "#{themecolorrbg}")
        q = q.replace('FG', "#{themecolorrfg}")
        q = q.replace('HF', "#{themecolorhfg}")
        q = q.replace('HB', "#{themecolorhbg}")
        q = q.replace('TH', "#{themeheadtxt}")
        q = q.replace('LARR', "#{themelarr}")
        q = q.replace('RARR', "#{themerarr}")
        result.append("set -gq {ka} {qv}".format(ka=ka, qv=q))

    result.append('# END generated status line')
    return '\n'.join(result)

def main (args) -> int :
    opts, args = parser.parse_args(args)
    # print(fmt("%uh | %l | %D | %T | %r %nu %nd %sl %sm"))

    lstat = opts.leftstatus
    rstat = opts.rightstatus

    config.update(
        theme = (opts.theme or 'default')
    )

    if (lstat is None) and not opts.noleft:
        lstat = config.get('default_leftstatus')

    if (rstat is None) and not opts.noright:
        rstat = config.get('default_rightstatus')

    output.update(
        window_status_format = wintab(config.get('window_title_inactive'), False),
        window_status_current_format = wintab(config.get('window_title_active'), True),
        status_left_length = (15 * len(lstat)),
        status_right_length = (15 * len(rstat))
    )


    tc = (themecolor.get(
            config.get('theme', None),
            config.get('theme') or 'default') or 'terminal')

    outvars.update(
        themecolorbg = tc,
        themecolorfg = THEME_FG,
        themecolorrbg = config.get('regular_bg', REGULAR_BG),
        themecolorrfg = config.get('regular_fg', REGULAR_FG),
        themecolorhfg = config.get('highlight_fg', HIGHLIGHT_FG),
        themecolorhbg = config.get('highlight_bg', HIGHLIGHT_BG),
        themelarr = (config.get('left_arrow', '')),
        themerarr = (config.get('right_arrow', ''))
    )


    if lstat:
        output['status_left'] = (' '.join(list(left_status([ fmt(l) for l in lstat ]))))

    if rstat:
        output['status_right'] = (' '.join(list(right_status([ fmt(r) for r in rstat ]))))


    print(render_output(**output))

    return 0


if __name__ == "__main__":
    exit(main(sys.argv[1:]))
