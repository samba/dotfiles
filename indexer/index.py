#!/usr/bin/python

import re, os, os.path, getopt, subprocess, sys, ConfigParser

Patterns = {
	'config': '(?P<name>[a-zA-Z0-9_.]+):(?P<value>.*)'
}

	


class SearchHandler:
	searches = {}
	indir = None
	outdir = None
	def __init__(self, config):
		cp = ConfigParser.ConfigParser()
		cp.readfp(open(config['config']))
		self.searches.update(dict(cp.items('searches')))
		self.indir = config['indir']
		self.outdir = config['outdir']
	
	def go(self):
		return search(self.indir, self.outdir, self.searches)
	

def search(indir, outdir, searches):
	if not indir or not os.path.isdir(indir):
		return None
	if not outdir or not os.path.isdir(outdir):
		return None
			
	for i in searches:
		o = open('%s/%s' % (outdir, i), 'w')
		e = searches[i].strip().split(';;')
		searches[i] = e[0]
		if len(e) > 1: fl = eval(e[1])
		else: fl = 0
		p = searches[i].replace('.', '\.').replace('*', '(.*)')
		sys.stderr.write('%s = "%s" with %s\n' % (i , searches[i], fl))
		p = re.compile(p, fl)
		for subdir, dirs, files in os.walk(indir):
			for f in files:
				m = None
				s = searches[i].find('/')
				if s > -1:
					m = p.match(os.path.join(subdir, f))
				else:
					m = p.match(os.path.basename(f))

				if m:
					r = os.path.relpath('%s/%s' % (subdir, f), outdir)
					o.write('%s\n' % r)

		o.close()



def Debug(s):
	if not sys.stderr.isatty(): return True
	sys.stderr.write(s)


def LoadPatterns(p):
	for i in p:
#		Debug('# compiling: %s = %s\n' % (i, p[i]))
		p[i] = re.compile(p[i])
	return p


# main search handler
def Search(config, arguments):
	c = SearchHandler(config)
	c.go()
	return 0

def ArgumentsDictionary(opts, args):
	d = {
		'config': None,
		'indir': None,
		'outdir': None
	}
	for i in opts:
		if i[0] == '-c':
			d['config'] = i[1]
		elif i[0] == '-i':
			d['indir'] = i[1]
		elif i[0] == '-o':
			d['outdir'] = i[1]

	return (d, args)

if __name__ == '__main__':
	Patterns = LoadPatterns(Patterns)
	o = getopt.getopt(sys.argv[1:], 'c:i:o:')
	d, a = ArgumentsDictionary(*o)
	sys.exit(int(Search(d, a)))
	

