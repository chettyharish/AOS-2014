#Version with changed delimiter 'A' and array based counting
#use strict;
use warnings;
use Date::Parse;
use String::Util 'trim';
use Algorithm::Combinatorics qw(combinations);

####################################################################
#initializing all required variables
my $inputlog      = "E:\\College\\Projects\\ZLearnPerl\\Small\\log_000";
my $tempfile      = "temp.txt";
my $processeddata = "data.csv";
my $outputfile    = "output.txt";
my @resultarray      = ();    #for storing the values
my @auxref           = ();    #for storing the temporary values
my %frequency        = ();    #for calculating the frequency for Apriori
my %hashtable        = ();    #for hashing in Apriori
my %reversehashtable = ();    #for unhashing in Apriori
my ( $i, $j, $k ) = 0;        #for iteration
my $n         = 0;            #for number of elements in the $inputlog
my $hashValue = 0;            #hash values for %hashtable as a counter
my ( $hi, $lo ) = 0;          #for mergeSort bounds

my $find = ".";               #for removing . character from IP address
$find = quotemeta $find;      #for removing quotemeta in $find
my $replace          = "";         #replace . with nothing
my $wrongline        = 0;          #for counting wrong input lines
my $temp             = '';         #for url inputs
my $ip_value         = 0;          #for IP address without . character
my $stored_IP        = 0;          #for sessionizing using IP
my $stored_TS        = 0;          #for sessionizing using Timestamp
my $sessionline      = '';         #for concatenating entries of a session
my $oldsessionval    = 0;          #for creating rows for Apriori
my $counter          = 0;          #Session Counter
my $TS_dif           = 10 * 60;    #Session window (10 minutes)
my $currenthashValue = 0;          #store temporary hash value
my $noofiterations   = 10;         #set number of Apriori Levels

####################################################################

####################################################################
#sub parseLog starts here
sub parseLog() {
	my $linecount = 0;
	open( INPUTFILE, '<', $inputlog )
	  or die "Could not open $inputlog\n";

	#Parsing input into a table
	while ( my $log_line = <INPUTFILE> ) {
		if ( $linecount == 10000 ) { last; }
		chomp $log_line;

		#Getting File Path and protocol only for GET
		if ( $log_line =~ /GET (.+?) / ) {
			$temp = $&;
			$temp =~ s/GET \///g;
			$temp = trim($temp);
			$resultarray[$i][2] = $temp;
			$linecount++;
		}
		else {
			$resultarray[$i][0] = undef;
			$resultarray[$i][1] = undef;
			$resultarray[$i][2] = undef;
			$wrongline++;
			$linecount--;
			next;    #storing only the GET statements
		}

		#Getting IP address
		if ( $log_line =~ /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/ ) {
			$ip_value = $&;
			$ip_value =~ s/$find/$replace/g;
			$resultarray[$i][0] = $ip_value;
		}
		else {
			$resultarray[$i][0] = undef;
			$resultarray[$i][1] = undef;
			$resultarray[$i][2] = undef;
			$linecount--;
			$wrongline++;
			next;
		}

		#Getting Timestamp
		if ( $log_line =~ /\d{2}(.){5}\d{4}:\d{2}:\d{2}:\d{2}/ ) {
			$resultarray[$i][1] = str2time($&);
		}
		else {
			$resultarray[$i][0] = undef;
			$resultarray[$i][1] = undef;
			$resultarray[$i][2] = undef;
			$linecount--;
			$wrongline++;
			next;
		}

		$i++
		  ; #incrementing to next element location only if all the data was successfull retrieved
	}
	$n = @resultarray;    #number of elements in resultarray
	print "Number of lines in the log : $n\n";
	print "Number of wrong lines skipped : $wrongline\n";
}    # sub parseLog ends
####################################################################

####################################################################
#sub mergeSort starts here
sub mergeSort {

	my ($aref)   = $_[0];
	my ($auxref) = $_[1];
	my $lo       = $_[2];
	my $hi       = $_[3];

	if ( $hi <= $lo ) { return; }
	my $mid = 0;
	$mid = int( $lo + ( $hi - $lo ) / 2 );
	mergeSort( $aref, $auxref, $lo,      $mid );
	mergeSort( $aref, $auxref, $mid + 1, $hi );
	merge( $aref, $auxref, $lo, $mid, $hi );

}    #sub mergeSort ends
####################################################################

####################################################################
#sub merge of mergeSort begins
sub merge {

	my ($aref)   = $_[0];
	my ($auxref) = $_[1];
	my $lo       = $_[2];
	my $mid      = $_[3];
	my $hi       = $_[4];

	for ( $i = $lo ; $i <= $hi ; $i++ ) {
		$auxref->[$i][0] = $aref->[$i][0];
		$auxref->[$i][1] = $aref->[$i][1];
		$auxref->[$i][2] = $aref->[$i][2];
	}
	$i = $lo;
	$j = $mid + 1;

	for ( $k = $lo ; $k <= $hi ; $k++ ) {
		if ( $i > $mid ) {
			$aref->[$k][0] = $auxref->[$j][0];
			$aref->[$k][1] = $auxref->[$j][1];
			$aref->[$k][2] = $auxref->[$j][2];
			$j++;
		}
		elsif ( $j > $hi ) {
			$aref->[$k][0] = $auxref->[$i][0];
			$aref->[$k][1] = $auxref->[$i][1];
			$aref->[$k][2] = $auxref->[$i][2];
			$i++;
		}
		elsif ( $auxref->[$i][0] <= $auxref->[$j][0] ) {
			$aref->[$k][0] = $auxref->[$i][0];
			$aref->[$k][1] = $auxref->[$i][1];
			$aref->[$k][2] = $auxref->[$i][2];
			$i++;
		}
		else {
			$aref->[$k][0] = $auxref->[$j][0];
			$aref->[$k][1] = $auxref->[$j][1];
			$aref->[$k][2] = $auxref->[$j][2];
			$j++;
		}
	}

}    #sub merge ends
####################################################################

####################################################################
#sub createSession starts here
sub createSession() {

	#creating sessions here
	$stored_IP         = $resultarray[0][0];
	$stored_TS         = $resultarray[0][1];
	$resultarray[0][3] = 0;

	for ( $i = 1 ; $i < $n ; $i++ ) {
		if ( $resultarray[$i][0] != $stored_IP ) {
			$counter++;
			$stored_IP          = $resultarray[$i][0];
			$stored_TS          = $resultarray[$i][1];
			$resultarray[$i][3] = $counter;
		}
		elsif ( ( $resultarray[$i][1] - $stored_TS ) > $TS_dif ) {
			$counter++;
			$stored_IP          = $resultarray[$i][0];
			$stored_TS          = $resultarray[$i][1];
			$resultarray[$i][3] = $counter;
		}
		else {
			$resultarray[$i][3] = $counter;
		}

	}

}    #sub createSession ends

####################################################################

####################################################################
#sub printToFile starts here
sub printToFile {
	open( DATAFILE, '>', $processeddata )
	  or die "Could not open $processeddata\n";
	print DATAFILE "The number of rows processed was $n\n";
	print DATAFILE "IP ADDRESS,TIMESTAMP,FILE,SESSION NUMBER\n";

	#print output of phase 1 in data.csv file
	for ( $i = 0 ; $i < $n ; $i++ ) {
		print DATAFILE
		  "$resultarray[$i][0],$resultarray[$i][1],$resultarray[$i][2]\n";
	}

}    #sub printToFile ends
####################################################################

####################################################################
#sub createList starts here
sub createList() {

	$oldsessionval = 0;
	$counter       = 0;
	open( TEMPWRITER, '>', $tempfile ) or die "Could not open $tempfile\n";

	#inserting the first element from tempfile
	$hashtable{ $resultarray[0][2] } = $hashValue;
	$reversehashtable{$hashValue} = $resultarray[$i][2];
	$hashValue++;
	$sessionline .= " ";
	$sessionline .= $hashValue - 1;
	$counter++;

	for ( $i = 1 ; $i < $n ; $i++ ) {

		if ( $oldsessionval < $resultarray[$i][3] ) {

			#new session so terminating the line
			$sessionline .= " \n";

			if ( $counter > 1 ) {

				#only writing if there are more than one entry in a session
				print TEMPWRITER $sessionline;
			}
			$sessionline   = '';
			$counter       = 0;
			$oldsessionval = $resultarray[$i][3];
		}

		$sessionline .= " ";

		$resultarray[$i][2] = trim( $resultarray[$i][2] );

		if ( exists $hashtable{ $resultarray[$i][2] } ) {

			$currenthashValue = $hashtable{ $resultarray[$i][2] };
			$sessionline .= $currenthashValue;
			$counter++;
		}
		else {
			$hashtable{ $resultarray[$i][2] } = $hashValue;
			$reversehashtable{$hashValue} = $resultarray[$i][2];
			$sessionline .= $hashValue;
			$hashValue++;
			$counter++;
		}

		#clearing the row which has been processed
		$resultarray[$i][0] = undef;
		$resultarray[$i][1] = undef;
		$resultarray[$i][2] = undef;
		$resultarray[$i][3] = undef;

	}

	# emptying the resultarray releasing memory
	@resultarray = ();
	close TEMPWRITER;

}    #sub createList ends here
####################################################################

####################################################################
#sub apriori starts here
sub apriori {

	my @inputarray = ();
	my ( $i, $j, $k, $l, $p ) = 0;
	my $flag   = 1;    #for testing wheter all subparts matched
	my %counts = ();   #hash table storing the elements and their distinct count
	my %newcounts = ()
	  ; #hash table storing the elements for finding distinct elements iteratively
	my @tempiparray      = ();    # Level 1 temp array
	my @distinctelements = ();    #holds all the disting elements
	my @apriorirow = (); #consists of rows of apriori table generated using glob
	my @rowelements =
	  ();    #consists of individual elements of apriori row for comparing
	my @countvalues =
	  ();    # contains values which are used for elimination of elements
	my $globstring = '';      #for generating all permutations at a level
	my $temp       = '';      #temp string for string operations
	my $iptemp     = '';      #temp string for string operations
	my $support    = 0.05;    #minimum support
	my $nooflines  = 0;       #total number of input lines
	my $currentval = 0;       #value of current element
	my $distinctelementstring = ''; #string of distinct elements for permutation
	my $nameofArray           = ''; #for element arrays
	open( WRITER,  '<', $tempfile )   or die "Could not open $tempfile\n";
	open( OWRITER, '>', $outputfile ) or die "Could not open $outputfile\n";

	my ( $no, $yes ) = 0;

	#taking input
	while (<WRITER>) {
		chomp;
		$inputarray[ $i++ ] = $_;
	}
	close WRITER;

	print "Number of sessions created : ", scalar @inputarray, "\n";

	#Single element count
	for ( $i = 0 ; $i < scalar @inputarray ; $i++ ) {
		@tempiparray = split( " ", $inputarray[$i] );
		foreach (@tempiparray) {
			if ( exists $counts{$_} ) {
				push( $counts{$_}, $i );
			}
			else {
				$nameofArray = '@arrayvalue' . "$_";
				$counts{$_} = \@$nameofArray;
				push( $counts{$_}, $i );
			}
		}
	}

	$nooflines = scalar @inputarray;

	#writing elements to the file only above the support;
	print OWRITER "================================================\n";
	print OWRITER "LEVEL 1 STARTS\n";

	foreach ( keys %counts ) {

		$currentval = scalar @{ $counts{$_} };
		my $currentSupport = $currentval / $nooflines;
		if ( $currentSupport >= $support ) {
			print OWRITER "$reversehashtable{$_} => ", scalar @{ $counts{$_} },
			  "	    HAS SUPPORT  ",
			  $currentSupport,
			  "\n";

			#	print OWRITER "$_ => $counts{$_}	    HAS SUPPORT  ",
			#	  $currentSupport,
			#	  "\n";

		}
		$currentSupport = 0;
		$currentval     = 0;
	}

	print OWRITER "================================================\n";

	my @tempdistinctelements = keys %counts;

	$i = 0;
	foreach (@tempdistinctelements) {
		$currentval = scalar @{ $counts{$_} };
		my $currentSupport = $currentval / $nooflines;
		if ( $currentSupport >= $support ) {
			$distinctelements[ $i++ ] = $_;
		}
	}

	print "Number of Distinct Elements : ", scalar @distinctelements,
	  "\n",
	  "Distinct Elements :   @distinctelements \n";

	foreach (@distinctelements) {
		$_ .= "A";
	}

	$distinctelementstring = [@distinctelements];

	#Single element phase complete
	%counts      = ();
	@tempiparray = ();
	$currentval  = 0;

	for ( $i = 2 ; $i <= $noofiterations ; $i++ ) {

		if ( scalar @distinctelements < $i ) {
			print $i,
			  " <- less elements than level of iteration so stopping \n";
			last;
		}

		my $iter = combinations( $distinctelementstring, $i );
		while ( my $c = $iter->next ) {
			$apriorirow[ $k++ ] = "@$c";
		}

		for ( $l = 0 ; $l < scalar @apriorirow ; $l++ ) {

		 #Turning a apriorirow into individual elements and removing delimiter A
			@rowelements = split( "A", $apriorirow[$l] );
			foreach (@rowelements) {
				$_ =~ s/A//g;
				$_ = trim($_);
			}

		   #testing whether all the elements of rowelements are present in input
			for ( $j = 0 ; $j < scalar @inputarray ; $j++ ) {
				$iptemp = $inputarray[$j];

				for ( $k = 0 ; $k < scalar @rowelements ; $k++ ) {
					$temp = $rowelements[$k];

					if ( ( $iptemp =~ / $temp / ) != 1 ) {

						#match not found
						$flag = 0;
						last;
					}
					else {
						$iptemp =~ s/ $temp / ~ /g;
					}
					$temp = '';
				}    #rowelement for end
				$iptemp = '';

				if ( $flag == 1 ) {
					$yes++;
					if ( exists $counts{ $apriorirow[$l] } ) {
						push( $counts{ $apriorirow[$l] }, $j );
					}
					else {
						$nameofArray = '@arrayvalue' . "$apriorirow[$l]";
						$counts{ $apriorirow[$l] } = \@$nameofArray;
						push( $counts{ $apriorirow[$l] }, $j );
					}
				}

				$flag = 1;

			}    #inputarray for end

		}    #apriorirow for end

		#writing elements to the file only above the support;
		print OWRITER "================================================\n";
		print OWRITER "LEVEL $i STARTS\n";

		foreach ( keys %counts ) {
			$currentval = scalar @{ $counts{$_} };
			my $currentSupport = $currentval / $nooflines;
			if ( $currentSupport >= $support ) {

				#separating the elemts using delimiter A and unhashing
				@rowelements = split( "A", $_ );
				foreach (@rowelements) {
					$_ =~ s/A//g;
					$_ = trim($_);
					$newcounts{$_}++;
					print OWRITER "$reversehashtable{$_}  ||  ";
				}

				print OWRITER "=> ",scalar @{ $counts{$_} },"	    HAS SUPPORT  ",
				  $currentSupport, "\n";

				#print OWRITER "$_ => $counts{$_}	    HAS SUPPORT  ",
				#  $currentSupport,
				# "\n";
			}
		}

		print OWRITER "================================================\n";

		#generating distinct elements for each iteration

		@distinctelements = keys %newcounts;

		print "Number of Distinct Elements : ", scalar @distinctelements,
		  "\n", "Distinct Elements :   @distinctelements \n";

		foreach (@distinctelements) {
			$_ .= "A";
		}

		$distinctelementstring = [@distinctelements];

		# element phase complete
		%newcounts  = ();
		%counts     = ();
		@apriorirow = ();
		$globstring = '';
	}    # for of Levels end

	close OWRITER;
	print "Negative Matches: $no 			Positive Matches: $yes \n";
}    #sub apriori ends here

####################################################################

####################################################################
# Program calls here

my $start = time;
my $dif   = 0;

parseLog();    #sub for fetching data from the log
$dif = -( $start - time );
print "Parse Log ended at : $dif seconds", "\n";

mergeSort( \@resultarray, \@auxref, 0, $n - 1 )
  ;            #sub for sorting data on the basis of IP address
$dif = -( $start - time );
print "Merge Sort ended at : $dif seconds", "\n";

createSession();    #sub for creating sessions based on IP address and Timestamp
$dif = -( $start - time );
print "Create Session ended at : $dif seconds", "\n";

printToFile();      #sub for printing the sessions
$dif = -( $start - time );
print "Print to file ended at : $dif seconds", "\n";

createList();       #sub for creating sessions based on IP address and Timestamp
$dif = -( $start - time );
print "Create List ended at : $dif seconds", "\n";

apriori();          #sub for running apriori on the list

print "Number of lines processed is $n \n";

$dif = -( $start - time );
print "Apriori ended at : $dif seconds", "\n";

####################################################################
