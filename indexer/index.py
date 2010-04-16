#!/usr/bin/python

import re, os, os.path, subprocess, sys, hashlib
import ConfigParser
from optparse import OptionParser
	
def Debug(s):
	if not sys.stderr.isatty(): return True
	sys.stderr.write(s)

# generate file tuples on a directory
def ScanFiles(path, ignore = None):
	""" Generator for matching files """
	ignore = [ os.path.abspath(i) for i in (ignore or []) ]
	for subdir, dirs, files in os.walk(path, followlinks=True):
		if os.path.abspath(subdir) in ignore: continue
		for f in files: yield (subdir, f)

def Parameters():
	parser = OptionParser()
	parser.add_option('-v', '--verbose', default=False,
			action='store_true', dest='verbose',
			help='Print lots of details')
	parser.add_option('-q', '--quiet',
			action='store_false', dest='verbose', default=False,
			help='Don\' print anything (except Python errors)')
	parser.add_option('-c', '--config', 
			action='append', dest='config', 
			metavar='CFGFILE', help='add config file for processing')
	parser.add_option('-i', '--in', 
			action='append', dest='inputdir',
			metavar='INDIR', help='add source directory for examination')
	parser.add_option('-o', '--out', 
			action='store', dest='outputdir',
			metavar='OUTDIR', help='set output directory for resulting indexes')
	parser.add_option('-s', '--section', 
			action='append', dest='section',
			metavar='SECTION', help='set a specific section for processing')
	# sorting is on by default until further notice
	parser.add_option('--no-sort', 
			action='store_false', dest='sort',
			help='Disable output sorting')
	parser.add_option('--sort', 
			action='store_true', dest='sort', default=True,
			help='Enable output sorting (default)')

	return parser.parse_args()


def SearchMain(opts, args):
	# Debug('parameters: %s, %s\n' % (opts, args))
	for c in opts.config:
		Debug('ini: %s\n' % (c))
		c = SearchConfig(c, opts = opts, args = args)
		for p in opts.inputdir:
			for d, f in ScanFiles(p, [ opts.outputdir ]):
				r = c.examine(d, f)
				if r: Debug('ex: %s\n\n' % (repr(r)))

		# Debug('\n\nOK, done scanning... rendering now...\n')
		c.apply()



class SearchCommon:
	def _getsubject(self, dir, file, subject):
		s = None
		if subject == '<basename>':
			s = file
		elif subject == '<fullpath>':
			s = os.path.join(dir, file)
		return s

	def _pattern(self, el, k, **kw):
		p = self._retrieve(el, k, default = None, **kw)
		if not p: return p	
		if p.startswith('r:'):
			p = p[2:]
		else:
			p = p.replace('.', '\\.').replace('*', '(.*)')
		fl = self._retrieve(el, 'flags', default = 0, **kw)
		return re.compile(p, fl)

	def eval(self, s):
		if s.startswith('eval:'):
			return eval(s[5:])
		else: return s

	def _call(self, s = None, input = None, **kw):
		return map(lambda i: i.strip(' \t\n\r'), 
				subprocess.Popen(s, 
					stdout = subprocess.PIPE, 
					stderr = subprocess.PIPE,
					stdin = subprocess.PIPE,
					**kw
				).communicate(input)
			)

	def _retrieve(self, sect, key, default = None, **kw):
		if not self.config: return None
		try:
			r = self.eval(self.config.get(sect, key, **kw))
		except ConfigParser.NoOptionError:
			return default
		return r

class SearchOutput(SearchCommon):
	name = None
	config = None
	opts = None
	find = None
	context = None
	type = None
	pipe = None
	output = None
	def __init__(self, el, c):
		self.name = el
		self.opts = c.options
		self.config = c.config
		self.find = (
				self._retrieve(el, 'subject', default = '<basename>'), 
				self._pattern(el, 'find')
			)
		self.type = self._retrieve(el, 'type', default = 'file')
		if self.type == 'file':
			self.context = ( open(os.path.join(c.options.outputdir, el), 'w'), os.path.abspath(c.options.outputdir)	)
		elif self.type == 'dir':
			self.context = ( None, os.path.abspath(os.path.join(c.options.outputdir, el)) )
		if not os.path.isdir(self.context[1]): 
			os.makedirs(self.context[1]) 
		self.pipe = (
			self._retrieve(el, 'pipemode', default = None, raw = True),
			self._retrieve(el, 'pipepass', default = 'stdin', raw = True),
			self._pattern(el, 'pipescan', raw = True),
			self._retrieve(el, 'pipe', default = None, raw = True)
		)
		self.output = self._retrieve(el, 'output', default = '', raw = True)

	def match(self, dir, file):
		s = self._getsubject(dir, file, self.find[0])
		m = self.find[1].match(s)
		if not m or not m.groups(): return None
		# Debug('match: %s, %s << %s\n' % (self.name, self.find[1].pattern, (dir, file, m.groupdict())))
		return { (dir, file): m }

	def shellquote(self, p):
		return p.replace('\'', '\\\'').replace(' ', '\\ ')

	def pathparse(self, k, v):
		splitext = os.path.splitext(k[1])
		relpath = os.path.relpath(os.path.join(k[0], k[1]), self.context[1])
		abspath = os.path.abspath(relpath)
		v = v.groupdict() or {}
		v.update({
			'_basename': k[1], # file
			'_pathname': k[0], # dir
			'_u_key': hashlib.md5(abspath).hexdigest(), # a unique key for the file
			'_base': splitext[0], # the basename up till its extension
			'_ext': splitext[1], # the extension
			'_relpath': relpath,
			'_abspath': abspath,
			'_q_relpath': self.shellquote(relpath),
			'_q_abspath': self.shellquote(abspath)
		})
		return v

	def _calleach(self, r, k):
		for i in k:
			s = None
			y = self._call(s = (self.pipe[3] % r[i]), cwd = self.context[1], shell = True)
			if self.pipe[2]: # pipescan
				# Debug('pipescan: %s << %s (%s,%s)\n' % (self.pipe[2].pattern, y[0], i[0], i[1]))
				s = self.pipe[2].match(y[0])
			if y[1]:
				raise Exception(i, self.name, y[1])
			r[i].update((s and s.groupdict()) or {})
			yield (i, [r[i], y])
	
	def _callall(self, r, k):
		# pm, pp, ps, p = self.pipe
		paths = [ (self.pipe[0][4:] % r[i]) for i in k ]
		if self.pipe[1] == 'stdin':
			i = '\n'.join(paths)
		# TODO: consider other means of passing "all" elements to the call	
		else: i = None
		Debug('passing to exec: %s <<\n%s\n>> %s, %s\n' % (self.pipe[3], i, self.context[1], self.name))
		return self._call(s = self.pipe[3], input = i, cwd = self.context[1], shell = True)

	def render(self, res, opts):
		res = dict([ (i, self.pathparse(i, res[i])) for i in res ])	
		k = res.keys()
		if opts.sort:
			k.sort(key = lambda i: os.path.join(*i))
		
		if self.pipe[3] and self.pipe[0].startswith('all:'):
			r = self._callall(res, k)
			if self.context[0]:
				self.context[0].write(r[0])
				return self.context[0].close()

		elif self.pipe[3] and self.pipe[0] == 'each':
			r = dict(self._calleach(res, k))
			# Debug('each: %s\n\n' % (repr(r)))
			if self.context[0]:
				for i in k:
					o = ((self.output or '') % r[i][0]) or (r[i][1][0]) # output format || pipe output # TODO verify
					o = o.replace('\\n', '\n').replace('\\r','\r').replace('\\t','\t')
					self.context[0].write('%s\n' % (o)) 
				return self.context[0].close()

		elif self.context[0] and not self.pipe[3]:
			for i in k:
				# Debug('output: %s << %s\n%s\n\n' % (self.output, i, res[i]))
				o = self.output % res[i]
				o = o.replace('\\n', '\n').replace('\\r','\r').replace('\\t','\t')
				self.context[0].write('%s\n' % (o))

			return self.context[0].close()

			
		

class SearchConfig:
	options = None
	arguments = None
	config = None
	outputs = None
	def __init__(self, file, opts = None, args = None):
		self.options = opts
		self.arguments = args
		self.config = self.loadconfig(file)

	def examine(self, dir, file):
		for i in self.outputs:
			r = self.outputs[i].match(dir, file)
			if r: 
				# Debug('updating: %s << %s\n' % (i, r))
				self.outputs[i].results.update(r)


	def apply(self):
		for i in self.outputs:
			self.outputs[i].render(self.outputs[i].results, self.options)

	def loadconfig(self, f):
		self.config = ConfigParser.ConfigParser()
		self.config.readfp(open(f, 'r'))
		s = self.config.sections()
		self.outputs = dict([ (i, SearchOutput(i, self)) for i in
			filter(lambda i: not i.startswith('handler:'), s)
		])
		for i in self.outputs:
			self.outputs[i].results = {}
		return self.config


if __name__ == '__main__':
	o, a = Parameters()	
	r = SearchMain(o, a)
	if o.verbose: Debug('\n\nresult: %s\n\n' % r)
	sys.exit(0)
	

