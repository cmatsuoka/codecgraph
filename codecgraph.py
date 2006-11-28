
import re, sys

ALL_NODES = False

def indentlevel(line):
	"""Return the indent level of a line"""
	m = re_indent.match(line)
	if not m:
		return 0
	return len(m.group(0))

def parse_item(level, lines):
	"""Read a line and corresponding indented lines"""
	item = lines.pop(0).rstrip('\r\n').lstrip(' ')
	subitems = list(parse_items(level, lines))
	return item,subitems

def parse_items(level, lines):
	"""Parse a list of indented lines"""
	while lines:
		l = lines[0]
		linelvl = indentlevel(l)
		if linelvl <= level:
			# end of list
			break
		yield parse_item(linelvl, lines)

class Node:
	node_info_re = re.compile('^Node (0x[0-9a-f]*) \[(.*?)\] wcaps 0x[0-9a-f]*?: (.*)$')
	final_hex_re = re.compile(' *(0x[0-9a-f]*)$')

	def __init__(self, codec, item, subitems):
		self.item = item
		self.subitems = subitems
		self.codec = codec

		fields = {}

		# split first line and get some fields
		data = item.split(' ')
		m = self.node_info_re.match(item)
		self.nid = int(m.group(1), 16)
		self.type = m.group(2)
		wcapstr = m.group(3)

		self.wcaps = wcapstr.split()

		for item,subitems in self.subitems:
			# Parse node fields
			if ': ' in item:
				f,v = item.split(': ', 1)

				# strip hex number at the end.
				# some fields, such as Pincap & Pin Default,
				# have an hex number in the end
				m = self.final_hex_re.search(f)
				if m:
					f = self.final_hex_re.sub('', f)

					# store the hex value and the
					# string, on different keys
					fields[f+'-hex'] = m.group(1),subitems
					fields[f] = v,subitems
				else:
					fields[f] = v,subitems
			else:
				sys.stderr("Unknown node item: %s" % (item))

		self.fields = fields

		conn = fields.get('Connection', ('0', []))

		number,items = conn
		self.num_inputs = int(number)
		conns = []
		self.active_conn = None
		for i,sub in items:
			for j in i.split():
				active = j.endswith('*')
				j = j.rstrip('*')
				nid = int(j, 16)
				conns.append(nid)
				if active:
					self.active_conn = nid
		assert len(conns) == self.num_inputs
		self.inputs = conns

		if not self.active_conn and self.num_inputs == 1:
			self.active_conn = self.inputs[0]

		self.outputs = []

	def new_output(self, nid):
		self.outputs.append(nid)

	def input_nodes(self):
		for c in self.inputs:
			yield self.codec.nodes[c]

	def is_divided(self):
		if self.type == 'Pin Complex':
			return True
		
		return False

	def idstring(self):
		return 'nid-%02x' % (self.nid)

	def has_outamp(self):
		return 'Amp-Out' in self.wcaps

	def outamp_id(self):
		return '"%s-ampout"' % (self.idstring())

	def out_id(self):
		if self.is_divided():
			return self.main_output_id()

		if self.has_outamp():
			return self.outamp_id()

		return self.outamp_next_id()

	def has_inamp(self):
		return 'Amp-In' in self.wcaps

	def inamp_id(self):
		return '"%s-ampin"' % (self.idstring())

	def in_id(self):

		if self.is_divided():
			return self.main_input_id()

		if self.has_inamp():
			return self.inamp_id()

		return self.inamp_next_id()

	def main_id(self):
		assert not self.is_divided()
		return '"%s"' % (self.idstring())

	def main_input_id(self):
		assert self.is_divided()
		return '"%s-in"' % (self.idstring())

	def main_output_id(self):
		assert self.is_divided()
		return '"%s-out"' % (self.idstring())

	def inamp_next_id(self):
		"""ID of the node where the In-Amp would be connected"""
		if self.is_divided():
			return self.main_output_id()

		return self.main_id()

	def outamp_next_id(self):
		"""ID of the node where the Out-Amp would be connected"""
		if self.is_divided():
			return self.main_input_id()

		return self.main_id()

	def label(self):
		r = '0x%02x' % (self.nid)
		print '// %r' % (self.fields)
		pdef = self.fields.get('Pin Default')
		if pdef:
			pdef,subdirs = pdef
			r += '\\n%s' % (pdef)

		r = '"%s"' % (r)
		return r

	def show_input(self):
		return ALL_NODES or len(self.inputs) > 0

	def show_output(self):
		return ALL_NODES or len(self.outputs) > 0

	def additional_attrs(self):
		default_attrs = [ ('shape', 'box'), ('color', 'black') ]
		shape_dict = {
			'Audio Input':[ ('color', 'red'),
			                ('shape', 'ellipse') ],
			'Audio Output':[ ('color', 'blue'),
			                 ('shape', 'ellipse') ],
			'Pin Complex':[ ('color', 'green'),
			                ('shape', 'box') ],
			'Audio Selector':[ ('shape', 'parallelogram'),
			                   ('orientation', '0')  ],
			'Audio Mixer':[ ('shape', 'hexagon') ],
		}
		return shape_dict.get(self.type, default_attrs)

	def new_node(self, f, id, attrs):
		f.write(' %s ' % (id))
		if attrs:
			attrstr = ', '.join('%s=%s' % (f,v) for f,v in attrs)
			f.write('[%s]' % (attrstr))
		f.write('\n')

	def dump_main(self, f):
		attrs = [ ('label', self.label()) ]
		attrs.extend(self.additional_attrs())

		if not self.is_divided():
			if self.show_input() or self.show_output():
				self.new_node(f, self.main_id(), attrs)
		else:
			if self.show_input():
				self.new_node(f, self.main_input_id(), attrs)
			if self.show_output():
				self.new_node(f, self.main_output_id(), attrs)

	def dump_amps(self, f):
		def show_amp(id, type, frm, to):
			f.write('  %s [label = "", shape=triangle orientation=-90];\n' % (id))
			f.write('  %s -> %s [arrowsize=0.5, arrowtail=dot, weight=2.0];\n' % (frm, to))

		if self.show_output() and self.has_outamp():
			show_amp(self.outamp_id(), "Out", self.outamp_next_id(), self.outamp_id())
		if self.show_input() and self.has_inamp():
			show_amp(self.inamp_id(), "In", self.inamp_id(), self.inamp_next_id())


	def is_conn_active(self, c):
		if self.type == 'Audio Mixer':
			return True
		if c == self.active_conn:
			return True
		return False

	def dump_graph(self, f):
		codec = self.codec
		if self.is_divided(): name = self.idstring()
		else: name = "cluster-%s" % (self.idstring())
		f.write('subgraph "%s" {\n' % (name))
		f.write('  pencolor="gray80"\n')
		self.dump_main(f)
		self.dump_amps(f)
		f.write('}\n')

		for origin in self.input_nodes():
			if self.is_conn_active(origin.nid):
				attrs="[color=gray20]"
			else:
				attrs="[color=gray style=dashed]"
			f.write('%s -> %s %s;\n' % (origin.out_id(), self.in_id(), attrs))
		

re_indent = re.compile("^ *")

class CodecInfo:
	def __init__(self, f):
		self.fields = {}
		self.nodes = {}
		lines = f.readlines()
		total_lines = len(lines)

		for item,subitems in parse_items(-1, lines):
			if item.startswith('Node '):
				n = Node(self, item, subitems)
				self.nodes[n.nid] = n
			elif ': ' in item:
				f,v = item.split(': ', 1)
				self.fields[f] = v
			else:
				line = total_lines-len(lines)
				sys.stderr.write("%d: Unknown item: %s\n" % (line, item))

		self.create_out_lists()

	def create_out_lists(self):
		for n in self.nodes.values():
			for i in n.input_nodes():
				i.new_output(n.nid)

	def dump(self):
		print "Codec: %s" % (self.fields['Codec'])
		print "Nodes: %d" % (len(self.nodes))
		for n in self.nodes.values():
			print "Node: 0x%02x" % (n.nid),
			print " %d conns" % (n.num_inputs)

	def dump_graph(self, f):
		f.write('digraph {\n')
		f.write("""rankdir=LR
		ranksep=1.0
		""")
		for n in self.nodes.values():
			n.dump_graph(f)
		f.write('}\n')

def main(argv):
	f = open(argv[1], 'r')
	ci = CodecInfo(f)
	ci.dump_graph(sys.stdout)

if __name__ == '__main__':
	main(sys.argv)
