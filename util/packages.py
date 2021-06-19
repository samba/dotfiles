#!/usr/bin/env python
# Targeting Python 2.7 per Mac OS defaults

import argparse
import sys
import csv

from collections import namedtuple

# This type is passed to CommandRenderer.__init__()
Command = namedtuple("Command", ["command", "packages"])


class CommandRender(object):
    args = None
    verb = "install"
    use_sudo = False
    priority = 5
    variants = []

    @classmethod
    def getRenderer(cls, cmd):
        for p in cls.__subclasses__():
            if p.call == cmd.command:
                return p(cmd)

    def __init__(self, cmd):
        assert isinstance(cmd, Command)
        self.command = cmd
    
    @property
    def executables(self):
        vals = [self.command.command.split(" ")[0]]
        if len(self.variants):
            for k in self.variants:
                if k not in vals:
                    vals.append(k)
        return vals

    @property
    def fixed_args(self):
        return ' '.join(self.command.command.split(" ")[1:])

    @property
    def generated_commands(self):
        sudo = ""
        if self.use_sudo:
            sudo = "sudo "
        for k in self.executables:
            yield "if {condition}; then {command} {verb} {args} {packages}; fi".format(
                condition=("command -v %s >/dev/null" % (k,)),
                command=(sudo + k + self.fixed_args),
                packages=(" ".join(self.command.packages)),
                verb=(self.verb if self.verb is not None else ""),
                args=(self.args if self.args is not None else "")
            )

    def __str__(self):
        return '\n'.join(list(self.generated_commands))
    
class BrewRenderer(CommandRender):
    call = "brew"
    args = "--display-items --force"
    priority = 1

class BrewCaskRenderer(CommandRender):
    call = "brew cask"
    priority = 0


class GoRender(CommandRender):
    call = "go"
    verb = "get"
    priority = 10

    def __str__(self):
        return "\n".join([
            "if {condition}; then {command.command} {verb} {pkg}; fi".format(
                condition=("command -v %s >/dev/null" % (self.call,)),
                command=self.command,
                verb=self.verb,
                pkg=pkg
            ) for pkg in self.command.packages
        ])


class NodeRender(CommandRender):
    call = "npm"
    args = "-g"
    priority = 10


class DebianRender(CommandRender):
    use_sudo = True
    call = "apt-get"
    args = "-y"
    priority = 0


class GCloudRender(CommandRender):
    call = "gcloud"
    verb = "components install"
    priority = 8


class EasyInstallRender(CommandRender):
    call = "easy_install"
    verb = None
    priority = 7


class PIPRender(CommandRender):
    call = "pip"
    priority = 8
    variants = [ "pip3" ]


def sort_commands(commands):
    return sorted(commands, key=lambda s: s.priority)


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
    parser.add_argument("-i", "--index", action="store")
    return parser.parse_args(args)


def queryCommands(indexFile, categories, packager):
    reader = csv.reader(open(indexFile))
    #  repr(categories)
    commands = dict()
    for record in reader:
        if len(record) < 1:
            continue  # skip empty rows
        if record[0].startswith('#'):
            continue  # skip comment lines
        cmd = record[0]
        if packager is not None and (packager != cmd):
            continue
        if len(categories) > 0 and record[1] not in categories:
            continue
        
        # Command identity is the call (e.g. "brew") plus a variant (e.g. "cask")
        cmd = (cmd, record[3] if len(record) > 3 else "none")

        if cmd not in commands:
            commands[cmd] = []
        commands[cmd].append(record[2]) # map the package name

    for cmd, packages in commands.iteritems():
        command = ("%s %s" % (cmd[0], cmd[1] if cmd[1] != "none" else ""))
        command = Command(
            command=command.strip(),
            packages=packages
        )

        yield CommandRender.getRenderer(command)


def main(args):
    args = parse_args(args)
    categories = flatten(args.category)
    commands = queryCommands(args.index, categories, args.packager)

    for instance in sort_commands(commands):
        print str(instance)

if __name__ == '__main__':
    sys.exit(int(main(sys.argv[1:]) or 0))
