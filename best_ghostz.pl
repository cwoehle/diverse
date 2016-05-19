#!/usr/bin/perl -w

##Script to get the coverage of a reference from assembled RNAseq coverage

use strict;



#Check transcriptome assembly quality based in a ghostz results and den corresponding fasta file
#like ghostz aln -b 100 -q "d" -i $i/Bridger.fasta -t "p" -d Reticulomyxa_filosa/Reti_AA -o $i/Bridger_Reti.z

#my %alen1;
my $s; my $e; my @d;
my $query; my $subject;my $len;my %slen;my %repr;
my %qlen; my %hit; my %id; my %alen; my %eval;
my %qleng; my %hitg; my %idg; my %aleng; my %evalg;
my %qlens; my %hits; my %ids; my %alens; my %evals;
my %range; my %range_pre;
my $mine=1e-10;
my $reti="$ARGV[1]";
#my $reti='Reticulomyxa_filosa/GCA_000512085.1_Reti_assembly1.0_protein.faa';
#my $reti='../swissprot/uniprot_sprot.fasta';

open(FILE,"$reti");
while(<FILE>){
        chomp;
        if(/^>/){
                my @a=();
                @a=split(/[\>\s]/,$_);
                $subject=$a[1];
        }else{
                #print "$subject\t",length($_),"\n";
		$slen{$subject}+=length($_);
        }


}
close(FILE);


open(FILE,"$ARGV[0]");

while(<FILE>){
chomp;
my @a=();
@a=split(/\t/,$_);

if($a[10]<=$mine){
#print "$a[0]\t$a[1]\t$a[2]\t$a[3]\t$a[10]\n";
my @b=();
@b=split(/[\s\=]+/,$a[0]);
$query=$b[0];
$len=$b[2];


#if($a[6]<$a[7]){
#	push(@{$range{$query}},"$a[6] $a[7]");
#}
#else{
#	push(@{$range{$query}},"$a[7] $a[6]");
#}

@b=();
@b=split(/[\s\=]+/,$a[1]);
$subject=$b[0];

if($a[6]<$a[7]){
   $s=$a[6]; $e=$a[7];
}
else{
   $s=$a[7]; $e=$a[6];
}


unless($range_pre{$query}{$subject}){
        $range_pre{$query}{$subject}="$s $e";
}
else{
	@d=();
	@d=split(/\s/,$range_pre{$query}{$subject});
	if($s>$d[0]){
		$s=$d[0]
	}
	if($e<$d[1]){
		$e=$d[1]
	}
	$range_pre{$query}{$subject}="$s $e";
}



unless($hit{$query}){
   $hit{$query}=$subject;
   $id{$query." ".$subject}=$a[2];
   $alen{$query." ".$subject}=abs($a[9]-$a[8])+1;
#	$alen{$query." ".$subject}=$a[3];
   $eval{$query." ".$subject}=$a[10];
	$qlen{$query}=$len;
#eprint $query."\t".$qlen{$query}."\t".$hit{$query}."\t".$id{$query." ".$hit{$query}}."\t".$alen{$query." ".$hit{$query}}."\t".$eval{$query." ".$hit{$query}}."\n";

}
elsif($eval{$query." ".$hit{$query}}>$a[10]){
   die "What happened\n?";
   $qlen{$query}=$len;   
   $hit{$query}=$subject;
   $id{$query." ".$subject}=$a[2];
   $alen{$query." ".$subject}=abs($a[9]-$a[8])+1;
   $eval{$query." ".$subject}=$a[10];
}

my $q2=$query;
$query=~s/\_i[0-9]+$//;
$query=~s/\_seq[0-9]+$//;

unless($hitg{$query}){
   $repr{$query}=$q2;
   $hitg{$query}=$subject;
   $idg{$query." ".$subject}=$a[2];
   $aleng{$query." ".$subject}=abs($a[9]-$a[8])+1;
   $evalg{$query." ".$subject}=$a[10];
	 $qleng{$query}=$len;

#print $query."\t".$qleng{$query}."\t".$hitg{$query}."\t".$idg{$query." ".$hitg{$query}}."\t".$aleng{$query." ".$hitg{$query}}."\t".$evalg{$query." ".$hitg{$query}}."\n";

}
elsif($evalg{$query." ".$hitg{$query}}>$a[10]){
#   print  "What happened\t".$evalg{$query." ".$hitg{$query}}."\tvs\t".$a[10]."\n?";
   $repr{$query}=$q2;
   $hitg{$query}=$subject;
   $idg{$query." ".$subject}=$a[2];
   $aleng{$query." ".$subject}=abs($a[9]-$a[8])+1;
   $evalg{$query." ".$subject}=$a[10];
	$qleng{$query}=$len;
}




}
}
close(FILE);

#$range{"a"}[0]="1 10";
#$range{"a"}[1]="0 10";
#$range{"a"}[2]="11 13";
#$range{"a"}[3]="12 14";
#$range{"a"}[4]="15 18";
#$range{"a"}[5]="200 210";
#$range{"a"}[6]="188 201";
#$range{"a"}[7]="5 18";

foreach my $f(keys %range_pre){
	foreach my $g(keys %{$range_pre{$f}}){
		push(@{$range{$f}},$range_pre{$f}{$g});

	}



}


#push(@{$range{$query}},"$a[6] $a[7]");


foreach my $n (keys %range){
	my $i=0;
	my $j=1;
	my $c=0;
	my $end=0;
	my $countdown=0;
	while($end==0){
		#foreach(@{$range{$n}}){
		#	print $_."\n"
		
		#}
		if($j>$#{$range{$n}}){
			$i++;
			$j=$i+1;
		if($i>$#{$range{$n}} || $j> $#{$range{$n}}){
				
			if($#{$range{$n}}==0){
					$end=1;
					last;
			}elsif($countdown>=5){
					$end=1;
					last;
			}else{
					$countdown++;
					$i=0;
					$j=1;	
				}
			}
		}
		
		
		#print "$i $j\n";
		my @a=();my @b=();
		@a=split(/\s/,$range{$n}[$i]);
		@b=split(/\s/,$range{$n}[$j]);
		if($a[0]<=$b[1] && $a[0]>=$b[0]){
			$a[0]=$b[0];
			$c=1;
		}
		if($a[1]<=$b[1] && $a[1]>=$b[0]){
			$a[1]=$b[1];
			$c=1;
		}
		if($a[1]>=$b[1] && $a[0]<=$b[0]){
			$c=1;
		}
		
		
		
		if($c){
			$range{$n}[$i]="$a[0] $a[1]";
			splice(@{$range{$n}},$j,1);
			$c=0;
			$countdown=0;
		}
		else{
			#$countdown++;
			$j++
		}
		
		if($#{$range{$n}}==0){
					$end=1;
		}
		
		
	}
}


my $ranger=0;

foreach my $n (keys %range){
       #$ranger+=@{$range{$n}};
       
       if(@{$range{$n}}>1){
       $ranger++;
       #	print $n,"\t";
       foreach(@{$range{$n}}){
       	#print "\t$_"
       
       }
      # print "\n"
       }

}

my $rangerr=0;
foreach my $n (keys %repr){
	if(@{$range{$repr{$n}}}>1){
#		print $repr{$n}."\n";
		 $rangerr++;
}
}


my $cut=.8;
my $total=0;
my $cutoff=0;
my %total_cand;
my %cutoff_cand;
my $total_count=0;
my $cutoff_count=0;

foreach my $q (keys %hit){
	$total++;
	unless($total_cand{$hit{$q}}){
                        $total_cand{$hit{$q}}=1;
                        $total_count++;
        }
	if($alen{$q." ".$hit{$q}}/$slen{$hit{$q}}>=$cut){
	#	print "$q\t$hit{$q}\t",$alen{$q." ".$hit{$q}},"\t",$alen1{$q." ".$hit{$q}},"\n";
		$cutoff++;
		unless($cutoff_cand{$hit{$q}}){
			$cutoff_cand{$hit{$q}}=1;
			$cutoff_count++;
		}
	}	
	

}

my $total_red=sprintf("%2.1f",$total/$total_count);
my $cutoff_red=sprintf("%2.1f",$cutoff/$cutoff_count);

#print "$total_count\t$total_red\t$cutoff_count\t$cutoff_red\n";


my $totalg=0;
my $cutoffg=0;
my %total_candg;
my %cutoff_candg;
my $total_countg=0;
my $cutoff_countg=0;


foreach my $q (keys %hitg){
	$totalg++;
	unless($total_candg{$hitg{$q}}){
                        $total_candg{$hitg{$q}}=1;
                        $total_countg++;
        }
	if($aleng{$q." ".$hitg{$q}}/$slen{$hitg{$q}}>=$cut){
	#	print "$q\t$hit{$q}\t",$alen{$q." ".$hit{$q}},"\t",$alen1{$q." ".$hit{$q}},"\n";
		$cutoffg++;
		unless($cutoff_candg{$hitg{$q}}){
			$cutoff_candg{$hitg{$q}}=1;
			$cutoff_countg++;
		}
	}	
	

}

my $total_redg=sprintf("%2.1f",$totalg/$total_countg);
my $cutoff_redg=sprintf("%2.1f",$cutoffg/$cutoff_countg);


print "\#Contigs with hits (evalue: $mine)\#Best hits covered genes\t\#Total redundancy\t\#",$cut*100,"\% coverage best hits\t\#Coverage cutoff redundancy\t\#\% potential chimeras\t(Values are for genes. Differences for transcripts are indicated in brackets)\n";
print "$totalg(",$total,")\t$total_countg(\+",abs($total_countg-$total_count),")\t$total_redg(",$total_red,")\t$cutoff_countg(\+",abs($cutoff_countg-$cutoff_count),")\t$cutoff_redg(",$cutoff_red,")\t",sprintf("%2.2f",($rangerr/$totalg)*100),"\%(",sprintf("%2.2f",($ranger/$total)*100),"\%)\n";

#old?
#8100	3.9	2010	2.6
#8040	2.7	1983	1.5
