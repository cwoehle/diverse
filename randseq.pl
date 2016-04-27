#!/usr/bin/perl -w


#this script gets a sequnce file in fasta format and randomizes the letters of each sequence#

use strict;								#get data from conf file
	
my $filename = $ARGV[0];

my @querys;
my %sequences;

my $sequence=0;
my $header=0;

my @array;
my $size;
my $nr;
my $letters;

###Reading of sequences of queryfile in a hash with the header as key	
	open (QUERY, "$filename") or die "Can't open \"$filename\": $!";	#open sequence file or stop if it doesnt work
		
	
		####
		# Read input and form as in an array
		while (<QUERY>) {
  		  chomp($_);
  		  	if(m/^(>.*)$/){
				push(@querys, $1);
				if($sequences{$header}){
					print "Sequence file\n";
        				print "line: $_\n";
       			 		die "multiple identical IDs ?\n";

				}
				elsif($sequence){

					$sequences{$header} = $sequence;
				
				}
			#print "$header\n";
			$header = $1;
			$sequence = 0;	

			}
			elsif(/[A-Za-z*]+/){
				unless($sequence){
					$sequence = $_;
				}
				else{
					$sequence .= $_;
				}
		    	}
			elsif(/^$/){} 
    			else {								 # If sequence does not meet criteria 		   
    			    	print "Sequence file\n";
        			print "line: $_\n";
       			 	die "Strange file\n";
		    	}
		}
		close(QUERY);

	#additional use of this part for the last sequence
	if($sequences{$header}){
		print "Sequence file\n";
        	print "end of file\n";
       		die "multiple identical IDs ?\n";

	}
	elsif($sequence){
		$sequences{$header} = $sequence;
				
	}
		
	$sequence = 0;
	$header = 0;
	
	
	#Output head and randomized sequence
	
	
	foreach(@querys){
		
		print "$_\n";
		
		@array=();
		@array=split(//,$sequences{$_});
		$letters="";
		
		
		#randomize by splice from old array to new scalar
		while(@array){
			$size=@array;
			$nr=int(rand($size));
			
			
			$letters.=splice(@array,$nr,1);
			
			
		
		
		}
		
		print "$letters\n";
	
	
	
	
	}
