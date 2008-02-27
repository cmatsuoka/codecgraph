#!/bin/sh

. ./build-common.sh

dir=$TOPDIR/htdocs/
index=$dir/index.html

rm -Rf $dir/*

make -C $TOPDIR svg

cp codecgraph.png $dir
cp style.css $dir
mkdir $dir/out
cp $TOPDIR/out/*svg $dir/out/

cat <<EOF > $index
<html>
<head>
  <title>HDA codec graphing tool</title>
  <link rel=StyleSheet href="style.css" type="text/css">
</head>
<body>
<h1>HDA codec graphing tool</h1>

<img title="STAC9200 from a Dell Latitude 120L" src="codecgraph.png">

<h2>Description</h2>

<em>Codecgraph</em> is a tool to generate a graph based on the
<a href="http://alsa-project.org/">ALSA</a>
description of a <a href="http://www.intel.com/design/chipsets/hdaudio.htm">
High Definition Audio</a> codec. The generated graph depicts the HDA codec
layout and node connections, helping driver troubleshooting and maintenance.

Codecgraph's parser reads the codec description from
<tt>/proc/asound/card*/codec#0</tt> and parsed data is sent to
<a href="http://graphviz.org">Graphviz</a> for actual graph generation.

<h2>Contributing</h2>

If you have an unlisted system, send your ALSA codec description file
(<tt>/proc/asound/card0/codec#X</tt>) to cmatsuoka&#64;gmail.com or
ehabkost&#64;raisama.net along with the PCI subdevice ID obtained with
<tt>lspci -vvnn</tt> and the manufacturer/model of your computer or
motherboard.

<h2>Download</h2>

<h3>Tarball</h3>
<ul>
<li><a href="$PKG.tar.gz">$PKG.tar.gz</a>
</ul>

<h3>Git repositories</h3>
<ul>
<li>http://git.raisama.net/hda-tools.git (Eduardo's tree)
<li>http://helllabs.org/git/codecgraph.git (Claudio's tree)
<!-- <li>git://git.distro.conectiva/git/herton-hda-tools (Herton's tree) -->
</ul>


<h2>Codec database</h2>
EOF

./gentable.pl >> $index

cat <<EOF >> $index
<hr>
<em>Last updated: `date`</em>
</body>
</html>
EOF
