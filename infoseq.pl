#!/usr/bin/perl

##to do I do not implement the "steps" for quality because it is real more difficult (because of the median)


#
#Script to get some info about a given sequencefile
#modified for gle output
use strict;								#get data from conf file
use Getopt::Long;							#Activates commadnlin options
use File::Basename;							#library for filename separation
use vars qw($in_id $in_dir $in_ext);					#variables for seperation of filename


my $j = 0;						#counter
my $i = 0;						#counter
my $filename;						#filename
my $help;						#help
my $key;						#key for hashes

my $totalseq;						#total number of sequences
my $meanlength = 0;					#average length
my $medianlength;					#median of sequencelengths
my $maxlength = 0;					#longest sequence	
my $maxlength2 = 0;					#second longest sequence
my $minlength;						#shortest sequence			
my @distribution;					#Array for the length distribution

my %basecount;						#Array to save number of bases
my $basecountall = 0;					#Counts number of bases
my %baseposcount;					#counts bases over position
my @baseposcountall;					#counts all bases over position	
	
my $qualfile;						#Qualityfile
my @qual;						#Quality	
my @seq;						#Sequences

my @splitqual;						#Splitted quality
my @splitseq;						#Splitted sequence
my %qualbase;						#quality to base
my @qualpos;						#quality over position
my %qualbasepos;					#quality of base per pos
my $qualmedian;						#median of all qualitys

my @sort;						#sort variable

my $all = 0;						#Commandline Options that indicatesprinting of all data
my $length = 0;						#just print length info
my $base = 0;						#just print base info
my $jqualfile = 0;					#just print quality info
my $stand = 1;						#standart output
my $gle = 0;						#if gle is used

my @colors;						#a list of available colors for gle

my $minnum = 1;					#minimum number of sequences in this sequence positions that have to exists the be printed in grafics

my $steps = 1;					# steps for which lengths are summarized to get better results in the grafics over the length
my $sum;					#sum of parts of steps
my $sum2;

##Commandline options					
GetOptions 	("filename=s" 	 => \$filename,		#Commandline option for filename
			"help"	 => \$help,		#Command option for help
			"quality=s"=> \$qualfile,	#Commandline option to specify qualityfile and enable working with quality
			"all"	=> \$all,		#print all
			"length"=> \$length,		#print length info
			"gle"	=> \$gle,		#Uses some Info to get graphics with gle and open them with gv
			"base"	=> \$base,		#just base info
			"jquality=s"=> \$jqualfile,	#just qual info
			"minnum=i" => \$minnum,		#minimum number of values in a position to be displayed
			"steps=i" => \$steps		#steps for which lengths are summarized to get better results in the grafics over the length
		);
		
####		                             
#help
if ($help){						#Help
	print "\nUsage: infoseq.pl -f \[Filename\]...\n";
	print "Extracts some infos on a nucleotide sequence file\n";
	print "\n";
	print "Arguments:\n";
	print "  -f, --filename \[Filename\]\tSequence file with input sequences.\n";
	print "  -q, --quality  \[Filename\]\tInformation about quality in comparation with \n\t\t\t\t\tthe sequence\n";
	print " -jq, --jquality \[Filename\]\tLike -q, but just print and print all \n\t\t\t\t\tinfo about quality\n";
	print "  -l, --length\t\t\tJust print and print all Length info\n";
	print "  -b, --base\t\t\tJust print and print all info about bases\n";
	print "  -a, --all\t\t\tPrint all available infos\n";
	print "  -g, --gle\t\t\tUse gle for some graphics output \n\t\t\t\t\tand open it with ghostview\n";
	print "  -h, --help\t\t\tPrint this help and exit\n";;
	exit;
}		
		
if($jqualfile && $qualfile){
	die "jquality and quality are not compatible, just choose one of the.\n";
}
if($jqualfile){
	$qualfile = $jqualfile;				#if jqualfile is chosen also $quakfile option is active
	$jqualfile = 1;					#jqual just active as 1
}



if($all){						#if option  all is chosen all showing options acitive	
	$base = 1;
	$jqualfile =1;
	$length =1;
}

if($base == 1 or $jqualfile == 1 or $length == 1){	#if one of this option is active standart option is no more active
		$stand = 0;
}




unless($filename){
	print "Please insert Filename:\n";		#if no filename is specified it asks
	$filename = <STDIN>;
	chomp $filename;
	if ($filename eq ""){				#if also STDIN stays empty
		die("No Filename specified!")
	}
}

($in_id, $in_dir, $in_ext) = fileparse($filename, '\..*'); #Seperate Filename Filepath and file extension


$filename =~ s/(.*\.gz)$/gzip --decompress --to-stdout $1 |/;	#If gz it is automatically unzipped

#Filehandle
open (FILE, "$filename") or die "Can't open \"$filename\": $!";	#open sequence file or stop if it doesnt work

####
# Read input and form as in an array
$i = 0;
while (<FILE>) {
    chomp($_);                						 # remove word wrap
	#if (m/^[ACGTNURYMWKSBDHVacgtnurymwksbdhv]+$/) {  				 # sequence in uppercase
       	if (m/^[A-Za-z*]+$/) {  
	#if (m/^!>.*$/) { 
		unless($seq[$i]){
	
			$seq[$i] = $_;
		}
		else{$seq[$i] .= $_
		}
	}
	elsif(m/^>.*/ && $seq[$i]){
		
	
	$meanlength+=length($seq[$i]);					 #Addition of lengths of every sequence
	
	unless($medianlength){						 #length of median
		$medianlength = length($seq[$i]);
	}
	else{
		$medianlength .= ";".length($seq[$i]);
	}
	
	
	if(length($seq[$i])>$maxlength){					 #if this sequence is longer than the actual max, so its the neww max
		$maxlength2 = $maxlength;
		$maxlength = length($seq[$i]);
	}
	if(length($seq[$i])>$maxlength2 &&  length($seq[$i])<$maxlength){
		$maxlength2 = length($seq[$i]);
	}
	
	unless($minlength){						 #if minlength does not exist this sequence is the new minimum
		$minlength=length($seq[$i]);
	}
	if(length($seq[$i])<$minlength){					 #if this sequence is shorter than the actual min. This sequence is the new min
		$minlength=length($seq[$i]);
	}
	unless($distribution[length($seq[$i])]){				 #Initiation of distribution if it doenst exist yet
		$distribution[length($seq[$i])] = 0;
	}
	$distribution[length($seq[$i])]++;					 #Count distribution on index equal the length
	
	$j=1;
	foreach my $base (split //, $seq[$i]) {				 #Go throw each base of sequence
		    $base = uc($base);					 #transform lc bases to uppercase
		    unless($basecount{$base}){				 #Inititate if does not exist
		    	$basecount{$base} = 0;
		    }
		    unless($baseposcountall[$j]){			 #Inititate if does not exist
		    	$baseposcountall[$j] = 0;
		    }
		    unless($baseposcount{$base}[$j]){			 #Inititate if does not exist
		    	$baseposcount{$base}[$j] = 0;
		    }
            	    $basecount{$base}++;				 #Count base
		    $basecountall++;					 #counts all characters of bases
		    $baseposcount{$base}[$j]++;				 #counts bases for position
		    $baseposcountall[$j]++;				 #counts all bases for position
		    $j++;
	}
	
        $i++;
    }elsif(m/^>.*/ or m/^$/){
    	#print "$i line\n";
	
    }  
    else {								 # If sequence does not meet criteria 		   
        print "Sequence file\n";
        print "line: $_\n";
        print "Index: $i\n";
        die "Strange file\n";
    }
}
close(FILE);

#Sequence end is described with a new header, but after the last sequence is no header so it is implementedone last time

	$meanlength+=length($seq[$i]);					 #Addition of lengths of every sequence
	
	unless($medianlength){						 #length of median
		$medianlength = length($seq[$i]);
	}
	else{
		$medianlength .= ";".length($seq[$i]);
	}
	
	
	if(length($seq[$i])>$maxlength){					 #if this sequence is longer than the actual max, so its the neww max
		$maxlength2 = $maxlength;
		$maxlength = length($seq[$i]);
	}
	unless($minlength){						 #if minlength does not exist this sequence is the new minimum
		$minlength=length($seq[$i]);
	}
	if(length($seq[$i])<$minlength){					 #if this sequence is shorter than the actual min. This sequence is the new min
		$minlength=length($seq[$i]);
	}
	unless($distribution[length($seq[$i])]){				 #Initiation of distribution if it doenst exist yet
		$distribution[length($seq[$i])] = 0;
	}
	$distribution[length($seq[$i])]++;					 #Count distribution on index equal the length
	
	$j=1;
	foreach my $base (split //, $seq[$i]) {				 #Go throw each base of sequence
		    $base = uc($base);					 #transform lc bases to uppercase
		    unless($basecount{$base}){				 #Inititate if does not exist
		    	$basecount{$base} = 0;
		    }
		    unless($baseposcountall[$j]){			 #Inititate if does not exist
		    	$baseposcountall[$j] = 0;
		    }
		    unless($baseposcount{$base}[$j]){			 #Inititate if does not exist
		    	$baseposcount{$base}[$j] = 0;
		    }
            	    $basecount{$base}++;				 #Count base
		    $basecountall++;					 #counts all characters of bases
		    $baseposcount{$base}[$j]++;				 #counts bases for position
		    $baseposcountall[$j]++;				 #counts all bases for position
		    $j++;
	}
	
        $i++;	


$totalseq = $i;


#Quality
if($qualfile){							#just if qualfile is chosen

$qualfile =~ s/(.*\.gz)$/gzip --decompress --to-stdout $1 |/;	#If gz it is automatically unzipped

#Filehandle Qualfile
open (QUALFILE, "$qualfile") or die "Can't open \"$qualfile\": $!";	#open sequence file or stop if it doesnt work


$i = 0;
while (<QUALFILE>) {
    chomp($_);                 						# remove word wrap

    if (m/^[0-9 -]+$/) { 
           	unless($qual[$i]){
	
			$qual[$i] = $_;
		}
		else{$qual[$i] .= " $_";
		}
	}
	elsif(m/^>.*/ && $qual[$i]){
							# quality line
	@splitqual = split(/ /,$qual[$i]);				#split quality
	@splitseq = split(//,$seq[$i]);					#split sequence
	for($j=0;$j<=$#splitqual;$j++){
			unless($qualbase{$splitseq[$j]}){			#for median of qual per base
				$qualbase{$splitseq[$j]} = $splitqual[$j];
			}
			else{
				$qualbase{$splitseq[$j]} .= ";$splitqual[$j]";		#add quality for  base with ;	
			}
							
			unless($qualbasepos{$splitseq[$j]}[$j+1]){				#for median of qual of nucleotide over position
			       $qualbasepos{$splitseq[$j]}[$j+1] = $splitqual[$j];		#+1 because the sequence psotion was saved beginning with "1" and not zero	
			}
			else{
			       $qualbasepos{$splitseq[$j]}[$j+1] .= ";$splitqual[$j]";
			}
			
			unless($qualpos[$j+1]){				#+1 because the sequence psotion was saved beginning with "1" and not zero
				$qualpos[$j+1] = $splitqual[$j];
			}
			else{
				$qualpos[$j+1] .= ";$splitqual[$j]";				#add quality for position
			}
			
			unless($qualmedian){				#Overall quality median
				$qualmedian = $splitqual[$j];
			}
			else{
				$qualmedian .= ";$splitqual[$j]";
			}
									
	}
	@splitqual = ();
	@splitseq = ();
        $i++;
    }elsif(m/^>.*/ ){
    	#print "$i line\n";
    } else {
        print "Quality file\n";
        print "line: $_\n";
        print "Index: $i\n";
        die "Strange file\n";
    }
}
close(QUALFILE);

	@splitqual = split(/ /,$qual[$i]);				#split quality
	@splitseq = split(//,$seq[$i]);					#split sequence
	for($j=0;$j<=$#splitqual;$j++){
			unless($qualbase{$splitseq[$j]}){			#for median of qual per base
				$qualbase{$splitseq[$j]} = $splitqual[$j];
			}
			else{
				$qualbase{$splitseq[$j]} .= ";$splitqual[$j]";		#add quality for  base with ;	
			}
							
			unless($qualbasepos{$splitseq[$j]}[$j+1]){				#for median of qual of nucleotide over position
			       $qualbasepos{$splitseq[$j]}[$j+1] = $splitqual[$j];		#+1 because the sequence psotion was saved beginning with "1" and not zero	
			}
			else{
			       $qualbasepos{$splitseq[$j]}[$j+1] .= ";$splitqual[$j]";
			}
			
			unless($qualpos[$j+1]){				#+1 because the sequence psotion was saved beginning with "1" and not zero
				$qualpos[$j+1] = $splitqual[$j];
			}
			else{
				$qualpos[$j+1] .= ";$splitqual[$j]";				#add quality for position
			}
			
			unless($qualmedian){				#Overall quality median
				$qualmedian = $splitqual[$j];
			}
			else{
				$qualmedian .= ";$splitqual[$j]";
			}
									
	}
	@splitqual = ();
	@splitseq = ();
        $i++;

if ($i!=$totalseq) {							#If number of sequences in qualityfile is not equal sequencenumber in sequencefile exit
    print "Sequence  file: $totalseq sequences\n";
    print "Quality file: $i sequences\n";
    die "Strange file\n"
}
}


sub median {					#calulates the median of a skalar with a string of ";" seperated values
	my $median = $_[0];
	
	my @sort = sort{$a <=> $b} split(/;/,$median);
		
		if(int(($#sort+1)/2) == ($#sort+1)/2){ ##wenn N gerade
			$median = ($sort[(($#sort+1)/2)-1]+$sort[(($#sort+1)/2)])/2;
		#	print "$key = ",$sort[$#sort]," ",$sort[$#sort/2]," ",($sort[(($#sort+1)/2)-2]+$sort[(($#sort+1)/2)]-1)/2,"\n";
		}
		else{						##wenn N nicht gerade
			$median = $sort[(($#sort+2)/2)-1];
		#	print "$key = ",$sort[$#sort]," ",$sort[$#sort/2]," ",$sort[(($#sort+2)/2)-2]," ",$sort[(($#sort+2)/2)],"\n";
		}
		
		@sort = ();
		return $median;
}
	
if($qualfile && ($jqualfile == 1 or $stand == 1 or $gle == 1)){#just get qualitymedian if qualfile ist given

	###qualmedian
	$qualmedian = median($qualmedian);


	###qualbase median
	foreach $key(keys %basecount){					
		$qualbase{$key} = median($qualbase{$key});
	}
	
	if($jqualfile == 1 or $gle == 1){#cause this stem needs much time, only do of needed
		###qualpos median
		
		for($i = 1; $i <= $#baseposcountall; $i++){				#get qualpos
				$qualpos[$i] = median($qualpos[$i]);
		}


		###qualbasepos median
		for($i = 1; $i <= $#baseposcountall; $i++){				#get qualbasepos

			foreach $key(keys %basecount){
				unless($qualbasepos{$key}[$i]){				#If there is no base in this position
					$qualbasepos{$key}[$i] = "-"
				}
				else{
					$qualbasepos{$key}[$i] = median($qualbasepos{$key}[$i]);
				}
			}		
			
			
		}
		
	}

}

$medianlength = median($medianlength);


$meanlength = $meanlength/$totalseq;					#Calculation of mean of length




if($length==1 or $stand == 1){						#just print if standart ouput or length is chosen
	print "\nSequencelength:";
	print "\n\nSequencenumber:\t$totalseq\n";					#total number of sequences
	printf ("\nAverage sequence length: %2.2f b",$meanlength);		#Average sequences length
	print "\nMedian of sequence lengths: $medianlength b";			#median length
	print "\n\nMaximum length: $maxlength b\n";				#maximal sequence length
	print "Second highest length: $maxlength2 b";				#maximal sequence length
	print "\nMinimum length: $minlength b";				#minimal sequence length

	if($length == 1){						#in default not all length info is printed. In Info all is printed

	print "\n\nLengthdistribution:\n(steps: $steps)\n\nLength:\t";

		for ($i=$minlength;$i<=$maxlength;$i+=$steps){		# lengthdistribution of the sequences
			unless($steps == 1 ){
				print "\t",$i+(($steps-1)/2);
			}
			else{
				print "\t",$i;
			}
		}
	print "\nNumber:\t";
		for ($i=$minlength;$i<=$maxlength;$i+=$steps){
			unless($distribution[$i]){
				$distribution[$i] = 0;
			}

			
			unless($steps == 1){
				
				$j = $steps-1;
				while($j > 0){
					unless($distribution[$i+$j]){
						$distribution[$i+$j] = 0;
					}
					$j--;
				}
				
				$j = $steps-1;
				$sum = 0;
				while($j >= 0){
					
					$sum += $distribution[$i+$j];
					$j--;
					
				}	
				
				print "\t$sum";
			}
			else{

				print "\t$distribution[$i]";

				
			}
			
					#absolute number of length
		}
	print "\nPercentage:";
		for ($i=$minlength;$i<=$maxlength;$i+=$steps){
			
			unless($steps == 1){
				
				$j = $steps-1;
				$sum = 0;
				while($j >= 0){
					
					$sum += $distribution[$i+$j];
					$j--;
					
				}	
				printf "\t%4.2f%%", 100.*($sum/$totalseq);
				
				#print "\t$sum";
			}
			else{

				printf "\t%4.2f%%", 100.*($distribution[$i]/$totalseq);#percentage of length

				
			}
		}
	}
}


if($base == 1 or $stand == 1){							#just print if standart ouput or base is chosen
	print "\n\nNucleotidecomposition:\n\n";

	print "Number of nucleotides: $basecountall b\n\nNucleotide:";		#number of characters

	foreach $key(keys %basecount){
		print "\t$key";
	}
	print "\nNumber:\t\t";
	foreach $key(keys %basecount){					#number of bases per base
		print "$basecount{$key}\t";
	}
	print "\nPercentage:";
		foreach my $key(keys %basecount){					#percentage of bases of number of all bases
	printf "\t%4.2f%%", 100.*($basecount{$key}/$basecountall);
		}
	print "\n\nGC-Content: ";
	printf "\t%4.2f%%", 100.*(($basecount{"G"}+$basecount{"C"})/$basecountall);
		
	if($base == 1){
	print "\n\nNucleotides over position:\n(steps: $steps)";

	print "\n\nPosition:";							#percentage of bases per sequence postion
		for($j=1;$j<=$#baseposcountall;$j+=$steps){
			unless($steps == 1 ){
				print "\t",$j+(($steps-1)/2);
			}
			else{
				print "\t",$j;
			}
		}
	print "\n";
		foreach my $key(keys %basecount){					#for each base
			print "$key:\t";					
				for($j=1;$j<=$#baseposcountall;$j+=$steps){				#for each position
					
					unless($baseposcount{$key}[$j]){
						$baseposcount{$key}[$j]	= 0;
					}

					unless($baseposcountall[$j]){
						$baseposcountall[$j]= 0;
					}
					
					unless($steps == 1){
				
						$i = $steps-1;
						while($i > 0){
							unless($baseposcount{$key}[$j+$i]){
								$baseposcount{$key}[$j+$i] = 0;
							}
							unless($baseposcountall[$j+$i]){
								$baseposcountall[$j+$i] = 0;
							}
							$i--;
						}
				
						$i = $steps-1;
						$sum = 0;
						$sum2 = 0;
						while($i >= 0){
					
							$sum += $baseposcount{$key}[$i+$j];
							$sum2 += $baseposcountall[$i+$j];
							$i--;
					
						}	
						printf "\t%4.2f%%", 100.*($sum/$sum2);
					
					}
					else{

					
						printf "\t%4.2f%%", 100.*($baseposcount{$key}[$j]/$baseposcountall[$j]);
				
					}
					
					
				}
		print "\n";	
		}
	print "Total:\t";
		for($j=1;$j<=$#baseposcountall;$j+=$steps){					#number of bases in this position
		
			
					unless($baseposcountall[$j]){
						$baseposcountall[$j]= 0;
					}


					
					unless($steps == 1){
				
						$i = $steps-1;
						while($i > 0){
							unless($baseposcountall[$j+$i]){
								$baseposcountall[$j+$i] = 0;
							}

							$i--;
						}
				
						$i = $steps-1;
						$sum = 0;
						while($i >= 0){
					
							$sum += $baseposcountall[$j+$i];

							$i--;
					
						}	
						print "\t$sum";
					
					}
					else{

					
						print "\t$baseposcountall[$j]";
				
					}
			
			#print "\t$baseposcountall[$j]";
		}

	}
}
print "\n";
#
#If quality is chosen here the quality infos are given
#
if($qualfile){
	if($jqualfile == 1 or $stand == 1){				#just print if standart ouput or jqual is chosen
		print "\nQualitys:\n\n";
		
		printf "Median of qualitys:\t$qualmedian\n\n";	#Overall median of quality
		print "Median of qualitys per nucleotide:\n\nNucleotide:";

		foreach $key(keys %basecount){
			print "\t$key";
		}
		print "\nQuality:";
		foreach my $key(keys %basecount){					#Average quality per base
			print "\t$qualbase{$key}";
		}
		print "\n\n";
		if($jqualfile == 1){						#if this print auotmatically all quality info
			print "\nQualitys over position:";

			print "\n\nPosition:";							#Average quality of bases per sequence postion
			for($j=1;$j<=$#baseposcountall;$j+$steps){
				print "\t$j";					#Position
			}
			foreach $key(keys %basecount){
				print "\n$key:\t";
				for($j=1;$j<=$#baseposcountall;$j++){					
						print "\t$qualbasepos{$key}[$j]";		#median quality	
								#Average quality per base
				}
			}
			print "\nAll:\t";
			for($j=1;$j<=$#baseposcountall;$j++){					
				print "\t$qualpos[$j]";		#median quality	
			}
			print "\n";
		}
	}

}	


if($gle == 1){
	@colors = ("", "black", "crimson", "limegreen", "royalblue", "tomato", "gray20", "brown", "fuchsia");
#begin gle
	if($minlength == $maxlength){#if there is only one length of sequences
		print "There is only one sequencelength\n";
	}

	print "\n";

	open (DATA, "> length.dat") or die "Can't open \"length.dat\": $!";	#open filename for writung
		print DATA "\"Position\", \"Frequency\"\n";
		
		for ($i=$minlength;$i<=$maxlength;$i++){		# lengthdistribution of the sequences
			
#			
#			print DATA "$i, ";
#		
#			unless($distribution[$i]){
#				$distribution[$i] = 0;
#			}
#			print DATA "$distribution[$i]";
#			unless($i == $maxlength){
#			print DATA "\n";
#			}

		for ($i=$minlength;$i<=$maxlength;$i+=$steps){		# lengthdistribution of the sequences
			unless($steps == 1 ){
				print DATA $i+(($steps-1)/2),", ";
			}
			else{
				print DATA $i,", ";
			}

			unless($distribution[$i]){
				$distribution[$i] = 0;
			}

			
			unless($steps == 1){
				
				$j = $steps-1;
				while($j > 0){
					unless($distribution[$i+$j]){
						$distribution[$i+$j] = 0;
					}
					$j--;
				}
				
				$j = $steps-1;
				$sum = 0;
				while($j >= 0){
					
					$sum += $distribution[$i+$j];
					$j--;
					
				}	
				
				print DATA "$sum, ";
			}
			else{

				print DATA "$distribution[$i], ";

				
			}
			
			print DATA "\n";
			
					#absolute number of length
		}
								
		}

	close (DATA);


	open (LENGTH, "> length.gle") or die "Can't open \"length.gle\": $!";	#open filename for writung
		
		
		print LENGTH "size 16 12\n\n";
		
		
		print LENGTH "!Lengthdistribution\n";
		print LENGTH "begin graph\n";
		print LENGTH "\ttitle  \"Lengthdistribution\" hei 0.5\n";
   		print LENGTH "\tytitle \"Frequency\"\n";
   		print LENGTH "\txtitle \"Length\"\n";
   		
		print LENGTH "\txaxis\n"; #nofirst nolast
   		print LENGTH "\txticks length -.1\n";
   		#print LENGTH "\txsubticks off\n";
		print LENGTH "\tkey off\n";
		print LENGTH "\tyaxis dsubticks 1\n";
		print LENGTH "\tyticks length -.1\n";
		   		
		#print LENGTH "\tyaxis grid\n";
		
   		print LENGTH "\tx2axis off\n";
   		print LENGTH "\ty2axis off\n";

   		print LENGTH "\tdata   \"length.dat\"\n";
   		print LENGTH "\tbar d1  color darkblue fill darkblue\n";
		print LENGTH "end graph\n";
	close (LENGTH);





	open (DATA, "> nucleotide.dat") or die "Can't open \"nucleotide.dat\": $!";	#open filename for writung		
							#percentage of bases per sequence postion		
		print DATA "\"Position\"";
		
		foreach my $key(keys %basecount){
			print DATA ", \"$key\"";
		}
		
		print DATA "\n";
		
#		for($j=1;$j<=$#baseposcountall;$j++){
#			if($baseposcountall[$j] >= $minnum){ #minimum number of bases per position
#			print DATA "$j";	
#			foreach my $key(keys %basecount){					#for each base									#for each position
#				printf DATA ", %4.2f", 100.*($baseposcount{$key}[$j]/$baseposcountall[$j]);
#			}
#			}
#			
#				print DATA "\n";
#			
#		}
		
		
								#percentage of bases per sequence postion
		for($j=1;$j<=$#baseposcountall;$j+=$steps){
			if($baseposcountall[$j] >= $minnum){
				unless($steps == 1 ){
					print DATA $j+(($steps-1)/2);
				}
				else{
					print DATA $j;
				}

				foreach my $key(keys %basecount){					#for each base
										
					unless($baseposcount{$key}[$j]){
						$baseposcount{$key}[$j]	= 0;
					}

					unless($baseposcountall[$j]){
						$baseposcountall[$j]= 0;
					}
					
					unless($steps == 1){
				
						$i = $steps-1;
						while($i > 0){
							unless($baseposcount{$key}[$j+$i]){
								$baseposcount{$key}[$j+$i] = 0;
							}
							unless($baseposcountall[$j+$i]){
								$baseposcountall[$j+$i] = 0;
							}
							$i--;
						}
				
						$i = $steps-1;
						$sum = 0;
						$sum2 = 0;
						while($i >= 0){
					
							$sum += $baseposcount{$key}[$i+$j];
							$sum2 += $baseposcountall[$i+$j];
							$i--;
					
						}	
						printf DATA ", %4.2f", 100.*($sum/$sum2);
						
					
					}
					else{

					
						printf DATA ", %4.2f", 100.*($baseposcount{$key}[$j]/$baseposcountall[$j]);
				
					}
					
					
				}
				
			}
			
			print DATA "\n";
				
		}

		

		
		
		
		
			
	close (DATA);



	open (POSITION, "> nucleotide.gle") or die "Can't open \"nucleotide.gle\": $!";	#open filename for writung

		print POSITION "\nsize 16 12\n\n";#10 8\n\n";
		
		
		print POSITION "!Nucleotide frequency over position\n";
		print POSITION "begin graph\n";

		
		print POSITION "\ttitle  \"Nucleotide frequency over position\" hei 0.5\n";
		print POSITION "\tytitle \"Frequency\"\n";
		print POSITION "\txtitle \"Position\"\n";
	
		print POSITION "\txaxis min 1\n";
	
		print POSITION "\tyaxis dsubticks 1 format \"fix 0 append \'%\'\"\n";
	
		print POSITION "\tx2axis off\n";
		print POSITION "\ty2axis off\n";
		print POSITION "\tdata   \"nucleotide.dat\"\n";
		
		
		my $k = 1;
		my $c = 1;
		for($i = 1; $i <= keys %basecount; $i++){
#			my $rgb = "";
#			
#			#Gives colors for infinite datasets, but after 7 datesets it begins to produce difficult to distinguish colors			#get the rgb as rgb with combination of 0 and $c
#			if($k =~ m/0/){
#				$rgb .= $c;
#			}
#			else{
#				$rgb .= "0";
#			}
#			
#			if($k =~ m/1/){
#				$rgb .= ",$c";
#			}
#			else{
#				$rgb .= ",0";
#			}
#			
#			if($k =~ m/2/){
#				$rgb .= ",$c";
#			}
#			else{
#				$rgb .= ",0";
#			}
#			
#			
#			if($k == 2){#modify $k to get changing values
#				$k = $k.0;
#			}
#			elsif($k == 21){
#				$k = 10;
#			}
#			elsif($k == 10){
#				$k = 102;
#			}
#			elsif($k == 102){
#				$k = 0;
#				$c = $c/2;
#			}
#			else{
#				$k++;
#			}
#			
			
			print POSITION "\td$i line color $colors[$c] lstyle $k\n"; #color rgb($rgb)\n";
	
			if($c <= $#colors){
				$c++;
			}
			else{
				$c = 1;
				$k++;
			}
		
		}
		
		print POSITION "\tkey compact pos tr offset -0.01 0 \n";

		
		print POSITION "end graph\n";
	close (POSITION);

	system("gle length.gle");
	system("gv  length.eps &");
	
	system("gle nucleotide.gle");
	system("gv  nucleotide.eps &");


	#system("rm length.gle length.dat nucleotide.gle nucleotide.dat");

	if($qualfile){

	   open (DATA, "> quality.dat") or die "Can't open \"quality.dat\": $!";	#open filename for writung
		print DATA "\"Position\", \"All\"";
		foreach $key(keys %basecount){
			print DATA ", \"$key\"";
		 }
		print DATA "\n";
		
		my $medianmax = 0;
		my $medianmin;
		#my $maxqual = 0;
		
		for($i=1;$i<=$#baseposcountall;$i++){
			if($baseposcountall[$i] < $minnum){ print DATA "\n";last;}
			if($qualpos[$i] ne ""){
			print DATA "$i, $qualpos[$i]";
			
			foreach $key(keys %basecount){
				if($qualbasepos{$key}[$i] eq "-"){
					print DATA ", *";
				}
				else{  # if($qualbasepos{$key}[$i] > $maxqual){$maxqual = $qualbasepos{$key}[$i]}
					print DATA ", $qualbasepos{$key}[$i]";
					if($medianmax < $qualbasepos{$key}[$i]){
						$medianmax = $qualbasepos{$key}[$i];
					}
					unless($medianmin){
						$medianmin = $qualbasepos{$key}[$i];
					}
					if($medianmin > $qualbasepos{$key}[$i]){
						$medianmin = $qualbasepos{$key}[$i];
					}
				}
			}
			
			unless($i == $maxlength){
			print DATA "\n";
			}
			}
								
		}
		#print " aw $maxqual  wa\n";

	   close (DATA);

	   open (QUALITY, "> quality.gle") or die "Can't open \"quality.gle\": $!";	#open filename for writung
		
		print QUALITY "\nsize 16 12\n\n";
		
		
		print QUALITY "!Average quality over position\n";
		print QUALITY "begin graph\n";

		
		print QUALITY "\ttitle  \"Median of qualities over position\" hei 0.5\n";
		print QUALITY "\tytitle \"Median of qualities\"\n";
		print QUALITY "\txtitle \"Position\"\n";
	
		print QUALITY "\txaxis min 100 dticks 500 dsubticks 100\n";
		print QUALITY "\tyaxis dsubticks 1\n";#max ",$medianmax+5,"\n";
		
		print QUALITY "\tx2axis off\n";
		print QUALITY "\ty2axis off\n";
		print QUALITY "\tkey compact pos tr offset -0.01 0\n";
		
		print QUALITY "\tdata   \"quality.dat\" ";
		
		$i = 1;
		$basecount{"All"} = $basecountall;		#to get the number of nucleotides + all
		foreach $key(keys %basecount){
			print QUALITY "d$i=c1,c",$i+1," ";
			$i++;
		}
		print QUALITY "\n\n";
		
		$i = 1;
		$c = 1;
		$k = 1;
		foreach $key(keys %basecount){
			print QUALITY "\td$i line color $colors[$c] lstyle $k\n";
			if($c <= $#colors){
				$c++;
			}
			else{
				$c = 1;
				$k++;
			}
			$i++;
		
		
		}
	
		

		
		print QUALITY "end graph\n";
	   close (QUALITY);
	
	   system("gle quality.gle");
	   system("gv  quality.eps &");
		
	   #system("rm quality.gle quality.dat");

	}

}
