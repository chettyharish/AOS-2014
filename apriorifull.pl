use warnings;
use strict;

my @inputarray = ();
my ( $i, $j, $k, $l, $p ) = 0;
my $flag        = 1;   #for testing wheter all subparts matched
my %counts      = ();  #hash table storing the elements and their distinct count
my @tempiparray = ();  # Level 1 temp array
my @distinctelements = ();    #holds all the disting elements
my @apriorirow = ();    #consists of rows of apriori table generated using glob
my @rowelements =
  ();    #consists of individual elements of apriori row for comparing
my @countvalues =
  ();    # contains values which are used for elimination of elements
my $globstring = '';    #for generating all permutations at a level
my $temp       = '';    #temp string for string operations
my $iptemp     = '';    #temp string for string operations

#my $aprow            = '';
my $support      = 0;    #minimum support
my $nooflines    = 0;    #number of lines
my $noofelements = 0;    #number of elements in a level
my $currentval   = 0;    #value of current element
my $sum          = 0;    # summation of all values in a level
open( WRITER,  '<', 'apip.txt' );
open( OWRITER, '>', 'opip.txt' );

#taking input
while (<WRITER>) {
	chomp;
	$inputarray[ $i++ ] = $_;
}
close WRITER;

#Single element count
$nooflines = scalar @inputarray;

for ( $i = 0 ; $i < scalar @inputarray ; $i++ ) {
	@tempiparray = split( " ", $inputarray[$i] );
	foreach (@tempiparray) {
		$counts{$_}++;
	}
}

my @sorted = sort { $counts{$b} <=> $counts{$a} } keys %counts;


print OWRITER "================================================\n";
print OWRITER "LEVEL 1 STARTS\n";
foreach (@sorted) {
	$currentval = $counts{$_};
	my $currentSupport = $currentval / $nooflines;
	if ( $currentSupport >= $support ) {
		print OWRITER "$_ => $counts{$_}	HAS SUPPORT  ", $currentSupport, "\n";
	}
}

print OWRITER "================================================\n";

@distinctelements = keys %counts;

foreach (@distinctelements) {
	$_ .= "~~~";
}

#Single element phase complete
%counts       = ();
@tempiparray  = ();
$noofelements = 0;
$sum          = 0;
$currentval   = 0;

for ( $i = 2 ; $i <= 3 ; $i++ ) {

	$globstring = join ',', @distinctelements;
	@apriorirow = glob "{$globstring}" x $i;

	for ( $l = 0 ; $l < scalar @apriorirow ; $l++ ) {

	   #Turning a apriorirow into individual elements and removing delimiter ~~~
		@rowelements = split( "~~~", $apriorirow[$l] );
		foreach (@rowelements) {
			$_ =~ s/~~~//g;
		}

		#testing whether all the elements of rowelements are present in input
		for ( $j = 0 ; $j < scalar @inputarray ; $j++ ) {
			$iptemp = $inputarray[$j];

			for ( $k = 0 ; $k < scalar @rowelements ; $k++ ) {
				$temp = $rowelements[$k];

				if ( ( $iptemp =~ / $temp / ) != 1 ) {

					#match not found
					$flag = 0;
				}
				else {
					$iptemp =~ s/ $temp /~/g;
				}

			}    #rowelement for end

			if ( $flag == 1 ) {
				$counts{$apriorirow[$l]}++;
			}

			$flag = 1;
		}    #inputarray for end

	}    #apriorirow for end

	my @sorted = sort { $counts{$b} <=> $counts{$a} } keys %counts;

	#writing elements to the file only above the support;

	print OWRITER "================================================\n";
	print OWRITER "LEVEL $i STARTS\n";
	foreach (@sorted) {
		$currentval = $counts{$_};
		my $currentSupport = $currentval / $nooflines;
		if ( $currentSupport >= $support ) {
			print OWRITER "$_ => $counts{$_}	HAS SUPPORT  ",
			  $currentSupport, "\n";
		}
	}
	$noofelements = 0;
	print OWRITER "================================================\n";

	%counts     = ();    # element phase complete
	@apriorirow = ();
	$globstring = '';
}    # combination length for end

close OWRITER;
