correlations_over_scales <- function(correlations,title){
  df<-data.frame(correlations)
  ggplot(df,aes(X1,X2)) + geom_line(col="#262228", size=1.2)+ylab(expression(rho))+theme_minimal()+theme(axis.text=element_text(size = 15), axis.title = element_text(size=15),panel.grid.minor = element_blank(), plot.title = element_text(size=14)) + xlab("# of Communities") + scale_x_continuous(breaks=seq(3, 27, 4)) + ggtitle(title) +  geom_hline(aes(yintercept=.098), linetype="dashed", col='#007849',size=1.3) + geom_hline(aes(yintercept=-.098), linetype="dashed", col='#007849',size=1.3) 
}


