#!/usr/bin/perl -w
use strict;

#subroutine for translation
#this algorithm translates just complete triplets, smaller overhangs are removed. "N"s lead to "X" aminoacids except if they are the third wobble nucleotide in a triplet.
##############
sub translate {
	
	my %codon;	
	$codon{"AGG"} = "R"; $codon{"AGA"} = "R"; $codon{"CGN"} = "R"; $codon{"CGA"} = "R"; $codon{"CGG"} = "R"; $codon{"CGC"} = "R"; $codon{"CGT"} = "R"; #Arginin
	$codon{"AGC"} = "S"; $codon{"AGT"} = "S"; $codon{"TCN"} = "S"; $codon{"TCA"} = "S"; $codon{"TCC"} = "S"; $codon{"TCG"} = "S"; $codon{"TCT"} = "S"; #Serin
	$codon{"AAG"} = "K"; $codon{"AAA"} = "K";													   #Lysin
	$codon{"AAC"} = "N"; $codon{"AAT"} = "N";													   #Asparagin
	$codon{"ACN"} = "T"; $codon{"ACA"} = "T"; $codon{"ACG"} = "T"; $codon{"ACC"} = "T"; $codon{"ACT"} = "T";					   #Threonin
	$codon{"ATG"} = "M";																   #Methionin (Start)
	$codon{"ATA"} = "I"; $codon{"ATC"} = "I"; $codon{"ATT"} = "I";											   #Isoleucin
	$codon{"CAA"} = "Q"; $codon{"CAG"} = "Q";													   #Glutamin
	$codon{"CAC"} = "H"; $codon{"CAT"} = "H";													   #Histidin
	$codon{"CCN"} = "P"; $codon{"CCA"} = "P"; $codon{"CCC"} = "P"; $codon{"CCG"} = "P"; $codon{"CCT"} = "P";					   #Prolin
	$codon{"CTN"} = "L"; $codon{"CTA"} = "L"; $codon{"CTC"} = "L"; $codon{"CTG"} = "L"; $codon{"CTT"} = "L"; $codon{"TTA"} = "L"; $codon{"TTG"} = "L"; #Leucin
	$codon{"TGG"} = "W";																   #Tryptophan
	$codon{"TGA"} = '*'; $codon{"TAG"} = '*'; $codon{"TAA"} = '*';											   #Stop
	$codon{"TGC"} = "C"; $codon{"TGT"} = "C";													   #Cystein
	$codon{"TAC"} = "Y"; $codon{"TAT"} = "Y";													   #Tyrosin
	$codon{"TTC"} = "F"; $codon{"TTT"} = "F";													   #Phenylalanin
	$codon{"GGN"} = "G"; $codon{"GGA"} = "G"; $codon{"GGC"} = "G"; $codon{"GGG"} = "G"; $codon{"GGT"} = "G";					   #Glycin
	$codon{"GAA"} = "E"; $codon{"GAG"} = "E";													   #Glutaminsaeure
	$codon{"GAT"} = "D"; $codon{"GAC"} = "D";													   #Asparaginsaeure
	$codon{"GCN"} = "A"; $codon{"GCA"} = "A"; $codon{"GCC"} = "A"; $codon{"GCG"} = "A"; $codon{"GCT"} = "A";					   #Alanin
	$codon{"GTN"} = "V"; $codon{"GTA"} = "V"; $codon{"GTC"} = "V"; $codon{"GTG"} = "V"; $codon{"GTT"} = "V";					   #Valin
	
	#idea of specific code
	#my $code;
	#if($_[2]){
	#}
	
	my $reading_frame = $_[1];	#the reading frame to be translated to
	my @splitframe = ();

	@splitframe = split(//, $reading_frame);
	
	###different start position n different frames
	my $start;
	if($splitframe[1] == 1){
		$start = 0;
	}
	elsif($splitframe[1] == 2){
		$start = 1;
	}
	elsif($splitframe[1] == 3){
		$start = 2;
	}
	else{
		die "Unknown reading frame\n";
	}
	
	#getting sequnce as upper case and substitute eventual Us by Ts
	my $sequence = uc($_[0]);#just upper case
	$sequence =~ tr/U/T/;		#if there ar "U" use them as "Ts"
	
	#if frame is minus get reciprocal sequence
	if($splitframe[0] eq "-"){
		$sequence = reverse($sequence);
		$sequence =~ tr/ACGTN/TGCAN/;
	}
	
	#getting peptide in triplets
	my $peptide = "";
	my $substr;
	while($start <= length($sequence)-3){
		$substr = substr($sequence,$start,3);
		if($codon{$substr}){
			$peptide .= $codon{$substr};
		}
		else{
			$peptide .= "X";
		}
		$start += 3;
	}
	
	return $peptide;
		
}

1;
