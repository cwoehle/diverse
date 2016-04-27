#fdr R module for fisher.sh



args=(commandArgs(TRUE))
  for(i in 1:length(args)){
      eval(parse(text=args[[i]]));
    }

pval=pval
fdr=p.adjust(pval, method = 'fdr')


write.table(fdr, file = "fdr.out", append = FALSE, quote = FALSE, sep = " ",
eol = "\n", na = "NA", dec = ".", row.names = FALSE,
col.names = FALSE, qmethod = c("escape", "double"),
fileEncoding = "")

