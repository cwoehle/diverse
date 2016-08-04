#Need the *R files to work. Input is an file with each line an identifier and 4 number representing a 2x2 contingency table.
#The script performs one test per line and applies fdr over all tests

if [ -e "$1" ];then
	f=$1
else
	echo Found no specified file. Using fisher_input.txt
	f="fisher_input.txt"
fi

cat $f | perl -nae 'chomp; $e=((($F[1]+$F[2])*($F[1]+$F[3]))/($F[1]+$F[2]+$F[3]+$F[4]));$a=($F[1]/($F[1]+$F[2])); $b=($F[3]/($F[3]+$F[4])); print "$_\t";printf("%2.4f\t%2.4f\t%2.2f\t",$a,$b,$a/$b);printf("%2.2f\t%2.2f\t",$e,$F[1]/$e); system("R CMD BATCH  --no-save --no-restore \"--args oxi=c($F[1],$F[2]) ctl=c($F[3],$F[4])\" fisher.R fisher.temp; cat pval.temp")' > fisher_output.txt
cat fisher_output.txt  | perl -nae 'BEGIN{$c=""};$c.=",$F[10]";END{$c=~s/^\,//; system("R CMD BATCH  --no-save --no-restore \"--args pval=c($c)\" fdr.R fdr.temp")}' 
echo -ne "#Sample\t#A1\t#A2\t#B1\t#B2\t#A1/A\t#B1/B\t#Proportion ((A1/A)/(B1/B))\t#Expected E(A1)\t#A1/E(A1)\t#Fisher-test p-value\t#FDR-corrected p-value\t#Bonferroni-corrected p-value\n"
cat fisher_output.txt | perl -nae 'BEGIN{$i=0;open(FILE,"fdr.out");while(<FILE>){chomp; $fdr[$i]=$_;$i++};close(FILE); $factor=$i;$i=0;}; chomp; print "$_\t$fdr[$i]\t",$F[$#F]*$factor,"\n"; $i++'
