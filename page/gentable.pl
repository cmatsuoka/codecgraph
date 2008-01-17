#!/usr/bin/perl

$\ = "\n";

open FILE, "/usr/share/misc/pci.ids";
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
	$_id{$system} = $id;
	push @{$_system{$codec}}, $system;
}
close FILE;

print "Known codecs: ";
$sep = "";
foreach $codec (sort keys %_system) {
	printf "$sep<a href=\"\#$codec\">$codec</a>";
	$sep = ", ";
}

foreach $codec (sort keys %_system) {
	print "<h3><a name=\"$codec\">$codec</a></h3>";

	print "<table>";
	print " <tr><th width=\"200\">System</th><th width=\"80\">ID</th><th width=\"300\">Vendor</th></tr>";
	foreach $system (@{$_system{$codec}}) {
		(my $file = lc $system) =~ s/ /-/g;

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
