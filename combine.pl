#!/usr/bin/perl -w
use strict;

#combine two files with specifid columns with the same values

#Use tab as seperator;
my $sep="\t";

my $i=0;
my $filea=0;
my $fileb=0;
my $cola=0;
my $colb=0;
my $onlya=0;
my $onlyb=0;
my %comba;
my %combb;

for($i=0;$i<=$#ARGV;$i++){
    #print $ARGV[$i]."\n";
    if($ARGV[$i]=~m/\./ && !$filea){
        $filea=$ARGV[$i];
    }
    elsif($ARGV[$i]=~m/\./ && $filea){
        $fileb=$ARGV[$i];
    }
    elsif(lc($ARGV[$i])=~m/^[\-]*a$/){
        $onlya=1
    }
    elsif(lc($ARGV[$i])=~m/^[\-]*b$/){
         $onlyb=1
    }
    elsif(!$cola){
        $cola=$ARGV[$i];
    }
    elsif(!$colb){
        $colb=$ARGV[$i];
    }
    else{
        die "Unknown problem with commandline arguments"
        
    }
    

}

    if(!$filea || !$fileb){
        die "At least one filename was missing. (Do all of them contain \"\.\"\?)"
    }


    
    if($onlya && $onlyb){
        die "The \"Only\" option is only valid for EITHER the one OR the other file. Input contains both options"
        
    }
    
    if(!$cola || !$colb){
        print STDERR  "At least for one file columns specification is missing. Using column 1 for bith\n";
        $cola=1;
        $colb=1;
        
    }
    
    
    print STDERR  "File A: $filea\tcolumn\(s\): $cola\n";
    print STDERR  "File B: $fileb\tcolumn\(s\): $colb\n";

if($onlya){
    print STDERR  "Output data only in file A\n"
    
}
elsif($onlyb){
    print STDERR  "Output data only in file B\n"
}else{
    print STDERR  "Output data shared between file A and B\n"
    
}



my @colsa=split(/[\;\s\,]+/,$cola);
my @colsb=split(/[\;\s\,]+/,$colb);

if($#colsa!=$#colsb){
    die "Number of specified columns differs between file A and B."
    
}


open(FILE,"$filea") || die "Cannot open file $filea";
while(<FILE>){
    chomp;
    if($_ ne ""){
    my @a=();@a=split(/$sep/,$_);
    my $c="";

	

    foreach(@colsa){
        if(($_-1)>$#a){
            die "Specified column $_ exceed number of columns in $filea\: ",$#a+1
        }
        $c.=" $a[($_-1)]"
    }
    
    unless($comba{$c}){
        $comba{$c}=$_;
    }else{
        print STDERR "WARNING: Found multiple identical cases in specified columns: $c\n"
    }
    }
   
    
}
close(FILE);



open(FILE,"$fileb") || die "Cannot open file $fileb";
while(<FILE>){
    chomp;
    if($_ ne ""){
    my @a=();@a=split(/$sep/,$_);
    my $c="";
    
    foreach(@colsb){
        if(($_-1)>$#a){
            die "Specified column $_ exceed number of columns in $filea\: ",$#a+1
        }
        $c.=" $a[($_-1)]"
    }
    
    unless($combb{$c}){
        $combb{$c}=$_;
    }else{
        print STDERR "WARNING: Found multiple identical cases in specified columns: $c\n"
    }
    }
    
}
close(FILE);


if(!$onlyb){
    
    foreach(keys %comba){
        if($onlya && !$combb{$_}){
		print 	$comba{$_}."\n";
	
	}
	
	
	if(!$onlya && $combb{$_}){
		
		print 	$comba{$_}.$sep.$combb{$_}."\n";
        
        }
        
    }
    
    
}

if($onlyb){
	foreach(keys %combb){
        	if(!$comba{$_}){
			print 	$combb{$_}."\n";
	
		}


	}

}

