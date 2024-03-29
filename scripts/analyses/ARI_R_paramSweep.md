Untitled
================
Adam
11/5/2021

``` r
library(ggplot2)
library(forcats)
knitr::opts_chunk$set(warning = FALSE, message = FALSE) 
```

``` r
### K=4

#p5_5 - p is for "point" (.5)
p5_5=read.csv('Y:/results/aggregated_data/BwSubj_p5_5_K4_r.csv')
# convert to matrix
p5_5Mat=data.matrix(p5_5)
# get index of upper triangle
UTI=upper.tri(p5_5Mat)
# index of lower
LTI=lower.tri(p5_5Mat)

#p5_10
p5_10=read.csv('Y:/results/aggregated_data/BwSubj_p5_10_K4_r.csv')
# convert to matrix
p5_10Mat=data.matrix(p5_10)

#p5_20
p5_20=read.csv('Y:/results/aggregated_data/BwSubj_p5_20_K4_r.csv')
# convert to matrix
p5_20Mat=data.matrix(p5_20)

# o is placeholder because starting variables with numbers is not accepted
o1_5=read.csv('Y:/results/aggregated_data/BwSubj_1_5_K4.csv')
# convert to matrix
o1_5Mat=data.matrix(o1_5)

#1_20
o1_20=read.csv('Y:/results/aggregated_data/BwSubj_1_20_K4.csv')
# convert to matrix
o1_20Mat=data.matrix(o1_20)

#2_5
o2_5=read.csv('Y:/results/aggregated_data/BwSubj_2_5_K4.csv')
# convert to matrix
o2_5Mat=data.matrix(o2_5)

#2_10
o2_10=read.csv('Y:/results/aggregated_data/BwSubj_2_10_K4.csv')
# convert to matrix
o2_10Mat=data.matrix(o2_10)

#2_20
o2_20=read.csv('Y:/results/aggregated_data/BwSubj_2_20_K4.csv')
# convert to matrix
o2_20Mat=data.matrix(o2_20)
```

``` r
# extract within-subject values
p5_5win=diag(p5_5Mat)
p5_10win=diag(p5_10Mat)
p5_20win=diag(p5_20Mat)
o1_5win=diag(o1_5Mat)
o1_20win=diag(o1_20Mat)
o2_5win=diag(o2_5Mat)
o2_10win=diag(o2_10Mat)
o2_20win=diag(o2_20Mat)

# extract between-subject values
p5_5bw=c(p5_5Mat[UTI],p5_5Mat[LTI])
p5_10bw=c(p5_10Mat[UTI],p5_10Mat[LTI])
p5_20bw=c(p5_20Mat[UTI],p5_20Mat[LTI])
o1_5bw=c(o1_5Mat[UTI],o1_5Mat[LTI])
o1_20bw=c(o1_20Mat[UTI],o1_20Mat[LTI])
o2_5bw=c(o2_5Mat[UTI],o2_5Mat[LTI])
o2_10bw=c(o2_10Mat[UTI],o2_10Mat[LTI])
o2_20bw=c(o2_20Mat[UTI],o2_20Mat[LTI])


### plot within vs. b/w distributions

# combine all withins, repeat 800 times to match distribution
Wins=data.frame(rep(c(p5_5win,p5_10win,p5_20win,o1_5win,o1_20win,o2_5win,o2_10win,o2_20win),450))

# combine all betweens
Bws=data.frame(c(p5_5bw,p5_5bw,p5_10bw,p5_20bw,o1_5bw,o1_20bw,o2_5bw,o2_10bw,o2_20bw))

colnames(Wins)<-'Frequency'
colnames(Bws)<-'Frequency'

# plot it
options(scipen = 999)
ggplot(Bws,aes(Frequency))+geom_histogram(fill='#7fcdbb')+geom_histogram(data=Wins,aes(Frequency),fill='#2c7fb8')+scale_y_continuous(sec.axis=sec_axis(trans=~.*(1/450)))+theme_classic(base_size=40)+xlab('ARI')+ylab(NULL)+theme(axis.text.y.right = element_text(color="#2c7fb8"),axis.text.y.left = element_text(color="#7fcdbb"))
```

![](ARI_R_paramSweep_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

``` r
###### Sep. Plots - p5_5
windf<-data.frame(rep(c(p5_5win),450))
bwdf<-data.frame(c(p5_5bw))
colnames(windf)<-'Frequency'
colnames(bwdf)<-'Frequency'

ggplot(bwdf,aes(Frequency))+geom_histogram(fill='#7fcdbb')+geom_histogram(data=windf,aes(Frequency),fill='#2c7fb8')+scale_y_continuous(labels=scales::scientific,breaks = c(0,100000,200000,300000),limits = c(0,330000),sec.axis=sec_axis(trans=~.*(1/450)))+theme_classic(base_size=40)+xlab('ARI: Spar = .5, Loc = 5')+ylab(NULL)+theme(axis.text.y.right = element_text(color="#2c7fb8"),axis.text.y.left = element_text(color="#7fcdbb"))+scale_x_continuous(breaks=c(0,.2,.4,.6,.8,1), lim = c(0,1.1))
```

![](ARI_R_paramSweep_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

``` r
### Sep. Plots - p5_10
windf<-data.frame(rep(c(p5_10win),450))
bwdf<-data.frame(c(p5_10bw))
colnames(windf)<-'Frequency'
colnames(bwdf)<-'Frequency'

ggplot(bwdf,aes(Frequency))+geom_histogram(fill='#7fcdbb')+geom_histogram(data=windf,aes(Frequency),fill='#2c7fb8')+scale_y_continuous(labels=scales::scientific,breaks = c(0,100000,200000,300000),limits = c(0,330000),sec.axis=sec_axis(trans=~.*(1/450)))+theme_classic(base_size=40)+xlab('ARI: Spar = .5, Loc = 10')+ylab(NULL)+theme(axis.text.y.right = element_text(color="#2c7fb8"),axis.text.y.left = element_text(color="#7fcdbb"))+scale_x_continuous(breaks=c(0,.2,.4,.6,.8,1), lim = c(0,1.1))
```

![](ARI_R_paramSweep_files/figure-gfm/unnamed-chunk-4-2.png)<!-- -->

``` r
### Sep. Plots - p5_20
windf<-data.frame(rep(c(p5_20win),450))
bwdf<-data.frame(c(p5_20bw))
colnames(windf)<-'Frequency'
colnames(bwdf)<-'Frequency'

ggplot(bwdf,aes(Frequency))+geom_histogram(fill='#7fcdbb')+geom_histogram(data=windf,aes(Frequency),fill='#2c7fb8')+scale_y_continuous(labels=scales::scientific,breaks = c(0,100000,200000,300000),limits = c(0,330000),sec.axis=sec_axis(trans=~.*(1/450)))+theme_classic(base_size=40)+xlab('ARI: Spar = .5, Loc = 20')+ylab(NULL)+theme(axis.text.y.right = element_text(color="#2c7fb8"),axis.text.y.left = element_text(color="#7fcdbb"))+scale_x_continuous(breaks=c(0,.2,.4,.6,.8,1), lim = c(0,1.1))
```

![](ARI_R_paramSweep_files/figure-gfm/unnamed-chunk-4-3.png)<!-- -->

``` r
### Sep. Plots - 1_5
windf<-data.frame(rep(c(o1_5win),450))
bwdf<-data.frame(c(o1_5bw))
colnames(windf)<-'Frequency'
colnames(bwdf)<-'Frequency'

ggplot(bwdf,aes(Frequency))+geom_histogram(fill='#7fcdbb')+geom_histogram(data=windf,aes(Frequency),fill='#2c7fb8')+scale_y_continuous(labels=scales::scientific,breaks = c(0,100000,200000,300000),limits = c(0,330000),sec.axis=sec_axis(trans=~.*(1/450)))+theme_classic(base_size=40)+xlab('ARI: Spar = 1, Loc = 5')+ylab(NULL)+theme(axis.text.y.right = element_text(color="#2c7fb8"),axis.text.y.left = element_text(color="#7fcdbb"))+scale_x_continuous(breaks=c(0,.2,.4,.6,.8,1), lim = c(0,1.1))
```

![](ARI_R_paramSweep_files/figure-gfm/unnamed-chunk-4-4.png)<!-- -->

``` r
### Sep. Plots - 1_20
windf<-data.frame(rep(c(o1_20win),450))
bwdf<-data.frame(c(o1_20bw))
colnames(windf)<-'Frequency'
colnames(bwdf)<-'Frequency'

ggplot(bwdf,aes(Frequency))+geom_histogram(fill='#7fcdbb')+geom_histogram(data=windf,aes(Frequency),fill='#2c7fb8')+scale_y_continuous(labels=scales::scientific,breaks = c(0,100000,200000,300000),limits = c(0,330000),sec.axis=sec_axis(trans=~.*(1/450)))+theme_classic(base_size=40)+xlab('ARI: Spar = 1, Loc = 20')+ylab(NULL)+theme(axis.text.y.right = element_text(color="#2c7fb8"),axis.text.y.left = element_text(color="#7fcdbb"))+scale_x_continuous(breaks=c(0,.2,.4,.6,.8,1), lim = c(0,1.1))
```

![](ARI_R_paramSweep_files/figure-gfm/unnamed-chunk-4-5.png)<!-- -->

``` r
### Sep. Plots - o2_5
windf<-data.frame(rep(c(o2_5win),450))
bwdf<-data.frame(c(o2_5bw))
colnames(windf)<-'Frequency'
colnames(bwdf)<-'Frequency'

ggplot(bwdf,aes(Frequency))+geom_histogram(fill='#7fcdbb')+geom_histogram(data=windf,aes(Frequency),fill='#2c7fb8')+scale_y_continuous(labels=scales::scientific,breaks = c(0,100000,200000,300000),limits = c(0,330000),sec.axis=sec_axis(trans=~.*(1/450)))+theme_classic(base_size=40)+xlab('ARI: Spar = 2, Loc = 5')+ylab(NULL)+theme(axis.text.y.right = element_text(color="#2c7fb8"),axis.text.y.left = element_text(color="#7fcdbb"))+scale_x_continuous(breaks=c(0,.2,.4,.6,.8,1), lim = c(0,1.1))
```

![](ARI_R_paramSweep_files/figure-gfm/unnamed-chunk-4-6.png)<!-- -->

``` r
### Sep. Plots - o2_10
windf<-data.frame(rep(c(o2_10win),450))
bwdf<-data.frame(c(o2_10bw))
colnames(windf)<-'Frequency'
colnames(bwdf)<-'Frequency'

ggplot(bwdf,aes(Frequency))+geom_histogram(fill='#7fcdbb')+geom_histogram(data=windf,aes(Frequency),fill='#2c7fb8')+scale_y_continuous(labels=scales::scientific,breaks = c(0,100000,200000,300000),limits = c(0,330000),sec.axis=sec_axis(trans=~.*(1/450)))+theme_classic(base_size=40)+xlab('ARI: Spar = 2, Loc = 10')+ylab(NULL)+theme(axis.text.y.right = element_text(color="#2c7fb8"),axis.text.y.left = element_text(color="#7fcdbb"))+scale_x_continuous(breaks=c(0,.2,.4,.6,.8,1), lim = c(0,1.1))
```

![](ARI_R_paramSweep_files/figure-gfm/unnamed-chunk-4-7.png)<!-- -->

``` r
### Sep. Plots - 2_20
windf<-data.frame(rep(c(o2_20win),450))
bwdf<-data.frame(c(o2_20bw))
colnames(windf)<-'Frequency'
colnames(bwdf)<-'Frequency'

ggplot(bwdf,aes(Frequency))+geom_histogram(fill='#7fcdbb')+geom_histogram(data=windf,aes(Frequency),fill='#2c7fb8')+scale_y_continuous(labels=scales::scientific,breaks = c(0,100000,200000,300000),limits = c(0,330000),sec.axis=sec_axis(trans=~.*(1/450)))+theme_classic(base_size=40)+xlab('ARI: Spar = 2, Loc = 20')+ylab(NULL)+theme(axis.text.y.right = element_text(color="#2c7fb8"),axis.text.y.left = element_text(color="#7fcdbb"))+scale_x_continuous(breaks=c(0,.2,.4,.6,.8,1), lim = c(0,1.1))
```

![](ARI_R_paramSweep_files/figure-gfm/unnamed-chunk-4-8.png)<!-- -->

``` r
### K=20

#p5_5 - p is for "point" (.5)
p5_5=read.csv('Y:/results/aggregated_data/BwSubj_p5_5_K20_r.csv')
# convert to matrix
p5_5Mat=data.matrix(p5_5)
# get index of upper triangle
UTI=upper.tri(p5_5Mat)
# index of lower
LTI=lower.tri(p5_5Mat)

#p5_10
p5_10=read.csv('Y:/results/aggregated_data/BwSubj_p5_10_K20_r.csv')
# convert to matrix
p5_10Mat=data.matrix(p5_10)

#p5_20
p5_20=read.csv('Y:/results/aggregated_data/BwSubj_p5_20_K20_r.csv')
# convert to matrix
p5_20Mat=data.matrix(p5_20)

# o is placeholder because starting variables with numbers is not accepted
o1_5=read.csv('Y:/results/aggregated_data/BwSubj_1_5_K20.csv')
# convert to matrix
o1_5Mat=data.matrix(o1_5)

#1_20
o1_20=read.csv('Y:/results/aggregated_data/BwSubj_1_20_K20.csv')
# convert to matrix
o1_20Mat=data.matrix(o1_20)

#2_5
o2_5=read.csv('Y:/results/aggregated_data/BwSubj_2_5_K20.csv')
# convert to matrix
o2_5Mat=data.matrix(o2_5)

#2_10
o2_10=read.csv('Y:/results/aggregated_data/BwSubj_2_10_K20.csv')
# convert to matrix
o2_10Mat=data.matrix(o2_10)

#2_20
o2_20=read.csv('Y:/results/aggregated_data/BwSubj_2_20_K20.csv')
# convert to matrix
o2_20Mat=data.matrix(o2_20)
```

``` r
# extract within-subject values
p5_5win=diag(p5_5Mat)
p5_10win=diag(p5_10Mat)
p5_20win=diag(p5_20Mat)
o1_5win=diag(o1_5Mat)
o1_20win=diag(o1_20Mat)
o2_5win=diag(o2_5Mat)
o2_10win=diag(o2_10Mat)
o2_20win=diag(o2_20Mat)

# extract between-subject values
p5_5bw=c(p5_5Mat[UTI],p5_5Mat[LTI])
p5_10bw=c(p5_10Mat[UTI],p5_10Mat[LTI])
p5_20bw=c(p5_20Mat[UTI],p5_20Mat[LTI])
o1_5bw=c(o1_5Mat[UTI],o1_5Mat[LTI])
o1_20bw=c(o1_20Mat[UTI],o1_20Mat[LTI])
o2_5bw=c(o2_5Mat[UTI],o2_5Mat[LTI])
o2_10bw=c(o2_10Mat[UTI],o2_10Mat[LTI])
o2_20bw=c(o2_20Mat[UTI],o2_20Mat[LTI])


### plot within vs. b/w distributions, dual-axis pdf?

# combine all withins, repeat 800 times to match distribution
Wins=data.frame(rep(c(p5_5win,p5_10win,p5_20win,o1_5win,o1_20win,o2_5win,o2_10win,o2_20win),450))

# combine all betweens
Bws=data.frame(c(p5_5bw,p5_5bw,p5_10bw,p5_20bw,o1_5bw,o1_20bw,o2_5bw,o2_10bw,o2_20bw))

colnames(Wins)<-'Frequency'
colnames(Bws)<-'Frequency'

# plot it
ggplot(Bws,aes(Frequency))+geom_histogram(fill='#7fcdbb')+geom_histogram(data=Wins,aes(Frequency),bins=35,fill='#2c7fb8')+scale_y_continuous(labels=scales::scientific,sec.axis=sec_axis(trans=~.*(1/450)))+theme_classic(base_size=40)+xlab('ARI')+ylab(NULL)+theme(axis.text.y.right = element_text(color="#2c7fb8"),axis.text.y.left = element_text(color="#7fcdbb"))
```

![](ARI_R_paramSweep_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

``` r
###### Sep. Plots - p5_5
windf<-data.frame(rep(c(p5_5win),450))
bwdf<-data.frame(c(p5_5bw))
colnames(windf)<-'Frequency'
colnames(bwdf)<-'Frequency'

ggplot(bwdf,aes(Frequency))+geom_histogram(fill='#7fcdbb')+geom_histogram(data=windf,aes(Frequency),fill='#2c7fb8')+scale_y_continuous(labels=scales::scientific,breaks = c(0,100000,200000,300000),limits = c(0,330000),sec.axis=sec_axis(trans=~.*(1/450)))+theme_classic(base_size=40)+xlab('ARI: Spar = .5, Loc = 5')+ylab(NULL)+theme(axis.text.y.right = element_text(color="#2c7fb8"),axis.text.y.left = element_text(color="#7fcdbb"))+scale_x_continuous(breaks=c(0,.2,.4,.6,.8,1), lim = c(0,1.1))
```

![](ARI_R_paramSweep_files/figure-gfm/unnamed-chunk-7-1.png)<!-- -->

``` r
### Sep. Plots - p5_10
windf<-data.frame(rep(c(p5_10win),450))
bwdf<-data.frame(c(p5_10bw))
colnames(windf)<-'Frequency'
colnames(bwdf)<-'Frequency'

ggplot(bwdf,aes(Frequency))+geom_histogram(fill='#7fcdbb')+geom_histogram(data=windf,aes(Frequency),fill='#2c7fb8')+scale_y_continuous(labels=scales::scientific,breaks = c(0,100000,200000,300000),limits = c(0,330000),sec.axis=sec_axis(trans=~.*(1/450)))+theme_classic(base_size=40)+xlab('ARI: Spar = .5, Loc = 10')+ylab(NULL)+theme(axis.text.y.right = element_text(color="#2c7fb8"),axis.text.y.left = element_text(color="#7fcdbb"))+scale_x_continuous(breaks=c(0,.2,.4,.6,.8,1), lim = c(0,1.1))
```

![](ARI_R_paramSweep_files/figure-gfm/unnamed-chunk-7-2.png)<!-- -->

``` r
### Sep. Plots - p5_20
windf<-data.frame(rep(c(p5_20win),450))
bwdf<-data.frame(c(p5_20bw))
colnames(windf)<-'Frequency'
colnames(bwdf)<-'Frequency'

ggplot(bwdf,aes(Frequency))+geom_histogram(fill='#7fcdbb')+geom_histogram(data=windf,aes(Frequency),fill='#2c7fb8')+scale_y_continuous(labels=scales::scientific,breaks = c(0,100000,200000,300000),limits = c(0,330000),sec.axis=sec_axis(trans=~.*(1/450)))+theme_classic(base_size=40)+xlab('ARI: Spar = .5, Loc = 20')+ylab(NULL)+theme(axis.text.y.right = element_text(color="#2c7fb8"),axis.text.y.left = element_text(color="#7fcdbb"))+scale_x_continuous(breaks=c(0,.2,.4,.6,.8,1), lim = c(0,1.1))
```

![](ARI_R_paramSweep_files/figure-gfm/unnamed-chunk-7-3.png)<!-- -->

``` r
### Sep. Plots - 1_5
windf<-data.frame(rep(c(o1_5win),450))
bwdf<-data.frame(c(o1_5bw))
colnames(windf)<-'Frequency'
colnames(bwdf)<-'Frequency'

ggplot(bwdf,aes(Frequency))+geom_histogram(fill='#7fcdbb')+geom_histogram(data=windf,aes(Frequency),fill='#2c7fb8')+scale_y_continuous(labels=scales::scientific,breaks = c(0,100000,200000,300000),limits = c(0,330000),sec.axis=sec_axis(trans=~.*(1/450)))+theme_classic(base_size=40)+xlab('ARI: Spar = 1, Loc = 5')+ylab(NULL)+theme(axis.text.y.right = element_text(color="#2c7fb8"),axis.text.y.left = element_text(color="#7fcdbb"))+scale_x_continuous(breaks=c(0,.2,.4,.6,.8,1), lim = c(0,1.1))
```

![](ARI_R_paramSweep_files/figure-gfm/unnamed-chunk-7-4.png)<!-- -->

``` r
### Sep. Plots - 1_20
windf<-data.frame(rep(c(o1_20win),450))
bwdf<-data.frame(c(o1_20bw))
colnames(windf)<-'Frequency'
colnames(bwdf)<-'Frequency'

ggplot(bwdf,aes(Frequency))+geom_histogram(fill='#7fcdbb')+geom_histogram(data=windf,aes(Frequency),fill='#2c7fb8')+scale_y_continuous(labels=scales::scientific,breaks = c(0,100000,200000,300000),limits = c(0,330000),sec.axis=sec_axis(trans=~.*(1/450)))+theme_classic(base_size=40)+xlab('ARI: Spar = 1, Loc = 20')+ylab(NULL)+theme(axis.text.y.right = element_text(color="#2c7fb8"),axis.text.y.left = element_text(color="#7fcdbb"))+scale_x_continuous(breaks=c(0,.2,.4,.6,.8,1), lim = c(0,1.1))
```

![](ARI_R_paramSweep_files/figure-gfm/unnamed-chunk-7-5.png)<!-- -->

``` r
### Sep. Plots - o2_5
windf<-data.frame(rep(c(o2_5win),450))
bwdf<-data.frame(c(o2_5bw))
colnames(windf)<-'Frequency'
colnames(bwdf)<-'Frequency'

ggplot(bwdf,aes(Frequency))+geom_histogram(fill='#7fcdbb')+geom_histogram(data=windf,aes(Frequency),fill='#2c7fb8')+scale_y_continuous(labels=scales::scientific,breaks = c(0,100000,200000,300000),limits = c(0,330000),sec.axis=sec_axis(trans=~.*(1/450)))+theme_classic(base_size=40)+xlab('ARI: Spar = 2, Loc = 5')+ylab(NULL)+theme(axis.text.y.right = element_text(color="#2c7fb8"),axis.text.y.left = element_text(color="#7fcdbb"))+scale_x_continuous(breaks=c(0,.2,.4,.6,.8,1), lim = c(0,1.1))
```

![](ARI_R_paramSweep_files/figure-gfm/unnamed-chunk-7-6.png)<!-- -->

``` r
### Sep. Plots - o2_10
windf<-data.frame(rep(c(o2_10win),450))
bwdf<-data.frame(c(o2_10bw))
colnames(windf)<-'Frequency'
colnames(bwdf)<-'Frequency'

ggplot(bwdf,aes(Frequency))+geom_histogram(fill='#7fcdbb')+geom_histogram(data=windf,aes(Frequency),fill='#2c7fb8')+scale_y_continuous(labels=scales::scientific,breaks = c(0,100000,200000,300000),limits = c(0,330000),sec.axis=sec_axis(trans=~.*(1/450)))+theme_classic(base_size=40)+xlab('ARI: Spar = 2, Loc = 10')+ylab(NULL)+theme(axis.text.y.right = element_text(color="#2c7fb8"),axis.text.y.left = element_text(color="#7fcdbb"))+scale_x_continuous(breaks=c(0,.2,.4,.6,.8,1), lim = c(0,1.1))
```

![](ARI_R_paramSweep_files/figure-gfm/unnamed-chunk-7-7.png)<!-- -->

``` r
### Sep. Plots - 2_20
windf<-data.frame(rep(c(o2_20win),450))
bwdf<-data.frame(c(o2_20bw))
colnames(windf)<-'Frequency'
colnames(bwdf)<-'Frequency'

ggplot(bwdf,aes(Frequency))+geom_histogram(fill='#7fcdbb')+geom_histogram(data=windf,aes(Frequency),fill='#2c7fb8',bins=)+scale_y_continuous(labels=scales::scientific,breaks = c(0,100000,200000,300000),limits = c(0,330000),sec.axis=sec_axis(trans=~.*(1/450)))+theme_classic(base_size=40)+xlab('ARI: Spar = 2, Loc = 20')+ylab(NULL)+theme(axis.text.y.right = element_text(color="#2c7fb8"),axis.text.y.left = element_text(color="#7fcdbb"))+scale_x_continuous(breaks=c(0,.2,.4,.6,.8,1), lim = c(0,1.1))
```

![](ARI_R_paramSweep_files/figure-gfm/unnamed-chunk-7-8.png)<!-- -->
