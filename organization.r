
library(maptools)
library(raster)
data <- read.dbf("/Network/Servers/lsd/lud11/pearman/lud11_docs/wsl_research/projects/scorpion/gis/shape/scorppoints.dbf")

names(data) <- c("species", "lat","long")

obs <- SpatialPointsDataFrame(data[,c(3,2)],data[,1:3],proj4string = CRS('+proj=longlat +datum=WGS84'))



setwd("/Network/Servers/lsd/lud11/pearman/lud11_docs/wsl_research/climate_layers/world_clim_current/30sec/bio/")


for (i in 1:19) eval(parse(text=paste("bio_",i," <- raster('bio_",i,"')",sep="")))
climate.stk <- stack()
for (i in 1:19) eval(parse(text=paste("climate.stk <- addLayer(climate.stk,bio_",i,")",sep="")))
layerNames(climate.stk) <- paste("bio",1:19,sep="")
climate.stk <- addLayer(climate.stk,bio_1)
layerNames(climate.stk)[20] <- "index"



extent.climate <- extent(-117.2,-88.8,14.4,42.0)
climate.stk2 <- crop(climate.stk,extent.climate)


ncells <- ncell(climate.stk2[[20]])
index2 <- climate.stk2[[20]]
values(index2) <- c(1:ncells)

plot(climate.stk2[[20]])

climate.stk2 <- addLayer(climate.stk2,index2)
climate.stk2 <- dropLayer(climate.stk2,20)

setwd("/Network/Servers/lsd/lud11/pearman/lud11_docs/wsl_research/projects/scorpion/gis/shape")

pseudoabs.poly <- readShapePoly("study_area",IDvar="Id",proj4string = CRS('+proj=longlat +datum=WGS84'))

pseudo.abs <- extract(climate.stk2,pseudoabs.poly,df=TRUE)
pseudo.abs <- pseudo.abs[which(!is.na(pseudo.abs$bio1)==TRUE),]

occs <- as.data.frame(extract(climate.stk2,obs,df=TRUE))
occs1 <- occs[which(!duplicated(occs$index)==TRUE),]

cors <- cor(pseudo.abs[,2:20],method="pearson")

file.name <- "/Network/Servers/lsd/lud11/pearman/lud11_docs/wsl_research/projects/scorpion/csv/correlation_results.csv"
write.csv(cors,file=file.name)

file.name <- "/Network/Servers/lsd/lud11/pearman/lud11_docs/wsl_research/projects/scorpion/data/PSEUDO_ABS_CLIMATE"
pseudo.abs$scorp <- rep(0,dim(pseudo.abs)[1])
save(pseudo.abs,file=file.name)

file.name <- "/Network/Servers/lsd/lud11/pearman/lud11_docs/wsl_research/projects/scorpion/data/PRESENCE_CLIMATE"
occs1$scorp <- rep(1,dim(occs1)[1])
save(occs1,file=file.name)

##############################################################################
# organize current climate data
##############################################################################
library(maptools)
library(raster)

setwd("//Network/Servers/lsd/lud11/pearman/lud11_docs/wsl_research/climate_layers/world_clim_current/30sec/bio/")


for (i in 1:19) eval(parse(text=paste("bio_",i," <- raster('bio_",i,"')",sep="")))

climate.stk <- stack()

for (i in 1:19) eval(parse(text=paste("climate.stk <- addLayer(climate.stk,bio_",i,")",sep="")))
layerNames(climate.stk) <- paste("bio",1:19,sep="")

climate.stk <- addLayer(climate.stk,bio_1)

layerNames(climate.stk)[20] <- "index"

climate.stk2 <- stack()

extent.climate <- extent(-117.2,-86.3,14.3,42.1)
climate.stk2 <- crop(climate.stk,extent.climate)


ncells <- ncell(climate.stk2[[20]])
index2 <- climate.stk2[[20]]
values(index2) <- c(1:ncells)

plot(climate.stk2[[20]])

climate.stk2 <- addLayer(climate.stk2,index2)
climate.stk2 <- dropLayer(climate.stk2,20)
setwd("/Network/Servers/lsd/lud11/pearman/lud11_docs/wsl_research/projects/scorpion/data/")

writeRaster(climate.stk2[[20]],"index_layer.tif",format="GTiff")

setwd("/Network/Servers/lsd/lud11/pearman/lud11_docs/wsl_research/projects/scorpion/data/worldclim_cropped_30sec/")

for(i in 1:19) eval(parse(text=paste("writeRaster(climate.stk2[[",i,"]],'bio",i,".tif',format='GTiff')",sep="")))

#setwd("/Network/Servers/lsd/lud11/pearman/lud11_docs/wsl_research/projects/scorpion/gis/shape")

#s.cent.USA.mex <- readShapePoly("s_central_usa_mex",IDvar="newID",proj4string = CRS('+proj=longlat +datum=WGS84'))

curr.clim <- rasterToPoints(climate.stk2,spatial=TRUE)
setwd("/Network/Servers/lsd/lud11/pearman/lud11_docs/wsl_research/projects/scorpion/data/")
file.name <- "CURR_CLIM_SP_DF"
save(curr.clim,file=file.name)

#######################################################################
#     organize MIROC LGM data
#######################################################################
library(maptools)
library(raster)

setwd("/Network/Servers/lsd/lud11/pearman/lud11_docs/wsl_research/climate_layers/LGM_climate/miroc_2_5m_21k/grids/bio/")


for (i in 1:19) eval(parse(text=paste("bio_",i," <- raster('bio_",i,"')",sep="")))

climate.stk <- stack()

for (i in 1:19) eval(parse(text=paste("climate.stk <- addLayer(climate.stk,bio_",i,")",sep="")))
layerNames(climate.stk) <- paste("bio",1:19,sep="")

#layerNames(climate.stk)[20] <- "index"

climate.stk2 <- stack()

extent.climate <- extent(-117.2,-86.3,14.3,42.1)
climate.stk2 <- crop(climate.stk,extent.climate)

for(i in 1:19) {
  eval(parse(text=paste("bio",i,"a <- disaggregate(climate.stk2[[",i,"]],fact=5,method='bilinear')",sep="")))
}
setwd("/Network/Servers/lsd/lud11/pearman/lud11_docs/wsl_research/projects/scorpion/data/miroc_30sec/")
for(i in 1:19) {
  eval(parse(text=paste("writeRaster(bio",i,"a,'bio",i,"a.tif',format='GTiff')",sep="")))
}
rm(list=ls())
for(i in 1:19) {
  eval(parse(text=paste("bio",i,"a <- raster('bio",i,"a.tif')",sep="")))
}


climate.stk3 <- stack()
for (i in 1:19) eval(parse(text=paste("climate.stk3 <- addLayer(climate.stk3,bio",i,"a)",sep="")))
index <- bio1a
names(index) <- "index"

ncells <- ncell(index)

values(index) <- c(1:ncells)
climate.stk3 <- addLayer(climate.stk3,index)




writeRaster(climate.stk3[[20]],"index_layer.tif",format="GTiff",overwrite=TRUE)
lnames <- paste("bio",1:19,sep="")
names(climate.stk3)[1:19] <- lnames


#for(i in 1:19) eval(parse(text=paste("writeRaster(climate.stk2[[",i,"]],'bio",i,".tif',format='GTiff')",sep="")))

#setwd("/Network/Servers/lsd/lud11/pearman/lud11_docs/wsl_research/projects/scorpion/gis/shape")

#s.cent.USA.mex <- readShapePoly("s_central_usa_mex",IDvar="newID",proj4string = CRS('+proj=longlat +datum=WGS84'))

miroc.clim <- rasterToPoints(climate.stk3,spatial=TRUE)
miroc.clim2 <- miroc.clim[-which(is.na(miroc.clim@data$bio1)),]


file.name <- "MIROC_CLIM_SP_DF"
save(miroc.clim2,file=file.name)

##################################################################################################
#          organize CCSM LGM data
##################################################################################################
library(maptools)
library(raster)

setwd("/home/pearman/lud11_docs/wsl_research/climate_layers/LGM_climate/ccsm_2_5m_21k/grids/bio/")


for (i in 1:19) eval(parse(text=paste("bio_",i," <- raster('bio_",i,"')",sep="")))

climate.stk <- stack()

for (i in 1:19) eval(parse(text=paste("climate.stk <- addLayer(climate.stk,bio_",i,")",sep="")))
layerNames(climate.stk) <- paste("bio",1:19,sep="")

#layerNames(climate.stk)[20] <- "index"

climate.stk2 <- stack()

extent.climate <- extent(-117.2,-86.3,14.3,42.1)
climate.stk2 <- crop(climate.stk,extent.climate)

for(i in 1:19) {
  eval(parse(text=paste("bio",i,"a <- disaggregate(climate.stk2[[",i,"]],fact=5,method='bilinear')",sep="")))
}
setwd("/home/pearman/lud11_docs/wsl_research/projects/scorpion/data/ccsm_30sec/")
for(i in 1:19) {
  eval(parse(text=paste("writeRaster(bio",i,"a,'bio",i,"a.tif',format='GTiff')",sep="")))
}
rm(list=ls())
for(i in 1:19) {
  eval(parse(text=paste("bio",i,"a <- raster('bio",i,"a.tif')",sep="")))
}


climate.stk3 <- stack()
for (i in 1:19) eval(parse(text=paste("climate.stk3 <- addLayer(climate.stk3,bio",i,"a)",sep="")))
index <- bio1a
names(index) <- "index"

ncells <- ncell(index)

values(index) <- c(1:ncells)
climate.stk3 <- addLayer(climate.stk3,index)


##################################################################################################
#          organize Last Interglacial data
##################################################################################################
library(maptools)
library(raster)

setwd("/Network/Servers/lsd/lud11/pearman/lud11_docs/wsl_research/projects/scorpion/data/interglacial/bio/")


#for (i in 1:19) eval(parse(text=paste("bio_",i," <- raster('bio_",i,".tif')",sep="")))

climate.stk <- stack()

for (i in 1:19) eval(parse(text=paste("climate.stk <- addLayer(climate.stk,bio_",i,")",sep="")))
layerNames(climate.stk) <- paste("bio",1:19,sep="")

#layerNames(climate.stk)[20] <- "index"

climate.stk2 <- stack()

extent.climate <- extent(-117.2,-86.3,14.3,42.1)
climate.stk2 <- crop(climate.stk,extent.climate)

for(i in 1:19) {
  #eval(parse(text=paste("bio",i,"a <- disaggregate(climate.stk2[[",i,"]],fact=5,method='bilinear')",sep="")))
  eval(parse(text=paste("bio",i,"a <-climate.stk2[[",i,"]]",sep="")))
}
setwd("/Network/Servers/lsd/lud11/pearman/lud11_docs/wsl_research/projects/scorpion/data/interglacial/bio/")
for(i in 1:19) {
  eval(parse(text=paste("writeRaster(bio",i,"a,'bio",i,"a.tif',format='GTiff')",sep="")))
}
rm(list=ls())
for(i in 1:19) {
  eval(parse(text=paste("bio",i,"a <- raster('bio",i,"a.tif')",sep="")))
}


climate.stk3 <- stack()
for (i in 1:19) eval(parse(text=paste("climate.stk3 <- addLayer(climate.stk3,bio",i,"a)",sep="")))
index <- bio1a
names(index) <- "index"

ncells <- ncell(index)

values(index) <- c(1:ncells)
climate.stk3 <- addLayer(climate.stk3,index)




writeRaster(climate.stk3[[20]],"index_layer.tif",format="GTiff",overwrite=TRUE)
lnames <- c(paste("bio",1:19,sep=""),"index")
layerNames(climate.stk3)[1:20] <- lnames


#for(i in 1:19) eval(parse(text=paste("writeRaster(climate.stk2[[",i,"]],'bio",i,".tif',format='GTiff')",sep="")))

#setwd("/Network/Servers/lsd/lud11/pearman/lud11_docs/wsl_research/projects/scorpion/gis/shape")

#s.cent.USA.mex <- readShapePoly("s_central_usa_mex",IDvar="newID",proj4string = CRS('+proj=longlat +datum=WGS84'))

interglac.clim <- rasterToPoints(climate.stk3,spatial=TRUE)
interglac.clim2 <- interglac.clim[-which(is.na(interglac.clim@data$bio1)),]


file.name <- "interglac_CLIM_SP_DF"
save(interglac.clim2,file=file.name)



###############
# helpful code
###############

load("CURR_CLIM_SP_DF")
index <- raster("index_layer.tif")
#  remove rows of a spatialPoints data frame that have NAs
curr.clim2 <- curr.clim[-which(is.na(curr.clim@data$bio1)),]

                                        # here is code to make rasters out of spatialpointdataframe columns
dummy <- index
values(dummy) <- NA
test <- rasterize(curr.clim2,y=dummy,field="bio1")



#  error text
> extent.climate <- extent(-117.2,-86.3,14.3,42.1)
> dummy2 <- crop(dummy,extent.climate)
> test <- rasterize(predict.data2,y=dummy,field="bio1")
Error in .local(x, filename, ...) : 
  Attempting to write a file to a path that does not exist:
  /tmp/R_raster_tmp/pearman
> 
