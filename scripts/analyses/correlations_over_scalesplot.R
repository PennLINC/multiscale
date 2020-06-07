correlations_over_scales <- function(correlations,title){
  df<-data.frame(correlations)
  ggplot(df,aes(X1,X2)) + geom_step(col="#262228", size=3)+ylab(expression(rho))+theme_minimal()+theme(axis.text=element_text(size = 15), axis.title = element_text(size=15),panel.grid.minor = element_blank(), plot.title = element_text(size=14)) + xlab("# of Communities") + scale_x_continuous(breaks=seq(2, 30, 4)) + ggtitle(title) +  geom_hline(aes(yintercept=.098), linetype="dashed", col='gold',size=2.5) + geom_hline(aes(yintercept=-.098), linetype="dashed", col='gold',size=2.5) + geom_hline(aes(yintercept=.125), linetype="dashed", col='#007849',size=2.5) + geom_hline(aes(yintercept=-.125), linetype="dashed", col='#007849',size=2.5)+ geom_hline(aes(yintercept=.148), linetype="dashed", col='blue',size=2.5)+ geom_hline(aes(yintercept=-.148), linetype="dashed", col='blue',size=2.5) 
}


