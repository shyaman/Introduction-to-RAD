#plot_twisst.R

setwd('~/Introduction-to-RAD/pungitius_exercise/phylogenetics/')
source('twisst_plotting_functions.R')
library(ggplot2)
library(cowplot)
library(scales)


#SET FILE NAMES

#weights file with a column for each topology
#note the topologies are saved in the working directory
weights_file <- "weights.txt"



#coordinates file for each window
window_data_file <- "bounds.txt"


# READ IN DATA

#weights data
weights = read.table(weights_file, header = T)
head(weights)
#normalise rows so weights sum to 1
weights <- weights / apply(weights, 1, sum)
#retrieve the names of the topologies
topoNames = names(weights)

#window data
window_data = read.table(window_data_file)
colnames(window_data) = c('start', 'end')
window_data$window = 1:nrow(window_data)
window_data$mid = apply(window_data[,c('start', 'end')], 1, mean) 
# window_data$mid = window_data$mid/1e6
head(window_data)


#exclude any rows where data is missing
good_rows = which(is.na(apply(weights,1,sum)) == F)
weights <- weights[good_rows,]
window_data = window_data[good_rows,]

## PLOT RESULTS

#plot means for the chromosome
mod.cols = cols
sums = apply(weights, 2, sum) / 207
contrib.df = data.frame(contrib = sums)
contrib.df$topo=factor(rownames(contrib.df), levels=rownames(contrib.df)) #so ggplot knows they are ordered factors
topoNums = sub("topo", "", contrib.df$topo)
contrib.df$topoNum = factor(topoNums, levels=topoNums)
contrib.df$color = mod.cols[1:nrow(contrib.df)]
bp=barplot(sums, col= mod.cols[1:length(sums)], ylab='Mean', main='mean topology weights accross chr12')



# #use loess to smooth weights.
span = 0.2
weights_smooth <- smooth_df(x=window_data$mid,weights,col.names=colnames(weights),span=span, min=0, max=1,weights=window_data$sites)
#rescale to sum to 1
weights_smooth <- weights_smooth / apply(weights_smooth, 1, sum)
reorder = colnames(weights_smooth)
reorder[3] = colnames(weights_smooth)[2]
reorder[2] = colnames(weights_smooth)[3]
weights_smooth = weights_smooth[,reorder]



# #plot the twisst way
mod.cols = cols[1:3]
g=ggplot_weights(weights_dataframe=weights_smooth, positions=window_data$mid/1e6, line_cols= line.cols, fill_cols=mod.cols, xlim =c(1, max(window_data$end)),stacked=T, xlab = "Position (Mb)", draw.legend=T)


#plot simple line plot
dim(weights)
line.cols = hue_pal()(3) #switch to cowplot colors
LWD=2
ws2 = weights_smooth
ws2$mb = window_data$mid / 1e6
norm.breaks = c(3.5, 18.9)
lp = ggplot(data= ws2) + 
	geom_line(aes(x=mb,y=topo3), col=line.cols[2], lwd=LWD) +
	geom_line(aes(x=mb,y=topo2), col=line.cols[3], lwd=LWD) +
	geom_line(aes(x=mb,y=topo1), col=line.cols[1], lwd=LWD) + 
	labs(y="Weight", x="Position (Mb)") + 
	scale_y_continuous(breaks=c(0,0.5, 1)) +
	scale_x_continuous(breaks=c(0,10,20)) 
plot(lp)

