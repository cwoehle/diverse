#!/usr/bin/perl
#script to extract positional information of a vcf-file and the correpsong gff-file.
#Uses information of gff- and fasta-file tp determine overlapping features and predict influence on amino acid coding
#Columns will be added to the end of vcf-files. First is general ";"-seperated list of genomic feature types followed by a column with more specific ids of genomic features
#The last columns shows alteration of CDS, if available

#Regarding amino acid coding
#One amino acid means that the sequence is not altered, otherwise the changes is determine by "reference -> sample".
#Dots indicate for leftover (Can not form a 3-triplet) nucleotides that may violate the frameshift of sequence.
# Terminal variants (indicated by "|" at start or end) were not conidered as leading to frameshifts.Instead the shortest fragment with complete triplets
#and including all positions of this variant were considered starting.
#Pseudogenes are highlighted by the term "(pseudo)" right after the "CDS" feature name.


use strict;
use warnings;

#subroutine now inlcuded in script
#use translate;

my $outtype=1; #alternative output format ( 1 or 2)

my $vcf=$ARGV[0];
if(!$ARGV[0]){
        print STDERR "You have to give a VCF-file!!!\n";
	print STDERR 'Usage: '.$0.' file.vcf [file.gff] [file.fa]'."\n";
	exit;
}

#In case of judith vcf txt file convert to vcf.
if($ARGV[0]=~m/\.txt$/){
	print STDERR "Converting Judith's txt-file $ARGV[0] to vcf $ARGV[0].vcf\n";
	open(IN,$ARGV[0]);	
	open(OUT,">".$ARGV[0].".vcf");
		while(<IN>){
			chomp;
			my @a=();
			@a=split(/\t/,$_);
			for(my $i=1;$i<=7;$i++){print OUT "$a[$i]\t"}; print OUT "$a[8];Sample=$a[0]\n";
		}

	close(IN);close(OUT);
	$vcf=$ARGV[0].".vcf";
}


my $gff="/home/judith/experimental_evolution_sequencing/reference/NC_000913_3_art3.gff";
if($ARGV[1]){
	$gff=$ARGV[1];
}

my $fasta="/home/judith/experimental_evolution_sequencing/reference/index/MG1655_V3_art3_pLC_contig.fa";
if($ARGV[2]){
        $fasta=$ARGV[2];
}
print STDERR "$0\t Mapping of variants to genomic features\n";
print STDERR "Using following files:\nVCF: $vcf\nGFF: $gff\nFASTA: $fasta\n\n";



my $q;
my %seq;
open(FILE,$fasta);
	while(<FILE>){
		chomp;
		if(/^>([^\s]*).*$/){
			$q=$1;
		}else{
			$seq{$q}.=$_;
		}
	};
close(FILE);

my %h; my %y;my %cds; my %chrom; my %pos;my %sample; my $pseudo; my %semi;
open(FILE,'bedtools intersect -a '.$vcf.' -b '.$gff.' -loj |');
        while(<FILE>){
#		print "$_";
           #     chomp;
		$pseudo=0;
		my @col=();
		@col=split(/\t+/,$_);

		my $c="";
		for(my $i=0;$i<=7;$i++){
			$c.="$col[$i]\t"
		};
		$chrom{$c}=$col[0];
		$pos{$c}=$col[1];
		my @d=();
		@d=split("\;",$col[7]);
		$d[$#d]=~s/Sample\=//;
		$sample{$c}=$d[$#d];

		unless($h{$c}){
			$semi{$c}="";
		}else{
			$semi{$c}=";";
		}
		

		if($col[8] eq "."){
			$h{$c}="-";
			$y{$c}="-"
		}else{
			
			my @a=();
			@a=split(/\;/,$col[16]);
			my $ind=0;

			foreach(@a){
				if($_=~m/Name\=(.*)$/){
					$y{$c}.=$semi{$c}."$1";
					$ind=1
				}
				if($_ eq "pseudo\=true"){
					$pseudo=1
				}
			};
			
			if($pseudo){
				$h{$c}.=$semi{$c}."$col[10](pseudo)";
				
			}else{
				$h{$c}.=$semi{$c}."$col[10]";
			}

			unless($ind){
				foreach(@a){
					if($_=~m/locus_tag\=(.*)$/){
						$y{$c}.=$semi{$c}."$1";
						$ind=1
					}
				}
			};
			unless($ind){
				foreach(@a){
					if($_=~m/Note\=(.*)$/){
						$y{$c}.=$semi{$c}."$1";
						$ind=1
					}
				}
			};

			unless($ind){
				$y{$c}.=$semi{$c}."-";
			}
		}



		
		if($col[10] eq "CDS"){
			if($col[3]!~m/^[ATGCatgc]+$/ || $col[4]!~m/^[ATGCatgc]+$/){
				die "Strange reference/alternative allele character in \"$_\""
			}
			if($col[14] eq "+"){
				my $start=$col[1]-$col[11];
				my $offset=0;
				while($start%3){
					$start--;
					$offset++
				}
				my $end=($col[1]+length($col[3]))-$col[11];
				while($end%3){
                                        $end++
                                }
				my $sub=substr($seq{$col[0]},$col[11]+$start-1,$end-$start);
				
				my $sub2=$sub;
                                substr($sub2,$offset,length($col[3]))=$col[4];
				
				my $sub0="";my $sub3="";	
				my $begin=0;
				if($start <= 0){
					
					$begin=1;
					$sub0=$sub;
					$sub=substr($seq{$col[0]},$col[11]-1,$end);

					my $i=length($sub2)-3;
					while($i>$offset){
						$i=$i-3
					}
					$sub3=$sub2;
					my $until=substr($seq{$col[0]},0,$col[11]+$start-1);
					$sub2=substr($until.$sub3,$col[11]+$start-1+$i);
				}
				
				my $terminal=0;
				if($end >= ($col[12]-$col[11])){
					$terminal=1;
					$sub0=$sub;
					$sub=substr($seq{$col[0]},$col[11]+$start-1,($col[12]-$col[11])-$start+1);

					my $i=0;
                                        while($i<$offset+length($col[4])){
                                                $i=$i+3
                                        }
					$sub3=$sub2;
					my $from=substr($seq{$col[0]},$col[11]+$end-1,length($seq{$col[0]})-$col[11]+$end-1);
					$sub2=substr($sub3.$from,0,$i);


				}				

				my $rest="";
                                my $l=length($sub2);
                                while($l%3){
                                                $rest.=".";
                                                $l--;
                                }
				
				my $change=0;
				my $subtrans=$sub;
				my $sub2trans=$sub2.$rest;

#				my $subtrans=translate($sub,"+1");
#				my $sub2trans=translate($sub2,"+1").$rest;
				#if($subtrans ne $sub2trans){
				#	$change=1;
				#}
				$change =1;
				if($terminal){
					$subtrans=$subtrans."\|";
                                }elsif($begin){
					$subtrans="\|".$subtrans;
				}
				
				chomp;
				if($change){
					unless($cds{$c}){
						$cds{$c}.="$subtrans\-\>$sub2trans";					
					}else{
						$cds{$c}.=";$subtrans\-\>$sub2trans";
					}
					#print $_."\t$subtrans \-\> $sub2trans\t$sub \- $sub2\t$sub0 - $sub3\n"
				}
				else{	
					unless($cds{$c}){
						$cds{$c}.="$subtrans";					
					}else{
						$cds{$c}.=";$subtrans";
					}
					#print $_."\t$subtrans\t$sub \- $sub2\t$sub0 - $sub3\n"
				}
				
                                #print translate($sub2,"+1"),"$rest\t$sub2\t$sub3\n";
				#print "Region: $start\t$end\n";				
	
				#my $gene=substr($seq{$col[0]},$col[11]-1,$col[12]-$col[11]+1);
				#print " " x ($start),$sub;
                                #$sub=substr($gene,0,$end);
                                #print "\n".$sub."\n";
                                #print "\n",$gene,"\n";
				#print "\n",substr($seq{$col[0]},$col[11]-1-3,$col[12]-$col[11]+1+6),"\n";
			}else{
				my $end=$col[12]-$col[1]+1;
                                my $offset=0;
				while($end%3){
                                        $end++
                                }
                                my $start=$col[12]-($col[1]+length($col[3]))+1;
                                while($start%3){
                                        $start--;
					$offset++;
                                }

				my $sub=substr($seq{$col[0]},$col[12]-$end,$end-$start);
				$sub=reverse($sub);$sub=~tr/ATGCatgc/tacgtacg/;
				
				my $alt=$col[4];
				$alt=reverse($alt);$alt=~tr/ATGCatgc/tacgtacg/;

				my $sub2=$sub;
				substr($sub2,$offset,length($col[3]))=$alt;

				 my $sub0="";my $sub3=""; 

                            	my $begin=0;
				if($start <= 0){
					
					$begin=1;
					$sub0=$sub;
					$sub=substr($seq{$col[0]},$col[12]-$end,$end);
					$sub=reverse($sub);$sub=~tr/ATGCatgc/tacgtacg/;

					my $i=length($sub2)-3;
					while($i>$offset){
						$i=$i-3
					}
					$sub3=$sub2;

					my $from=substr($seq{$col[0]},$col[12]-$start,length($seq{$col[0]})-($col[12]-$start));
					$from=reverse($from);$from=~tr/ATGCatgc/tacgtacg/;
					$sub2=substr($from.$sub3,(length($seq{$col[0]})-$col[12])+$start+$i);

				}

				my $terminal=0;
				if($end >= ($col[12]-$col[11])){
					$terminal=1;
					$sub0=$sub;
					$sub=substr($seq{$col[0]},$col[11]-1,$col[12]-$col[11]-$start+1);
					$sub=reverse($sub);$sub=~tr/ATGCatgc/tacgtacg/;

					my $i=0;
                                        while($i<$offset+length($alt)){
                                                $i=$i+3
                                        }
					$sub3=$sub2;
					
					my $until=substr($seq{$col[0]},0,$col[11]+(($col[12]-$col[11])-$end));
					$until=reverse($until);$until=~tr/ATGCatgc/tacgtacg/;
					$sub2=substr($sub3.$until,0,$i);


				}




				my $rest="";
                                my $l=length($sub2);
                                while($l%3){
                                                $rest.=".";
                                                $l--;
                                }
				
				my $change=0;
                                
				my $subtrans=$sub;
                                my $sub2trans=$sub2.$rest;

#                               my $subtrans=translate($sub,"+1");
#                               my $sub2trans=translate($sub2,"+1").$rest;
                                #if($subtrans ne $sub2trans){
                                #       $change=1;
                                #}
                                $change =1;

                                if($terminal){
                                        $subtrans=$subtrans."\|";
                                }elsif($begin){
                                        $subtrans="\|".$subtrans;
                                }

				chomp;
				if($change){
					unless($cds{$c}){
						$cds{$c}.="$subtrans\-\>$sub2trans";					
					}else{
						$cds{$c}.=";$subtrans\-\>$sub2trans";
					}
					#print $_."\t$subtrans \-\> $sub2trans\t$sub \- $sub2\t$sub0 - $sub3\n"
				}
				else{	
					unless($cds{$c}){
						$cds{$c}.="$subtrans";					
					}else{
						$cds{$c}.=";$subtrans";
					}
					#print $_."\t$subtrans\t$sub \- $sub2\t$sub0 - $sub3\n"
				}				
	
                              # print translate($sub2,"+1"),"$rest\t$sub2\t$sub3\n";
				#print "Region: $start\t$end\n";
        			
				#my $gene=substr($seq{$col[0]},$col[11]-1,$col[12]-$col[11]+1);
				#$gene=reverse($gene);
				#$gene=~tr/ATGCatgc/tacgtacg/;
                                #print " " x ($start),$sub;
                                #$sub=substr($gene,0,$end);
                                #print "\n".$sub."\n";
                            	#print "\n",$gene,"\n";
				#my $gene2=substr($seq{$col[0]},$col[11]-1-3,$col[12]-$col[11]+1+6);$gene2=reverse($gene2);$gene2=~tr/ATGCatgc/tacgtacg/;
				#print "\n",$gene2,"\n";
			}
		}
	}
close(FILE);

#alternative output format
my @sort=();
@sort=sort { $chrom{$b} cmp $chrom{$a} or $pos{$a} <=> $pos{$b} or $sample{$a} cmp $sample{$b} or $a cmp $b} keys %h;
		
		if($outtype==1){
			print "\#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFEATURE_TYPES\tFEATURE_NAMES\tAA_CODING\n";
			foreach(@sort){
				if($cds{$_}){
					print "$_\t$h{$_}\t$y{$_}\t$cds{$_}\n"
				}else{
					print "$_\t$h{$_}\t$y{$_}\t-\n"
				}
			}
		}
		elsif($outtype==2){
			my @order=();
			my %tail;
			my %cond;
			my %prop;
			my $c;
			my %count;
			my $min=0;
			my %minprop;
			foreach(@sort){
				my @a=(); 
				@a=split(/[\t\;]+/,$_);
				$c="$a[0]\t$a[1]\t$a[3]\t$a[4]";
				$a[$#a]=~s/Sample\=//;
				$a[8]=~s/AF\=//;
				unless($tail{$c}){
					if($cds{$_}){
						$tail{$c}="$h{$_}\t$y{$_}\t$cds{$_}"
					}else{
						$tail{$c}="$h{$_}\t$y{$_}\t-"
					}
					$prop{$c}=$a[8];
					if($a[8]>=$min){
						$minprop{$c}=1;
					}
					$cond{$c}=$a[$#a];
					$count{$c}=1;
					push(@order,$c);
				}else{
					$prop{$c}.=";".$a[8];
					if($a[8]>=$min){
						$minprop{$c}=1;
					}
					$cond{$c}.=";".$a[$#a];
					$count{$c}++;
				}


			}
			print "\#CHROM\tPOS\tREF\tALT\tSAMPLE_COUNT\tSAMPLE\tAF\tFEATURE_TYPE\tFEATURE_NAME\tAA_CODING\n";
			foreach(@order){
				if($minprop{$_}){
					print "$_\t$count{$_}\t$cond{$_}\t$prop{$_}\t$tail{$_}\n";
				}
			}
		}


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
