correlations_over_scales <- function(correlations,title){
  df<-data.frame(correlations)
  ggplot(df,aes(X1,X2)) + geom_step(size=3)+ylab(expression(rho))+
    theme_minimal(base_size = 35)+
    theme(axis.text=element_text(), axis.title = element_text(),panel.grid.minor = element_blank(), plot.title = element_text())+
    xlab("# of Communities") + scale_x_continuous(breaks=seq(2, 30, 4)) +
    ggtitle(title)+
    geom_hline(aes(yintercept=.098), linetype="dashed", col='#ECB602',size=2.5) +
    geom_hline(aes(yintercept=-.098), linetype="dashed", col='#ECB602',size=2.5)+ylim(c(-.35,.35))
}


