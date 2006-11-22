
import re, sys

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
	def __init__(self, item, subitems):
		self.item = item
		self.subitems = subitems
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
		self.num_connections = int(number)
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
		assert len(conns) == self.num_connections
		self.connections = conns

		if not self.active_conn and self.num_connections == 1:
			self.active_conn = self.connections[0]


	def idstring(self):
		return 'nid-%02x' % (self.nid)

	def out_id(self):
		return self.main_id()

	def in_id(self):
		return self.main_id()

	def main_id(self):
		return '"%s"' % (self.idstring())

	def label(self):
		return '"0x%02x [%s]"' % (self.nid, self.type)

	def dump_graph(self, codec, f):
		typecolors = {
			'Audio Output':'blue',
			'Audio Input':'red',
			'Pin Complex':'green'
		}
		color = typecolors.get(self.type, 'black')

		f.write('subgraph "%s" {\n' % (self.idstring()))
		f.write('  %s [label = %s, color=%s];\n' %
				(self.main_id(), self.label(), color))
		f.write('}\n')

		for c in self.connections:
			origin = codec.nodes[c]
			if c == self.active_conn:
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
				n = Node(item, subitems)
				self.nodes[n.nid] = n
			elif ': ' in item:
				f,v = item.split(': ', 1)
				self.fields[f] = v
			else:
				line = total_lines-len(lines)
				sys.stderr.write("%d: Unknown item: %s\n" % (line, item))

	def dump(self):
		print "Codec: %s" % (self.fields['Codec'])
		print "Nodes: %d" % (len(self.nodes))
		for n in self.nodes.values():
			print "Node: 0x%02x" % (n.nid),
			print " %d conns" % (n.num_connections)

	def dump_graph(self, f):
		f.write('digraph {\n')
		for n in self.nodes.values():
			n.dump_graph(self, f)
		f.write('}\n')

def main(argv):
	f = open(argv[1], 'r')
	ci = CodecInfo(f)
	ci.dump_graph(sys.stdout)

if __name__ == '__main__':
	main(sys.argv)
