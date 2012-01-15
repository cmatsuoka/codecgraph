#!/usr/bin/perl

$\ = "\n";
@idfiles = ("/usr/share/misc/pci.ids", "/usr/share/hwdata/pci.ids");

foreach (@idfiles) {
	$idfile = $_ if (-f $_);
}


open FILE, $idfile;
while (<FILE>) {
	s!#.*!!;
	s!\s*$!!;
	m!^\s*$! && next;
	if (m!^(\w\w\w\w)\s+(.*)!) {
		$vendor{$1} = $2;
	}
}
close FILE;

open FILE, "../codecs.txt";
while (<FILE>) {
	chomp();
	my ($system, $id, $codec) = split /\t+/;
	if ($codec =~ m!^Analog Devices!) {
		($codec_vendor, $codec_model) = $codec =~ m!(\S*\s\S*)\s(.*)!;
	} else {
		($codec_vendor, $codec_model) = $codec =~ m!(\S*)\s(.*)!;
	}

	unless ($mark{$codec}) {
		push @{$_codec_model{$codec_vendor}}, $codec_model;
		$mark{$codec} = 1;
	}
	$_id{$system} = $id;
	push @{$_system{$codec}}, $system;
}
close FILE;

print "Known codecs: ";
print "<ul>";
foreach $vendor (sort keys %_codec_model) {
	print "<li>$vendor: ";
	$sep = "";
	foreach $model (sort @{$_codec_model{$vendor}}) {
		printf "$sep<a href=\"\#$vendor $model\">$model</a>";
		$sep = ", ";
	}
}
print "\n</ul>\n";

foreach $codec (sort keys %_system) {
	print "<h3><a name=\"$codec\">$codec</a></h3>";

	print "<table>";
	print " <tr><th width=\"250\">System</th><th width=\"80\">ID</th><th width=\"300\">Vendor</th></tr>";
	foreach $system (@{$_system{$codec}}) {
		(my $file = lc $system) =~ y/ [\.\(\)]/-_/;

		print "<tr>";
		print " <td><a href=\"out/$file.svg\">$system</a></td>";
		print " <td>$_id{$system}</td>";
		if ($_id{$system} eq '?') {
			print " <td>?</td>";
		} else {
			my ($v, $d) = $_id{$system} =~ m!(.*):(.*)!;
			print " <td>$vendor{$v}</td>";
		}
		print "</tr>";
	}
	print "</table>";
}
