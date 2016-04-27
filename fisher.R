#fisher R module for fisher.sh


args=(commandArgs(TRUE))
  for(i in 1:length(args)){
      eval(parse(text=args[[i]]));
    }



data=cbind(oxi,ctl);
data


res=fisher.test(data)
res

pval=res$p.val
pval

write.table(pval, file = "pval.temp", append = FALSE, quote = FALSE, sep = " ",
eol = "\n", na = "NA", dec = ".", row.names = FALSE,
col.names = FALSE, qmethod = c("escape", "double"),
fileEncoding = "")
