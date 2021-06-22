#!/usr/bin/env python
# Targeting Python 2.7 per Mac OS defaults

import argparse
import sys
import re

try:
    from ConfigParser import ConfigParser, NoOptionError
except ImportError:
    from configparser import ConfigParser, NoOptionError

from collections import OrderedDict

class MultiOrderedDict(OrderedDict):
    def __setitem__(self, key, value):
        if isinstance(value, list) and key in self:
            self[key].extend(value)
        else:
            super(MultiOrderedDict, self).__setitem__(key, value)
            # super().__setitem__(key, value) in Python 3


def flatten(*parts):
    queue = list(parts)
    result = []
    for p in queue:
        if isinstance(p, list):
            queue.extend(p)
        else:
            result.append(p)
    return result


def parse_args(args):
    parser = argparse.ArgumentParser(
        description="Package index scanner"
    )
    parser.add_argument("category", action="append", nargs="*", type=str)
    parser.add_argument("-p", "--packager", action="store")
    parser.add_argument("-c", "--config", action="store")
    parser.add_argument("-d", "--defaults", action="store_const",
                        dest="mode",
                        default="generate_packages",
                        const="list_profile_default")
    return parser.parse_args(args)



def strip_whitespace(text):
    return re.sub(r'\s+', ' ', text)


def safe_command(command, sudo=False):
    firstword = r'^([\w-]+)'
    repl = r'command -v \1 >/dev/null && %s \1' % ("sudo" if sudo else "")
    return re.sub(firstword, repl, command).strip()

def generate_install(conf, profiles, packager):

    installers = dict(conf.items("INSTALLERS"))
    variants = dict(conf.items("VARIANTS"))
    priority = dict((k, int(v)) for (k, v) in conf.items("PRIORITY"))
    postinst = dict(conf.items("POSTINSTALL"))
    packages = dict((k, conf.items(k)) for k in installers.keys())
    execorder = []

    # assign priority to each installer
    for k in installers.keys():
        execorder.append((k, priority.get(k, priority.get('default', 100))))


    for k, pkgs in packages.items():
        stash = list()
        for c, v in pkgs:
            # NB: implicit removal of unselected profiles
            if c in profiles:
                vals = re.split(r'\s+', v)
                stash.extend(vals)
        packages[k] = stash

    # each installer in priority order
    for inst, prio in sorted(execorder, key=lambda x: x[1]):

        each = False
        if conf.has_option(inst, "each_package"):
            each = conf.getboolean(inst, "each_package")

        use_sudo = False
        if conf.has_option(inst, "use_sudo"):
            use_sudo = conf.getboolean(inst, "use_sudo")


        template = str(installers.get(inst, "# none"))
        cmds = set(variants.get(inst, inst).split(' ') + [inst])
        cmds = [(template.replace("{handler}", c).strip()) for c in cmds]

        cmds = [safe_command(c, use_sudo) for c in cmds]

        pkgs = packages.get(inst, [])

        if not each:
            pkgs = [strip_whitespace(' '.join(pkgs))]


        print >> sys.stderr, ("# " + repr([ inst, use_sudo, pkgs]))

        # A command for each variant with attendant packages

        for pkgs in filter(len, pkgs):

            if not len(pkgs):
                continue

            if len(cmds) == 1:
                yield cmds[0].replace("{packages}", pkgs).strip()

            else:
                cmds = reversed(cmds)  # alternates first
                cmds = [c.replace("{packages}", pkgs).strip() for c in cmds]

                yield " ||\\\n\t".join(
                    ("{ %s ; }" % (c) for c in cmds)
                )


    # postinst scripts for each profile selected
    for p in profiles:
        for k in re.split(r'\s+', postinst.get(p, "")):
            if len(k):
                yield "bash " + k # execute



def main(args):
    args = parse_args(args)
    categories = flatten(args.category)

    try:
        conf = ConfigParser(strict=False, dict_type=MultiOrderedDict)
    except TypeError:
        conf = ConfigParser(dict_type=MultiOrderedDict)

    conf.read(args.config)


    if len(categories) == 0:
        categories = conf.items("PROFILES")
        categories = [key for (key, val) in categories if val == "true"]


    if args.mode == "generate_packages":
        commands = generate_install(conf, categories, args.packager)
        print "# This script is generated by packages.py"
        print "set -euf -o pipefail"
        print "\n".join(list(commands))
    elif args.mode == "list_profile_default":
        print "\n".join(list(categories))


if __name__ == '__main__':
    sys.exit(int(main(sys.argv[1:]) or 0))
