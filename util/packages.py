#!/usr/bin/env python
# Targeting Python 2.7 per Mac OS defaults

import argparse
import sys
import csv

from collections import namedtuple

Command = namedtuple("Command", ["command", "packages", "variant"])


class CommandRender(object):
    args = None
    verb = "install"
    priority = 5
    variant = None

    @classmethod
    def getRenderer(cls, cmd):
        for p in cls.__subclasses__():
            if p.matchPackageSelector(cmd):
                return p(cmd)
        # else
        raise TypeError("Unmatched package spec: %r", cmd)

    @classmethod
    def matchPackageSelector(cls, cmd):
        return (cmd.command == cls.call) and (cmd.variant == cls.variant)

    def __init__(self, cmd):
        assert isinstance(cmd, Command)
        self.command = cmd

    @property
    def executable(self):
        return self.command.command.split(" ")[0]

    def __str__(self):
        return "{condition} && {command} {verb} {args} {packages}".format(
            condition=("which %s >/dev/null" % (self.executable,)),
            command=(self.command.command),
            packages=(" ".join(self.command.packages)),
            verb=(self.verb if self.verb is not None else ""),
            args=(self.args if self.args is not None else "")
        )

class BrewRenderer(CommandRender):
    call = "brew"
    args = "--display-times --force"
    priority = 1

class BrewCaskRenderer(CommandRender):  # Must be derived directly for __subclasses__ to work above.
    call = "brew"
    variant = "cask"
    args = "--cask --force"
    priority = 0  # some of the other formulae of Brew depend on Cask-installed components, particularly Java


class GoRender(CommandRender):
    call = "go"
    verb = "get"
    priority = 10

    def __str__(self):
        return "\n".join([
            "{condition} && {command.command} {verb} {pkg}".format(
                condition=("which %s >/dev/null" % (self.executable,)),
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
    commands = dict()

    for record in reader:
        if len(record) < 1:
            continue  # skip empty rows
        if record[0].startswith('#'):
            continue  # skip comment lines

        cmd = record[0]  # command name

        # Filter out items not related to this packager
        if packager is not None and (packager != cmd):
            continue

        # Filter out items that don't match these categories
        if len(categories) > 0 and record[1] not in categories:
            continue

        # Command is tuple[package-manager, variant]
        cmd = (cmd, record[3] if len(record) > 3 else "none")

        if cmd not in commands:
            commands[cmd] = []  # a list of packages for this Command tuple to queue

        commands[cmd].append(record[2])  # add the package for this Command tuple

    # For all package lists for all relevant package managers
    for cmd, packages in commands.iteritems():
        # command = ("%s %s" % (cmd[0], "" if cmd[1] == "none" else cmd[1]))
        command = Command(
            command=cmd[0],
            packages=packages,
            variant=(None if cmd[1] == "none" else cmd[1])
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
