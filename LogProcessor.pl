use strict;
use warnings;

my $logfile         = "Largelog";
my $linefile        = "line.txt";
my $linecounter     = 1;
my $prevlinecounter = 1;
my $maxlines        = 10000;
my $windowsize      = 1000;
my $support         = 0.1;
my $start           = time;
my $difference      = 0;


#delete old information
system("perl RemoveOld.pl");

open( INPUTFILE,  '<', $logfile )  or die "Could not open $logfile\n";
open( OUTPUTFILE, '>', $linefile ) or die "Could not open $linefile\n";
while ( my $logline = <INPUTFILE> ) {
	if ( $linecounter % $maxlines == 0 || eof ) {
		close OUTPUTFILE;
		print "Processing lines from : $prevlinecounter to $linecounter \n";
		system("perl SessionMS.pl $linefile $windowsize $support");
		print "\n";
		$prevlinecounter = $linecounter + 1;
		open( OUTPUTFILE, '>', $linefile ) or die "Could not open $linefile\n";
	}
	$linecounter++;
	print OUTPUTFILE $logline;
}

close INPUTFILE;
close OUTPUTFILE;
$difference = -( $start - time );
print "Time taken for complete process is $difference\n";
print "Log Processor Completed\n";
