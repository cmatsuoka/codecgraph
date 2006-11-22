
import re, sys

ALL_NODES = True

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
		return '"0x%02x [%s]"' % (self.nid, self.type)

	def main_color(self):
		typecolors = {
			'Audio Output':'blue',
			'Audio Input':'red',
			'Pin Complex':'green'
		}
		return typecolors.get(self.type, 'black')

	def show_input(self):
		return ALL_NODES or len(self.inputs) > 0

	def show_output(self):
		return ALL_NODES or len(self.outputs) > 0

	def dump_main(self, f):
		if not self.is_divided():
			if self.show_input() or self.show_output():
				f.write('  %s [label = %s, color=%s, shape=box];\n' %
						(self.main_id(),
						 self.label(),
						 self.main_color()))
		else:
			if self.show_input():
				f.write('  %s [label = %s, color=%s, shape=box];\n' %
						(self.main_input_id(),
						 self.label(),
						 self.main_color()))
			if self.show_output():
				f.write('  %s [label = %s, color=%s, shape=box];\n' %
						(self.main_output_id(),
						 self.label(),
						 self.main_color()))

	def dump_amps(self, f):
		def show_amp(id, type):
			f.write('  %s [label = "%s-A", shape=diamond];\n' % (id, type))

		if self.show_output() and self.has_outamp():
			show_amp(self.outamp_id(), "Out")
			f.write('  %s -> %s [arrowsize=0.5, weight=2.0];\n' % (self.outamp_next_id(), self.outamp_id()))
		if self.show_input() and self.has_inamp():
			show_amp(self.inamp_id(), "In")
			f.write('  %s -> %s [arrowsize=0.5, weight=2.0];\n' % (self.inamp_id(), self.inamp_next_id()))


	def is_conn_active(self, c):
		if self.type == 'Audio Mixer':
			return True
		if c == self.active_conn:
			return True
		return False

	def dump_graph(self, f):
		codec = self.codec
		f.write('subgraph "%s" {\n' % (self.idstring()))
		self.dump_main(f)
		self.dump_amps(f)
		f.write('}\n')

		for origin in self.input_nodes():
			if self.is_conn_active(origin.nid):
				attrs="[color=black]"
			else:
				attrs="[color=gray]"
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
		for n in self.nodes.values():
			n.dump_graph(f)
		f.write('}\n')

def main(argv):
	f = open(argv[1], 'r')
	ci = CodecInfo(f)
	ci.dump_graph(sys.stdout)

if __name__ == '__main__':
	main(sys.argv)
