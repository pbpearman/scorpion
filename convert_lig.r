library(rgdal)
library(raster)
setwd("/Network/Servers/lsd/lud11/pearman/lud11_docs/wsl_research/projects/scorpion/data/interglacial/lig_30s_bio/")

for (i in 1:19){
  eval(parse(text=paste("bio_",i," <- raster('lig_30s_bio_",i,".bil')",sep="")))
}
setwd("/Network/Servers/lsd/lud11/pearman/lud11_docs/wsl_research/projects/scorpion/data/interglacial/bio/")

for(i in 2:19){
  file <- paste("bio_",i,".tif",sep="")
  format <- "GTiff"
  eval(parse(text=paste("writeRaster(bio_",i,", filename='",file,"',format='",format,"')",sep="")))
  print(paste("done with bio",i,sep=""))
}
