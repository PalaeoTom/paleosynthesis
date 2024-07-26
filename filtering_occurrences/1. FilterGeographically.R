#Package by Matthew E. Aiello-Lammens
#install the package if you have not yet done so
install.packages('spThin')

#call the package
library('spThin')

#loading the pre-existing dataset from the package
data("Heteromys_anomalus_South_America")

#look at the data
head(Heteromys_anomalus_South_America)

#Make a plot of the full data set
plot(Heteromys_anomalus_South_America$LONG, Heteromys_anomalus_South_America$LAT)

#the thin function returns spatially thinned species occurrence data sets. A randomization algorithm is used to create the data set in which all occurrence locations are at least thin.par distance apart. The threshold for thing.par depends in part on the biology of your species (e.g., home range size)

#100 repetitions, so 100 thinned datasets
thinned_dataset_full <- thin(loc.data = Heteromys_anomalus_South_America, lat.col= "LAT", long.col= "LONG", spec.col = "SPEC", thin.par = 10, reps = 100, locs.thinned.list.return = TRUE, write.files = FALSE)

#What was the maximum number of occurrences from the 100 repetitions? How does this compare to the full dataset?

#look at one of the datasets
thinned_dataset_full[[1]]
#You can see some of the row numbers skip on the left side, which indicates those records were filtered. 

#check out which points have been thinned. Add the thinned dataset to the full occurrence plot. The thinned points are red, which means the black points you see were removed. 
points(thinned_dataset_full[[1]]$Longitude, thinned_dataset_full[[1]]$Latitude, col="red", pch=20)

#Compare this result to the results you get from environmental filtering. 




