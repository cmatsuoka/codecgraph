#!/usr/bin/perl

$\ = "\n";

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
	print " <tr><th>System</th><th>Subsystem ID</th></tr>";
	foreach $system (@{$_system{$codec}}) {
		(my $file = lc $system) =~ s/ /-/g;

		print "<tr>";
		print " <td><a href=\"out/$file.svg\">$system</a></td>";
		print " <td>$_id{$system}</td>";
		print "</tr>";
	}
	print "</table>";
}
