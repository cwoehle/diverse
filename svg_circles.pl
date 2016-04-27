#!/usr/bin/perl -w

#Presence absence pattern with circles. Negative values get open circles. Positive close one


use strict;

my @matrix;
my @input;
my $i=0;
my $j=0;
my $k=0;
open(FILE,"$ARGV[0]") || die "Problem with input file: $ARGV[0]";
while(<FILE>){
      # chomp;
       @{$input[$i]}=split(/\t/,$_);
       chomp($input[$i][$#{$input[$i]}]);
	$i++;


}
close(FILE);


my $headline=0;
for($i=0;$i<=$#{$input[0]};$i++){
	if($input[0][$i]=~m/[A-z\-\_\;\:]/){
	
		$headline=1;
	
	};

}

my $length=@{$input[0]};
my $headcolumn=0;
for($i=0;$i<=$#input;$i++){
	if($input[$i][0]=~m/[A-z\-\_\;\:]/){
	
		$headcolumn=1;
		if($length != @{$input[$i]}){
			die "Line lengths differ!$length and ",scalar @{$input[$i]}		
		}

	
	};

}

#remove headline and column
if($headline){
	shift(@input)
}
if($headcolumn){
	for($i=0;$i<=$#input;$i++){
		shift(@{$input[$i]});
	}
}


#load colormap is there is one defined
my @colormap;
my $col=0;
if($ARGV[1]){
	$i=0;
	$col=1;
	open(FILE,"$ARGV[1]") || die "Problem with input file: $ARGV[1]";
	while(<FILE>){
    	chomp;
       	@{$colormap[$i]}=split(/\t/,$_);
	$i++;


	}
	close(FILE);
}


#get max and min values
my $max;
my $min;
$max=$input[0][0];
$min=$input[0][0];
for($i=0;$i<=$#input;$i++){
	for($j=0;$j<=$#{$input[$i]};$j++){	
		if($input[$i][$j]>$max){
			$max=$input[$i][$j];
		}
			
		if($input[$i][$j]<$min){
			$min=$input[$i][$j];
		}
	}
}

#wenn nicht anders angegeben ist $min=0
$min=0;
my $grenze;
my @colors;
for($i=0;$i<=$#input;$i++){
	for($j=0;$j<=$#{$input[$i]};$j++){	
		
		if($col){
			for($k=0;$k<=$#colormap;$k++){
				$grenze=((($max-$min)/(@colormap))*($k+1))+$min;
					if($input[$i][$j]<=$grenze){
						$colors[$i][$j]='rgb('. int($colormap[$k][0]*255) .', '. int($colormap[$k][1]*255) .', '. int($colormap[$k][2]*255) .')';
						last;
					}
			}
		
		
		}else{
		
			$colors[$i][$j]='rgb(255, 128, 0)';
		
		
		}
		
	}
}



#print "@{$input[4]}\n";




my $sq_size=10;
my $columns=@{$input[0]};
my $lines=@input;
my $size_x=$columns*$sq_size;
my $size_y=$lines*$sq_size;

#print "$size_x\t$size_y\n";
my $desc="SVG Test";

#write file header
print '<!DOCTYPE svg >'."\n";
#print '<svg xmlns="http://www.w3.org/2000/svg" version="1.1">'."\n";
print '<svg viewBox="0 0 ',380," ",490,'" xmlns="http://www.w3.org/2000/svg" version="1.1">'."\n"; 
#print '<svg viewBox="0 0 ',$size_x," ",$size_y,'" xmlns="http://www.w3.org/2000/svg" version="1.1">'."\n";#unterschiedliche Werte ergäben unterschiedliche Größen
print '<desc>'.$desc.'</desc>'."\n";






my $pi="3.14159265358979323846264338327950288419716939937";
my $x=$sq_size;
my $y=$sq_size;

#circle				#specifications of the circles
my $radius=$sq_size/2;
my $circlescale=0.95;
my $emptycirclescale=0.85;
#my $circlecolor="orange";
#my $circlecolor="rgb(255, 128, 0)";#orange
#my $circlecolor="rgb(0, 170, 0)"; #green

#cross specifier			#specification of cross grid
my $crossind=1;
my $crosssizex=1;
my $crosssizey=1;
my $crossstroke=0.2;
my $crosscolor="rgb(1, 1, 1)";

#smallcircle			#specification to show small circles for missing values
my $smallcind=1;
my $smallscale=5;
my $scirclecolor="rgb(200, 200, 200";


my $minusx;
my $minusy;
my $plusx;
my $plusy;
for(my $posy=0; $posy <=$lines; $posy++){
	if($posy==0){
		$plusy=(($sq_size*$crosssizey)/2);
		$minusy=0;
	}
	elsif($posy==$lines){
		$plusy=0;
		$minusy=(($sq_size*$crosssizey)/2);
	}
	else{
		$minusy=$plusy=(($sq_size*$crosssizey)/2);
	}
	
	for(my $posx=0; $posx <=$columns; $posx++){
		if($posx==0){
			$plusx=(($sq_size*$crosssizex)/2);
			$minusx=0;
		}
		elsif($posx==$columns){
			$plusx=0;
			$minusx=(($sq_size*$crosssizex)/2);
		}
		else{

			$minusx=$plusx=(($sq_size*$crosssizex)/2);
	
		}		       
			
		if($crossind){	
			#print '<line x1="',($x*$posx)-$minusx,'" y1="',($y*$posy),'" x2="',($x*$posx)+$plusx,'" y2="',($y*$posy),'" style="stroke:',$crosscolor,';stroke-width:',$crossstroke,'pt;"/>'."\n";
			#print '<line x1="',($x*$posx),'" y1="',($y*$posy)-$minusy,'" x2="',($x*$posx),'" y2="',($y*$posy)+$plusy,'" style="stroke:',$crosscolor,';stroke-width:',$crossstroke,'pt;"/>'."\n";
		}
		#my $radius2=$radius*rand(1);	
		if($posx<$columns && $posy<$lines){
		

			
			if(($input[$posy][$posx]>=0 && $input[$posy][$posx]!~m/[\ \_]+/) && $input[$posy][$posx]>=0){	
				#$circlescale=0.95;
				#if($input[$posy][$posx]==1){
				#	$circlecolor="blue";
				#}
				#elsif($input[$posy][$posx]==2){
				#	$circlecolor="red";
				#}
				#elsif($input[$posy][$posx]==3){
				#	$circlecolor="green";
				#}
				#elsif($input[$posy][$posx]==4){
				#	$circlecolor="grey";
				#}
				#elsif($input[$posy][$posx]==5){
				#	$circlecolor="yellow";
				#}
				#elsif($input[$posy][$posx]==0){
				#	$circlecolor="black";
				#}								
				#else{
				#	$circlecolor="pink";
				#}
							
				#print "$input[$posy][$posx]\n";
				print '<rect x="',($x*$posx),'" y="',($y*$posy),'" width="',($sq_size),'" height="',($sq_size),'" fill="',$colors[$posy][$posx],'" stroke="black" stroke-width="0pt"/>'."\n";
			}
			elsif(($input[$posy][$posx] && $input[$posy][$posx]!~m/[\ \_]+/) && $input[$posy][$posx]<0){
				#$emptycirclescale=0.85;			
				#print '<circle cx="',($x*$posx)+($sq_size/2),'" cy="',($y*$posy)+($sq_size/2),'" r="',$radius*$emptycirclescale,'" fill="transparent" stroke="'.$circlecolor.'" stroke-width="1.5pt"/>'."\n";

			}
			elsif($smallcind){
				#print '<circle cx="',($x*$posx)+($sq_size/2),'" cy="',($y*$posy)+($sq_size/2),'" r="',($radius*$circlescale)/$smallscale,'" fill="',$scirclecolor,'" stroke="blue" stroke-width="0pt"/>'."\n";
		
			}
			

		}
					


	}
}

for(my $posy=0; $posy <=$lines; $posy++){
	if($posy==0){
		$plusy=(($sq_size*$crosssizey)/2);
		$minusy=0;
	}
	elsif($posy==$lines){
		$plusy=0;
		$minusy=(($sq_size*$crosssizey)/2);
	}
	else{
		$minusy=$plusy=(($sq_size*$crosssizey)/2);
	}
	
	for(my $posx=0; $posx <=$columns; $posx++){
		if($posx==0){
			$plusx=(($sq_size*$crosssizex)/2);
			$minusx=0;
		}
		elsif($posx==$columns){
			$plusx=0;
			$minusx=(($sq_size*$crosssizex)/2);
		}
		else{

			$minusx=$plusx=(($sq_size*$crosssizex)/2);
	
		}		       
			
		if($crossind){	
			print '<line x1="',($x*$posx)-$minusx,'" y1="',($y*$posy),'" x2="',($x*$posx)+$plusx,'" y2="',($y*$posy),'" style="stroke:',$crosscolor,';stroke-width:',$crossstroke,'pt;"/>'."\n";
			print '<line x1="',($x*$posx),'" y1="',($y*$posy)-$minusy,'" x2="',($x*$posx),'" y2="',($y*$posy)+$plusy,'" style="stroke:',$crosscolor,';stroke-width:',$crossstroke,'pt;"/>'."\n";
		}
		#my $radius2=$radius*rand(1);	
		if($posx<$columns && $posy<$lines){
		

			
			if(($input[$posy][$posx] && $input[$posy][$posx]!~m/[\ \_]+/) && $input[$posy][$posx]>=0){	
				#$circlescale=0.95;
			
				#print "$input[$posy][$posx]\n";
				#print '<rect x="',($x*$posx),'" y="',($y*$posy),'" width="',($sq_size),'" height="',($sq_size),'" fill="',$circlecolor,'" stroke="black" stroke-width="0pt"/>'."\n";
			}
			elsif(($input[$posy][$posx] && $input[$posy][$posx]!~m/[\ \_]+/) && $input[$posy][$posx]<0){
				#$emptycirclescale=0.85;			
				#print '<circle cx="',($x*$posx)+($sq_size/2),'" cy="',($y*$posy)+($sq_size/2),'" r="',$radius*$emptycirclescale,'" fill="transparent" stroke="'.$circlecolor.'" stroke-width="1.5pt"/>'."\n";

			}
			elsif($smallcind){
				#print '<circle cx="',($x*$posx)+($sq_size/2),'" cy="',($y*$posy)+($sq_size/2),'" r="',($radius*$circlescale)/$smallscale,'" fill="',$scirclecolor,'" stroke="blue" stroke-width="0pt"/>'."\n";
		
			}
			

		}
					


	}
}

print '</svg>'."\n"
