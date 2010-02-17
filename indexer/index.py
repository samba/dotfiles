#!/usr/bin/python

import re, os, os.path, getopt, subprocess, sys, ConfigParser

Patterns = {
	'config': '(?P<name>[a-zA-Z0-9_.]+):(?P<value>.*)'
}

	


class SearchHandler:
	searches = {}
	config = None
	options = None
	def __init__(self, options):
		self.options = options
		self.loadcfg(self.options['config'])
	
	def loadcfg(self, file):
		self.config = ConfigParser.ConfigParser()
		self.config.readfp(open(file, 'r'))
		# set up the search data structure
		for i in self.config.sections():
			# outfile name -> { options }
			self.searches.update({ i: dict(self.config.items(i)) })
		return self.config


	def go(self):
		return self.search(self.options['indir'], self.options['outdir'], self.searches)
	

	def searchpath(self, pattern, path):
		for subdir, dirs, files in os.walk(path):
			for f in files:
				match = None
				slash = pattern.pattern.find('/') 
				if slash > -1:
					match = pattern.match(os.path.join(subdir, f))
				else:
					match = pattern.match(os.path.basename(f))

				if match:
					yield '%s/%s' % (subdir, f)


	def search(self, indir, outdir, searches):
		if not indir or not os.path.isdir(indir): return None
		if not outdir or not os.path.isdir(outdir): return None
			
		# sys.stderr.write(repr(searches))

		for i in searches:
			# set up the regular expression
			p = searches[i]['pattern'].replace('.', '\.').replace('*', '(.*)')
			fl = 0
			if 'flags' in searches[i]:
				fl = eval(searches[i]['flags'])
			sys.stderr.write('%s = "%s" with %s\n' % (i, p, fl))
			p = re.compile(p, fl)

			# gather resultant paths
			results = [ os.path.relpath(r, outdir) for r in self.searchpath(p, indir) ]
			if self.options['sort']: results.sort() # sort - duh.

			# setup the buffer and write the results
			outfile = open('%s/%s' % (outdir, i), 'w')
			for f in results: outfile.write('%s\n' % f)
			outfile.close()

		return None	



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
		'outdir': None,
		'sort': False
	}
	for i in opts:
		if i[0] == '-c':
			d['config'] = i[1]
		elif i[0] == '-i':
			d['indir'] = i[1]
		elif i[0] == '-o':
			d['outdir'] = i[1]
		elif i[0] == '-s':
			d['sort'] = True

	return (d, args)

if __name__ == '__main__':
	Patterns = LoadPatterns(Patterns)
	o = getopt.getopt(sys.argv[1:], 'c:i:o:s')
	d, a = ArgumentsDictionary(*o)
	sys.exit(int(Search(d, a)))
	

