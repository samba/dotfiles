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
gradients = [
    '#080808', '#121212', '#1c1c1c', '#262626', '#303030', '#3a3a3a',
    '#444444', '#4e4e4e', '#585858', '#626262', '#6c6c6c', '#767676',
]

# defaults...
REGULAR_BG = "terminal"
REGULAR_FG = gradients[4]
HIGHLIGHT_FG = gradients[7]
HIGHLIGHT_BG = gradients[11]
THEME_FG = gradients[0]

global config
config = dict(
    theme='default',
    date_format="%y-%m-%d",
    time_format="%T",
    right_arrow='',
    left_arrow='',
    upload_icon='󰕒',
    download_icon='󰇚',
    memory_icon='🗋',
    window_list=True,
    window_title_inactive="%wt",
    window_title_active="%wt",
    default_leftstatus=["%uh", "%sn", "%nu", "%nd"],
    default_rightstatus=["%pt", "%pc", "%ap", "%sm", "%sl", "%T", "%D"],
    regular_bg=REGULAR_BG,
    regular_fg=REGULAR_FG,
    highlight_bg=HIGHLIGHT_BG,
    highlight_fg=HIGHLIGHT_FG,
)

global param_interpol
param_interpol = ({
        "wt": "#I:#W#F",  # removing pane_title here... it's already in the window list
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
    status_left_length=150,
    status_right_length=150,
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


global themecolor
themecolor = dict(
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
        default="colour3",
)

PAD_BEFORE = 1
PAD_AFTER = 2

def colorseq (index: int, val: str, arr: str, last: bool, pad_position=PAD_BEFORE):
    default_bg = REGULAR_BG
    theme_fg = THEME_FG
    theme_bg = themecolor.get(config.get('theme', 'default') or 'default')

    q = math.ceil(len(gradients)/(1.5)) - (1 + index)

    this_bg = gradients[max(0, q)]
    next_bg = gradients[max(0, q-1)]

    if last:
        next_bg = default_bg

    beforepad = ""
    afterpad = ""

    if pad_position & PAD_BEFORE:
        beforepad = " "
    if pad_position & PAD_AFTER:
        afterpad = " "

    if index == 0:
        # invert color scheme
        return ("#[fg={tb},bg={tc},bold]{pb}{val}{pa}".format(
                        tb=theme_fg, tc=theme_bg, val=val, pa=afterpad, pb=beforepad),
                "#[fg={tc},bg={nb},nobold]{arr}".format(
                    tc=theme_bg, nb=next_bg, arr=arr))

    else:
        return ("#[fg={tc},bg={tb},nobold]{pb}{val}{pa}".format(
                        tc=theme_bg, tb=this_bg, val=val, pa=afterpad, pb=beforepad),
                "#[fg={tc},bg={nb},nobold]{arr}".format(
                    tc=this_bg, nb=next_bg, arr=arr))


def wintab(pat: str, active: bool) -> str:
    if active:
        parts = ("#[fg=TC,bg=BG,us=TC,nobold,underscore]LARR#[fg=TF,bg=TC,bold,nounderscore]",  "#[fg=TC,bg=BG,nobold,underscore,us=BG]RARR")
    else:
        parts = ('#[fg=HB,bg=BG,nobold]', '#[nobold]')

    return fmt(parts[0] + " " + pat + " " + parts[1])


def left_status(sections: stringlist):
    arrow = config.get('right_arrow', '')
    last = len(sections) - 1
    for i, v in enumerate(sections):
        t, a = colorseq(i, v, arrow, (i == last), PAD_BEFORE)
        yield t + " " + a



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

    tc = themecolor.get(
            config.get('theme', None),
            themecolor.get('default'))


    for k, v in kwargs.items():
        ka = k.replace('_', '-')
        q = quoted(str(v))
        q = re.sub(r'\s+', ' ', q)
        q = q.replace('TC', tc)
        q = q.replace('TF', THEME_FG)
        q = q.replace('BG', config.get('regular_bg', REGULAR_BG))
        q = q.replace('FG', config.get('regular_fg', REGULAR_FG))
        q = q.replace('HF', config.get('highlight_fg', HIGHLIGHT_FG))
        q = q.replace('HB', config.get('highlight_bg', HIGHLIGHT_BG))
        q = q.replace('LARR', config.get('left_arrow', ''))
        q = q.replace('RARR', config.get('right_arrow', ''))
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

    output.update(
        window_status_format = wintab(config.get('window_title_inactive'), False),
        window_status_current_format = wintab(config.get('window_title_active'), True)
    )

    if (lstat is None) and not opts.noleft:
        lstat = config.get('default_leftstatus')

    if (rstat is None) and not opts.noright:
        rstat = config.get('default_rightstatus')


    if lstat:
        output['status_left'] = fmt(' '.join(list(left_status(lstat))))

    if rstat:
        output['status_right'] = fmt(' '.join(list(right_status(rstat))))


    print(render_output(**output))

    return 0


if __name__ == "__main__":
    exit(main(sys.argv[1:]))
