#!/usr/bin/perl -w

#Search for protein GIs matching to a given Entrez search query

#search script to get GIs from NCBI. Modified to fit for large datasets.
#But additionally control output number
#Syntax entrez_gi_large.pl 'Suchanfrage'
#Output: gi.txt, gi.log

use LWP::Simple;
use strict;

my $query = $ARGV[0];
my $data = 'protein'; #can also be nucleotide
my $type = 'gi'; #can also be fasta
my $format = 'text'; #can also be xml
my $efetch_out = '';
my $efetch_out2 = '';
my $start=0;
my $base = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/';
my $counter;
my $count;
my $ind=0;
my $retmax = 10000;
my $vget;



#open output file for writing
open(OUT, ">gi.txt") || die "Can't open file!\n";
open(LOG, ">gi.log") || die "Can't open file!\n";

while(!$count || $start < $count){


#assemble the esearch URL
my $url = $base . "esearch.fcgi?db=$data&term=$query&usehistory=y";
   $url .= "&retstart=$start&retmax=100000";

#post the esearch URL
my $output = get($url);

if(!$output){

	next;



}

#parse WebEnv, QueryKey and Count (# records retrieved)
my $web = $1 if ($output =~ /<WebEnv>(\S+)<\/WebEnv>/);
my $key = $1 if ($output =~ /<QueryKey>(\d+)<\/QueryKey>/);
$count = $1 if ($output =~ /<Count>(\d+)<\/Count>/);

if(!$web || !$key){
	next;
}

if(!$start){

	print LOG "$count GIs to retrieve\n"; 


}

if($counter && $counter != $count){

	print LOG  "Number of Hits has been changed: $counter and $count";
	exit;

}


for (my $retstart = $start; $retstart < ($start+100000); $retstart += $retmax) {
        my $efetch_url = $base ."efetch.fcgi?db=$data&WebEnv=$web";
           $efetch_url .= "&query_key=$key&retstart=$retstart";
           $efetch_url .= "&retmax=$retmax&rettype=$type&retmode=$format";
        	$efetch_out = get($efetch_url);
		
		
		if(!$efetch_out){
			last;
			$vget=$retstart;
		}
		elsif($efetch_out=~m/ERROR/){
			$ind=1;
			$vget = $retstart;
			last;
		
		}
		else{
			
			$efetch_out2 = get($efetch_url);
			
			if($efetch_out2 && $efetch_out2 eq $efetch_out){
			
				print OUT "$efetch_out";
				$vget = $retstart+10000;			
			
			
			}
			else{
			
				print LOG count($efetch_out),"\t";

				if($efetch_out2){

					print LOG  count($efetch_out2),"\n";
				
				}
				else{

					print LOG "n\/a\n";

				}

				$vget = $retstart;
				last;
			
			
			}

		}
		
		
		#print STDERR "Durchlauf beendet $start\n";

}



print LOG "$start\t $vget\n";

#xit;

$counter = $count;

$start=$vget;


}



	
close OUT;

print LOG "Retrieved $count GIs\n"; 

close LOG;

sub count{
	my @a=split(/\n/,$_[0]);
	
	my $k=@a;
	
	return $k;

}                            
