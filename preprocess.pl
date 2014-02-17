#!/usr/bin/perl

use File::Basename;

while (<>) {
	my $line = $_;
	my($host, $ir, $author, $date, $zone, $request, $URL, $protocol, $sc, $bs) = split / /, $line, 10;
	
	if ($sc == 200 && $request eq '"GET') {
		($name, $dir) = fileparse($URL);
		if ($name) {
			chomp($bs);
			#if ($timestamp ne $date) {
				#print "\n";
			#}
			print "$host		$date	$URL	$bs\n";
			$timestamp = $date;
		}
	}
}
