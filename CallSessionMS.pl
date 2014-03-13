
@filenames =
  qw (E:\\College\\Projects\\ZLearnPerl\\Small\\log00 E:\\College\\Projects\\ZLearnPerl\\Small\\log01 E:\\College\\Projects\\ZLearnPerl\\Small\\log02 E:\\College\\Projects\\ZLearnPerl\\Small\\log03 E:\\College\\Projects\\ZLearnPerl\\Small\\log04);
 
foreach (@filenames) {
	print "New file : $_ \n\n\n\n";
	system("perl SessionMS.pl $_");
}


