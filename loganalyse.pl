#!/usr/bin/perl -w

use Socket;
use File::Basename;
use 5.010;

while (<>) {
    my $line = $_;
    my($host, $ir, $author, $date, $zone, $request, $URL, $protocol, $sc, $bs) = split / /, $line, 10;
    
    if ( $bs =~ /[\d]/) {
    	$URL = substr($URL,1);
    	($name, $dir) = fileparse($URL);
    	
    	#`mkdir -p $dir`;
		#`dd if=/dev/zero of=$URL bs=1 count=$bs`;
    	say "$host ~/weblog$URL $bs";
    }
}
