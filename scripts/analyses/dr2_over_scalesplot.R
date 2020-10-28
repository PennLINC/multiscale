dr2_over_scales <- function(correlations,title){
  df<-data.frame(correlations)
  ggplot(df,aes(X1,X2)) + geom_step(size=3)+ylab(expression(paste(Delta,R^2[adj]))) +
    theme_minimal(base_size = 35)+
    theme(axis.text=element_text(), axis.title = element_text(),panel.grid.minor = element_blank(), plot.title = element_text())+
    xlab("# of Communities") + scale_x_continuous(breaks=seq(2, 30, 4)) +
    ggtitle(title)+ylim(c(-.15,.15))
}


