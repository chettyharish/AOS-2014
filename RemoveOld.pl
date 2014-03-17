#Remove old files before starting
use strict;
use warnings;

my $i        = 0;
my $filename = "";

if ( -e "data.csv" ) {
	`del data.csv`;
}

if ( -e "temp.txt" ) {
	`del temp.txt`;
}

if ( -e "output.txt" ) {
	`del output.txt`;
}

if ( -e "info.txt" ) {
	`del info.txt`;
}

if ( -e "line.txt" ) {
	`del line.txt`;
}

if ( -e "hashtable" ) {
	`del hashtable`;
}

if ( -e "reversehashtable" ) {
	`del reversehashtable`;
}

for ( $i = 1 ; $i <= 10 ; $i++ ) {
	$filename = "hashlevel" . $i;
	if ( -e "$filename" ) {
		`del $filename`;
	}
}
