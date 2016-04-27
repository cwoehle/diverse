#!/usr/bin/perl

#V1.1

#This scripts searches a given sequence file, unifies double entries and substitutes protein names through an new given id
#By uncommenting it can be used with formatdb to build new database
#if a folder is given all subfolder are searched for fasta files and used
# it also replaces "U" and "u" by "X" and removes stop codons at the end.(small bug that is is sorted before "U"s are replaced, but because its mainly sorted by length and the amount of Us is very small, this shoulnt be a problem(additionallys the sorting is realy unimportant))

#
use strict;								#get data from conf file
use Getopt::Long;							#Activates commadnlin options
use File::Basename;							#library for filename separation
use vars qw($in_id $in_dir $in_ext);					#variables for seperation of filename


my $j = 0;						#counter
my $i = 0;						#counter
my $k = 0;
my $c = 0,
my $filename = $ARGV[0];				#filename
my $help;						#help
my $key;						#key for hashes
my $bigfile;

my %seq;												

my $header;						#temporary saves header
my $sequence;						#temporary saves sequence

my $startseq = 0;					#number of sequences before filtering repeating sequences
#my $sameseq = 0;					#count if a sequence is repeated
my $newseq = 0;						#Database size after filtering of repeated sequences

my @sort;						#sortieren
my $id;							#new id for the proteins
my %idind;						#indicator if id is already in use

my $description = "";					#an additional description to describe the actual data file
my $protein;						#indicates if the database is protein or not

my %newseq;						#hash for the new sequence with the new id as key

my $path = ".";					#saves the path to the files from a folder
my @fasta;						#saves complete filenames in a folder und subfolder that are fasta formated
my $ls = "ls -R1";					#ls options if using a folder
my $name;						#name of the folder for the databases
my $fastafile;						# a scalar for filenames in folder
my $ind;						#indicator if protein or nucleotide

##Commandline options					
#GetOptions 	("filename=s" 	 => \$filename,		#Commandline option for filename
#		# "id=s" 	 => \$id,		#specifies the id for the organism for the new names of the sequences#just possible if just one organism
#);

if($ARGV[0] eq "-h" || $ARGV[0] eq "--h" || $ARGV[0] eq "-help" || $ARGV[0] eq "--help"){

	print "\nUsage:\n";
	print "\tdatabase.pl filename\/folder\n\n";
	print "This script reads a file in fasta format or folder with all containing fasta files.\n";	
	print "it combines multiple entries and substitutes headers with a new id, which allocation\n";
	print "are written in a new files. followed by converting the files into Blast databases with\nformatdb.\n\n";
	exit;
}
	
	
	
unless($filename){
	print "Please insert Filename:\n";		#if no filename is specified it asks
	$filename = <STDIN>;
	chomp $filename;
	if ($filename eq ""){				#if also STDIN stays empty
		die("No Filename specified!")
	}
}



if(-d $filename){#if folder
	print "Actual file is a folder\nRecursive processing of all fasta files in the folder\n";
	
	$path = $filename;
	
	#print "$filename\n";
	
	$ls .= " \"$filename\" |";
	
	#print "$filename\n";
	
	open (LS, "$ls") or die "Can't open \"$ls\": $!";
	while(<LS>){
		chomp;
		
		if(/^$filename.*\:/){
			#print "$_\n";
			$path = $_;
			chop($path);
		}
		elsif(/^$/){}
		else{
			#print "$_\n";
			if(/.+\.fasta$/ || /.+\.fna$/ || /.+\.fa$/ || /.+\.fas$/ || /.+\.fasta\.gz$/ || /.+\.fna\.gz$/ || /.+\.fa\.gz$/ || /.+\.fas\.gz$/ || /.+\.vie\.gz$/ || /.+\.vie$/){#searches for fasta files or fasta gz
				$fasta[$k] = $path.'/'.$_;
				$k++;
			}
			
		
		}
	
	
	}
	
	close(LS);
	
	print "$k fasta files were found.\n\n";
	
	
	#extract name of the folder with pwd
	open (PWD,"cd \"$filename\" ; pwd |");
	while(<PWD>){
		chomp;
		$name = $_;
	}
	close(PWD);
		
	$name =~ s/.*[\/]{1,}(.+)$/$1/; #just extract the last folder name
	
	#print "$name\n";
	
	open (ALLOC, ">$filename\/$name\.alloc") or die "Can't open \"$filename\/$name\.alloc\": $!";	#design header fuer alloc file
		print ALLOC "\#new header\tdescription\told header\tsequence number in the new database\tprotein or nucleotide\toriginal filename of the old database\tdate of construction of the new database\n";
	close(ALLOC);
	
	$bigfile = "$filename\/$name\.db";
	
	system("rm -i $bigfile");
	system("touch $bigfile");
	
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	
			#Filehandle
	open (DB, ">$filename\/$name.databases") or die "Can't open \"$filename\/$name.databases\": $!";	#open output file or stop if it doesnt work
	
	foreach(@fasta){
	
		
		
		$sequence = 0;
		$header = 0;
		$protein = "";
		%seq = ();
		$newseq = 0;
		
		$startseq = 0;
		$newseq = 0;
		$fastafile = $_;
		
		
		($in_id, $in_dir, $in_ext) = fileparse($fastafile, '\.f.*$'); #Seperate Filename Filepath and file extension
		
		print DB "$in_dir$in_id\.db\n"; #write to "databases" file
		
		$fastafile =~ s/(.*\.gz)$/gzip --decompress --to-stdout $1 |/;	#If gz it is automatically unzipped
			#Filehandle
		open (FILE, "$fastafile") or die "Can't open \"$fastafile\": $!";	#open sequence file or stop if it doesnt work
		
		print "Reading file\n";
		
		####
		# Read input and form as in an array
		$i = 0;
		while (<FILE>) {
  		  chomp($_);
  		  	if(m/^>(.*)$/){
				if($seq{$sequence}){
					$seq{$sequence} .=";$header";
					#$sameseq++;
					#print "\n\n$seq{$sequence}\n$sequence\n";
				}
				elsif($sequence){
					$seq{$sequence} = $header;
					$newseq++;
				}
				
				$startseq++;	#also counts in the first time. SO has not to be added after processing
				$header = $1;
				$header =~ s/\t/ /g;	#no \t for easier separation later
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
		close(FILE);

		#additional use of this part for the last sequence
		if($seq{$sequence}){
			$seq{$sequence} .=";$header";
			#$sameseq++;
		}
		elsif($sequence){
			$seq{$sequence} = $header;
			$newseq++;
		}
		print "File: $in_id$in_ext\n";
		print "Number of redundant sequences: $startseq\n";
		#print "Number of multiple sequences: $sameseq\n";
		print "Number of non-redundant sequences: $newseq\n";
		
		@sort = ();
		@sort = sort{length($b) <=> length($a)}	keys %seq;	#sorting by length
		
		#unless($id){#if not done already give a new id of the organism for the proteins
			print "What abbreviation for for new protein IDs ?:\n";
			$id = <STDIN>;
			chomp $id;
			if ($id eq ""){				#if also STDIN stays empty
				die("No new ID specified!")
			}
			
			while($idind{$id}){
				print "id \"$id\" is already in use. Please specifiy another id.\n";
				$id = <STDIN>;
				chomp $id;
					if ($id eq ""){				#if also STDIN stays empty
						die("No new ID specified!")
					}
			}
			
			$idind{$id} = 1;
		#}
	
		print "Would you like to give any nearer description of the data ? If not press just ENTER:\n";
		$description = <STDIN>;
		chomp $description;
			
		#for formatdb if it is protein sequence and for alloc file
		print "Is it a protein database ? [Y/n]\n";
		$protein = <STDIN>;
		chomp $protein;
		
		if($protein eq "n" || $protein eq "N" || $protein eq "No" || $protein eq "no"){
		
			$protein = "F";
	
		}
		else{
			$protein = "T";
		}
		

		if($protein eq "T"){
				$ind = "P";
		}
		else{
				$ind = "N"
		}
	
		#Filehandle
		open (ALLOC, ">>$filename\/$name\.alloc") or die "Can't open \"$filename\/$name\.alloc\": $!";	#open alloc file or stop if it doesnt work#this file contains the new and old header
	
		#Filehandle
		open (OUTPUT, ">$in_dir$in_id\.db") or die "Can't open \"$in_dir\/$in_id\.db\": $!";	#open output file or stop if it doesnt work
		
		
		
		#if(-e $bigfile){
			open (BIG, ">>$bigfile") or die "Can't open \"$bigfile\": $!";# writing in a big database with all sequences
		#}
		#else{
		#	open (BIG, ">$filename\/$name\.db") or die "Can't open \"$filename\/$name\.db\": $!"; writing in a big database with all sequences
		#}
		
		print "Writing new sequence file and allocation file.\n";
	
		%newseq = ();
	
	
		foreach($k = 0; $k <= $#sort; $k++){
	 
			$header = sprintf("$id%06d",$k+1);
			#$newseq{$header} = $sort[$k];
			
			if($ind eq "P"){
				#replace U by X
				$sort[$k]=~tr/Uu/Xx/;
			
				#remove ending '*'
				while(substr($sort[$k],-1,1) eq '*'){
					chop($sort[$k]);
			
				}
			}

			
			
			print ALLOC "$header\t$description\t$seq{$sort[$k]}\t$newseq\t$ind\t$in_id$in_ext\t$mday\.$mon\.",$year+1900,"\n";#writes the new header, a description, the old header, the filename and the date of database production in one line seperated with tabs
			print OUTPUT ">$header\n$sort[$k]\n";
			print BIG ">$header\n$sort[$k]\n";
			$c++;
			#unless($k == $#sort){
			#	#sprint ALLOC "\n";
			#	print OUTPUT "\n";
			#}
		}
		
		#print $#sort."\n";
		#print "$id";
		close(BIG);
		close(OUTPUT);
		close(ALLOC);
	
	

		
		#print "Creating database files\n\n";
#	
#		#formatdb
		#system("formatdb -i $in_dir$in_id\.db -t $in_id -p $protein");


		}	
		
		close(DB);
		
		print "In sum there are $c sequences\n";

}
elsif(-e $filename){#if file

	($in_id, $in_dir, $in_ext) = fileparse($filename, '\..*'); #Seperate Filename Filepath and file extension

	open (ALLOC, ">$in_dir\/$in_id\.alloc") or die "Can't open \"$in_dir\/$in_id\.alloc\": $!";	#design header fuer alloc file
		print ALLOC "\#new header\tdescription\told header\tsequence number in the new database\tprotein or nucleotide\toriginal filename of the old database\tdate of construction of the new database\n";
	close(ALLOC);
	
	$filename =~ s/(.*\.gz)$/gzip --decompress --to-stdout $1 |/;	#If gz it is automatically unzipped

	#Filehandle
	open (FILE, "$filename") or die "Can't open \"$filename\": $!";	#open sequence file or stop if it doesnt work

	####
	# Read input and form as in an array
	$i = 0;
	my $ind = 0;
	while (<FILE>) {
  	  chomp($_);
  	  	if(m/^>(.*)$/){
			
			if($seq{$sequence}){
				$seq{$sequence} .=";$header";
				#$sameseq++;
				#print "\n\n$seq{$sequence}\n$sequence\n";
			}
			elsif($sequence){
				$seq{$sequence} = $header;
				$newseq++;
			}
			
			$startseq++;	#also counts in the first time. SO has not to be added after processing
			$header = $1;
			$header =~ s/\t/ /g;		#no \t for easier separation later
			$sequence = "";
		}
		elsif(/[A-Za-z*]+/){
			if($sequence eq ""){
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
        		print "Index: $i\n";
       		 	die "Strange file\n";
	    	}
	}
	close(FILE);

	#additional use of this part for the last sequence
	if($seq{$sequence}){
		$seq{$sequence} .=";$header";
		#$sameseq++;
	}
	elsif($sequence){
		$seq{$sequence} = $header;
		$newseq++;
	}
	print "File: $in_id$in_ext\n";
	print "Number of redundant sequences: $startseq\n";
	#print "Number of multiple sequences: $sameseq\n";
	print "Number of non-redundant sequences: $newseq\n";
	
	@sort = sort{length($b) <=> length($a)}	keys %seq;	#sorting by length
	
	#unless($id){#if not done already give a new id of the organism for the proteins
		print "What abbreviation for for new protein IDs ?:\n";
		$id = <STDIN>;
		chomp $id;
		if ($id eq ""){				#if also STDIN stays empty
			die("No new ID specified!")
		}
	#}
	
	print "Would you like to give any nearer description of the data ? If not press just ENTER:\n";
	$description = <STDIN>;
	chomp $description;
		
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);


	#for formatdb if it is protein sequence
	print "Is it a protein database ? [Y/n]\n";
	$protein = <STDIN>;
	chomp $protein;
	
	if($protein eq "n" || $protein eq "N" || $protein eq "No" || $protein eq "no"){
		
			$protein = "F";
	
	}
	else{
			$protein = "T";
	}
		

	if($protein eq "T"){
			$ind = "P";
	}
	else{
			$ind = "N"
	}
	
	#Filehandle
	open (ALLOC, ">>$in_dir$in_id\.alloc") or die "Can't open \"$in_dir\/$in_id\.alloc\": $!";	#open alloc file or stop if it doesnt work#this file contains the new and old header
	
	#Filehandle
	open (OUTPUT, ">$in_dir$in_id\.db") or die "Can't open \"$in_dir\/$in_id\.db\": $!";	#open output file or stop if it doesnt work
	
	
	
	
	foreach($k = 0; $k <= $#sort; $k++){
	 
		$header = sprintf("$id%06d",$k+1);
		#$newseq{$header} = $sort[$k];
		if($ind eq "P"){
			#replacev U by X
			$sort[$k]=~tr/Uu/Xx/;
			
			#remove ending '*'
			while(substr($sort[$k],-1,1) eq '*'){
				chop($sort[$k]);
			
			}
		}
		
		print ALLOC "$header\t$description\t$seq{$sort[$k]}\t$newseq\t$ind\t$in_id$in_ext\t$mday\.$mon\.",$year+1900,"\n";#writes the new header, a description, the old header, the filename and the date of database production in one line seperated with tabs
		print OUTPUT ">$header\n$sort[$k]\n";
		#unless($k == $#sort){
		#	print ALLOC "\n";
		#	print OUTPUT "\n";
		#}
	
	
	}
	
	#print $#sort."\n";
	#print "$id";
	close(OUTPUT);
	close(ALLOC);
	
	
#	#formatdb
	#system("formatdb -i $in_dir$in_id\.db -t $in_id -p $protein");

}
else{
	print "Can not find file or folder\n";	
}

