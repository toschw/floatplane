#Preparing a Cook Inlet subset of destinations for Tammy, 03/05/2019
library(dplyr)
library(tidyr)


data <- read.csv("D:/Dropbox/DATA/Schwoerer_floatplane_survey/Destinations091916_4.csv",stringsAsFactor=FALSE)
CIdata <- subset(data, Name=="Cook Inlet"| Name =="Knik Arm")
CIdata2 <- select(CIdata, AnnualFl_1, HUC6, Name, UniqueID, Fetch_m, ElevMIN, Dest1Lat, Dest2Long, DestName, Dest_Acres)

CIdata2n <- select(CIdata2, -AnnualFl_1)
CIdata2n <- subset(CIdata2n,!duplicated(CIdata2n$UniqueID))

#summing flights by lake and putting in descending order
CIdata3 <- CIdata2 %>%
  group_by(UniqueID) %>%
  summarise(total_flights = sum(AnnualFl_1))
##adding the remaining columns
CIdata4 <- CIdata3 %>%
  inner_join(CIdata2n, by = "UniqueID")
##ordering by number of flights the destination receives

shareData <- CIdata4[order(-CIdata4$total_flights),]

#renaming some column names
names(shareData)[7:8] <- c("Lat","Long")
            
write.csv(shareData, file="D:/Dropbox/CURRENT_PROJECTS/1_AKSSF_Salmon_Elodea/POSTED/Floatplane_data/shareData.csv")           


