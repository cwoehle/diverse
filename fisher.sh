cat $1 | perl -nae 'chomp; print "$_\t";printf("%2.2f\t",($F[1]/$F[2])/($F[3]/$F[4])); system("R CMD BATCH  --no-save --no-restore \"--args oxi=c($F[1],$F[2]) ctl=c($F[3],$F[4])\" fisher.R fisher.temp; cat pval.temp")' | sort -k6 -n > fisher_output.txt
#cat fisher_output.txt  | perl -nae 'BEGIN{$c=""};$c.=",$F[6]";END{$c=~s/^\,//; system("R CMD BATCH  --no-save --no-restore \"--args pval=c($c)\" fdr.R fdr.temp; cat fdr.out")}'
cat fisher_output.txt | perl -nae 'BEGIN{$i=0;open(FILE,"fdr.out");while(<FILE>){chomp; $fdr[$i]=$_;$i++};close(FILE);$i=0;}; chomp; print "$_\t$fdr[$i]\n"; $i++'
