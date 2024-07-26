#Set home
setwd(setwd("~/R_packages/APW/filtering_occurrences"))
home <- getwd()

# Load Terra for spatial data manipulation
library(terra)

#read in species occurrence points. We will use the ones included in the spThin package (Heteromys_anomalus)
library(spThin)
data("Heteromys_anomalus_South_America")
xy <- data.frame(cbind(Heteromys_anomalus_South_America$LONG, Heteromys_anomalus_South_America$LAT))
colnames(xy) <- c('LONG', 'LAT')

#read in the environmental data that you will use in niche modelling. Here we will use five layers from Worldclim v. 2.1 at 5 min resolution, downloaded from https://www.worldclim.org/data/worldclim21.html.
bio1 <- rast("EnvData/wc2.1_5m_bio_1.tif")
bio5 <- rast("EnvData/wc2.1_5m_bio_5.tif")
bio6 <- rast("EnvData/wc2.1_5m_bio_6.tif")
bio12 <- rast("EnvData/wc2.1_5m_bio_12.tif")
bio13 <- rast("EnvData/wc2.1_5m_bio_13.tif")
bio14 <- rast("EnvData/wc2.1_5m_bio_14.tif")

#stack these rasters - don't worry about warning messages
s <- c(bio1, bio5, bio6, bio12, bio13, bio14)

#extract the environmental data at your occurrence data and convert to a data.frame
d <- data.frame(extract(s, xy))

#check out the data structure
head(d)

#function to resample your data so only one occurrence is allowed per environmental combination
is.between <- function(x, band) {
  for (k in c(2:length(band))){
    if (x >= band[k-1] & x < band[k]){
      return(k-1)
    }
  }
  return(-9999)
}


#set the columns (number of variables) to resample. Selecting everything here. 
combinated_cols<-c(ncol(d))

#set the resolution for each environmental variable (that is, how you want to 'split' your environmental variables). '1' indicates every value is counted as unique, whereas '2' would mean the environmental variables are grouped by values of two (e.g., temperatures of 0 and 1 degrees C would be grouped together and seen as only one unique value).

#the length of the res_bands must be no less than combinated_cols but can be more (just useless information at that point)
#try altering the resolution of each variable by changing the corresponding value in res_bands
res_bands<-c(5, 5, 5, 500, 50, 25)

#give every point a band-label
d$label<-""
band_grid <- list()
for (i in c(1:length(res_bands))){
  band_grid<-seq(from=min(d[,i]),to=max(d[,i]) + res_bands[i], by=res_bands[i])
  for (j in c(1:dim(d)[1])){
    v<-d[j, i]
    if(d[j,]$label==""){
      d[j,]$label<-paste0(is.between(v, band_grid))
    } else {
      d[j,]$label<-paste(d[j,]$label, is.between(v, band_grid), sep = "-")
    }
  }
}

#add lat and long into the data frame
d$LONG<-xy$LONG
d$LAT <-xy$LAT


#resample the occurrence points
d_samp<-data.frame()
for (label in unique(d$label)){
  d_sub<-d[which(d$label==label),]
  d_samp<-rbind(d_samp, d_sub[1,]) #use this to select first occurrence in combination, otherwise use d_samp<-rbind(d_samp, sample(d_sub, n=1)) if you want to select at random
}


#plot the filtered and selected data. 
plot(d$LONG, d$LAT, pch=".")
points(d_samp$LONG, d_samp$LAT, col="red", pch=1)

#Q: How does this compare to the spatially filtered occurrence data using spThin?

#write the new filtered occurrences to a file.
write.table(d_samp, file="filtered_new.csv", row.names=F, sep=",")

