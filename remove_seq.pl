#!/usr/bin/perl -w


#removes sequences that are in one file from another file if there are any to find
#-r is the file with sequences to be removed from -f file
#multiple identical entry stay multiple


#
use strict;								#get data from conf file
use Getopt::Long;							#Activates commadnlin options
use File::Basename;							#library for filename separation
use vars qw($in_id $in_dir $in_ext);					#variables for seperation of filename

my $i = 0;		#counter
my $j = 0;		#counter
my $k = 0;		#counter
my $c = 0;		#counter

my %seq;		#sequence to header
my %seq_num;		#counter for multiple identical sequences
my %remove; #indicator if sequence is in file for removing sequences

my $removefile;		#file for removing
my $filename;		#file from which the sequences are removed
my $outfile;
my $help;

my $sequence;		#local save for header and sequence
my $header;

##Commandline options					
GetOptions 	("filename=s" 	 => \$filename,		#Commandline option for filename for query
		 "remove=s" 	 => \$removefile,		#filename for removing
		 "help" 	 => \$help,		#if help
);

if($help){

	print "\nUsage:\n";
	print "\tremove.pl -f sequencefile -r removefile\n\n";
	print "This script reads two files and removes identical sequences of the sequencefile to the removefile from the sequencefile.\n";
	print "Output goes to filename \"_remove.vie\" and is vienna formated.\n\n";	
	exit;
}


	open (REMOVE, "$removefile") or die "Can't open \"$removefile\": $!";	#open sequence file or stop if it doesnt work
		
		print "Reading remove file\n";
		
		####
		# Read input and form as in an array
		while (<REMOVE>) {
  		  chomp($_);
  		  	if(m/^>(.*)$/){
				$i++;
				if($sequence && $remove{$sequence}){
					$remove{$sequence} .= ";$header";
					#print "multiple sequence entry\n";

				}
				elsif($sequence){

					$remove{$sequence} = $header;
					
				
				}
				
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
		close(REMOVE);
		
		if($remove{$sequence}){
			$remove{$sequence} .= ";$header";
			#print "multiple sequence entry\n";

		}
		elsif($sequence){

			$remove{$sequence} = $header;
				
		}
		
	$sequence = 0;
	$header = 0;
		
		print "sequences in remove file: $i\n\n";
		
		open (SEQ, "$filename") or die "Can't open \"$filename\": $!";	#open sequence file or stop if it doesnt work
		
		print "Reading sequence file\n";
		
		####
		# Read input and form as in an array
		while (<SEQ>) {
  		  chomp($_);
  		  	if(m/^>(.*)$/){
				$j++;
				if($sequence && $seq{$sequence}){
					$seq_num{$sequence}++;
					$seq{$sequence}[$seq_num{$sequence}] = $header;
					#print "multiple sequence entry\n";

				}
				elsif($sequence){
					$seq_num{$sequence} = 0;
					$seq{$sequence}[$seq_num{$sequence}] = $header;
				
				}
				
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
		close(SEQ);
		
				if($sequence && $seq{$sequence}){
					$seq_num{$sequence}++;
					$seq{$sequence}[$seq_num{$sequence}] = $header;
					#print "multiple sequence entry\n";

				}
				elsif($sequence){
					$seq_num{$sequence} = 0;
					$seq{$sequence}[$seq_num{$sequence}] = $header;
				
				}
		
	$sequence = 0;
	$header = 0;

	print "sequences in sequence file: $j\n\n";

	($in_id, $in_dir, $in_ext) = fileparse($filename, '\..*$');
	
	print "Writing output file...\n";

	$outfile = "$in_dir\/".$in_id."_r\.vie";	
	open (OUT, ">$outfile") or die "Can't open \"$outfile\": $!";

	foreach my $key(keys %seq){
		if(! $remove{$key}){

			for($c=0;$c<=$seq_num{$key};$c++){
			print OUT ">$seq{$key}[$c]\n$key\n";
			
				#if($seq_num{$key}>0){
				#	print "$seq{$key}[$c]\t$seq_num{$key}\n";
			
				#}
			}
		}
		else{
			#$remove{$key} = 0;
			$k=$k+$seq_num{$key}+1;
		}
	
	}
	print "Sequences removed: $k\n\n";
	
	close(OUT);
#
#	foreach my $key(keys %remove){
#	
#		if($remove{$key}){
#		
#			print "$key\n\n";
#		}
#	}
