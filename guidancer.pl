#!/usr/bin/perl

#This should use GUIDANCE for all files within a folder
#
use strict;								#get data from conf file
use Getopt::Long;							#Activates commadnlin options
use File::Basename;							#library for filename separation
use vars qw($in_id $in_dir $in_ext);					#variables for seperation of filename


my $j = 0;						#counter
my $i = 0;						#counter
my $k = 0;
my $c = 0;
my $x = 0;
my $y = 0;
my $folder = $ARGV[0];
my $ls = "ls -1 $folder |";

my $exe = "nice -n 19 perl /usr/local/guidance.v1.1/www/Guidance/guidance.pl";
my $seq = "--seqFile";
my $prog = "--msaProgram MAFFT";
my $type ="--seqType aa";
my $order ="--outOrder as_input";
my $out = "--outDir";

my $guidir;
my $alndir;
my $ugalndir;
my $errordir;

my @files;
my @names;

my @align;
my @alignug;
my @head;


#Filehandle
open (FILE, "$ls") or die "Can't open \"$ls\": $!";	#open sequence file or stop if it doesnt work


	while (<FILE>) {
  	  chomp($_);
		if($_ =~ m/(.*)\.fa.*/){
		
			push(@files,"$folder\/$_");
			push(@names,$1);
		
		}
	}
	
close(FILE);
	

for($i = 0; $i <= $#files; $i++){

	$guidir = "$folder\/guidance";
	$alndir = "$folder\/multiple_alignments";
	$ugalndir = "$folder\/ungapped_multiple_alignments";
	$errordir = "$folder\/ERROR";
	
	unless(-d $guidir){
		system("mkdir $guidir");
	}

	$guidir .= "\/$names[$i]";
	#print "$guidir\n";
	system("$exe $seq $files[$i] $prog $type $order $out $guidir ;");
	system("rm -rf $guidir\/MSA\.MAFFT\.Guidance_BP_Dir\.tar\.gz $guidir\/MSA\.MAFFT\.Guidance_res_pair_res\.\* $guidir\/MSA\.MAFFT\.Guidance_res_pair\.scr");
	
	unless(-d $alndir){
		system("mkdir $alndir");
	}
	
	unless(-e "$guidir\/MSA\.MAFFT\.aln\.With_Names"){
		unless(-d $errordir){
			system("mkdir $errordir");
		}
		system("cp $files[$i] $errordir");
		next;
	}
	
	system("cp $guidir\/MSA\.MAFFT\.aln\.With_Names $alndir/$names[$i].aln");
	
	
	
	
	#Filehandle
	@head = ();
	@align = ();
	@alignug = ();
		
	open (UNGAP, "$alndir/$names[$i].aln") or die "Can't open \"$alndir/$names[$i].aln\": $!";	#open sequence file or stop if it doesnt work

			$j = -1;
			while (<UNGAP>) {
  			  chomp($_);
				if($_ =~ m/^(>.*)$/){
					$j++;
					$head[$j] = $1;
				}
				elsif($_ =~ m/^$/){}
				elsif($_ =~m/^[A-Za-z\*\-]+$/ ){
					unless($align[$j]){
						$align[$j] = $_;
					}
					else{
						$align[$j] .= $_;
					}
				
				}
			}
	
	close(UNGAP);
	
	
	$x = 0;
	$y = 1;
	while(substr($align[0],$x,$y)){
		
		$c = 0;
		for($j = 0; $j <= $#align; $j++){
			if(substr($align[$j],$x,$y) eq "-"){
				$c = 1;
				last;
			}

		}
		
		unless($c == 1){
			for($j = 0; $j <= $#align; $j++){
				unless($alignug[$j]){
					$alignug[$j] = "";
				}
				
				$alignug[$j] .= substr($align[$j],$x,$y);
				
			}

		}
		
		$x++;
	}
	
	unless(-d $ugalndir){	
		system("mkdir $ugalndir");
	}	
	
	
	open (WRITE, ">$ugalndir/$names[$i].aln") or die "Can't open \"$ugalndir/$names[$i].aln\": $!";	#open sequence file or stop if it doesnt work
		
		for($j = 0; $j <= $#align; $j++){
			print WRITE "$head[$j]\n$alignug[$j]\n";	
		}
	
	close(WRITE);
	
	
	
	
	
	
		
	
}
