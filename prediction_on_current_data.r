
args <- commandArgs()
n <- args[length(args)]
index <- as.numeric(n)





options(java.parameters="-Xmx4g")
library(shapefiles)
library(maptools)
library(foreign)
#gpclibPermit()
library(gbm)
library(gam)
library(raster)
library(dismo)
library(rJava)


load("/Users/bgppermp/Dropbox/Sweden_SDM_course/r_code/scorpion/data/current/CURR_CLIM_SP_DF")

curr.clim <- curr.clim[-which(is.na(curr.clim@data$bio1)),]

predict.data1 <- curr.clim
rm(curr.clim)

species <- c("scorp")
results.dir <- c("scorp")

           
calculation.folder <- paste("/Users/bgppermp/Dropbox/Sweden_SDM_course/r_code/scorpion/",results.dir,sep="")
setwd(calculation.folder)


models <- c("gam","glm","gbm")   #only include the models that you want
para.sets <- c("vec1","vec2","vec3","vec4","vec5")  # adjust this also, too many will result in an error

for(k in species){
  predict.data <- predict.data1
  for(i in models){
    z=0
    for(j in para.sets){
      z=z+1
      print(paste("now i = ",i," and j = ",j," and k = ",k,sep=""))
      y <- eval(parse(text=paste("load('./",k,"/",k,"_",i,"_",j,"',.GlobalEnv)",sep="")))
      if((i=="gam")==TRUE) mod.obj <- gam.step
      if((i=="glm")==TRUE) mod.obj <- glm.step
      if((i=="gbm")==TRUE) mod.obj <- gbm.model
      if((i=="me")==TRUE)  mod.obj <- me

      if((i=="gbm")==TRUE){
        pred <- predict.gbm(mod.obj,predict.data,n.trees=best.itr1,type="response")
        eval(parse(text=paste("predict.data@data$",i,j," <- pred",sep="")))
        pres <- as.numeric(pred > gbm.tss.max)
        eval(parse(text=paste("predict.data@data$bi",i,j," <- pres",sep="")))
      }

      if((i=="gam")==TRUE){
        pred <- predict.gam(mod.obj,predict.data,type="response")
        eval(parse(text=paste("predict.data@data$",i,j," <- pred",sep="")))
        pres <- as.numeric(pred > gam.tss.max)
        eval(parse(text=paste("predict.data@data$bi",i,j," <- pres",sep="")))
      }

      if((i=="glm")==TRUE){
        pred <- predict(mod.obj,predict.data,type="response")
        eval(parse(text=paste("predict.data@data$",i,j," <- pred",sep="")))
        pres <- as.numeric(pred > glm.tss.max)
        eval(parse(text=paste("predict.data@data$bi",i,j," <- pres",sep="")))

      }

      if((i=="me")==TRUE){
        system(paste("mkdir -p ",species,"/temp.path",sep=""))
        mod.obj@path <- paste(species,"/temp.path",sep="")
        pred <- dismo::predict(mod.obj,predict.data,type="response",na.rm=FALSE)
        eval(parse(text=paste("predict.data@data$",i,j," <- pred",sep="")))
        pres <- as.numeric(pred > me.max.tss)
        eval(parse(text=paste("predict.data@data$bi",i,j," <- pres",sep="")))
      }
      rm(list=y)
    }
  }

  fname = paste("CURRENT_PREDICTION_",k,sep="")  
  save(predict.data,file=fname)
}

rm(list=ls())


load("CURRENT_PREDICTION_scorp")
dummy <- raster("/Users/bgppermp/Dropbox/Sweden_SDM_course/r_code/scorpion/data/current/index_layer.tif")

models <- c("gam","glm","gbm")
para.sets <- c("vec1","vec2","vec3","vec4","vec5")

ensemble <- rep(0,dim(predict.data)[1])

for (i in models){
  for (j in para.sets) {
    eval(parse(text=paste("ensemble <- ensemble + predict.data@data$bi",i,j,sep="")))
  }
}

predict.data@data$ensemble <- ensemble

current.distribution <- rasterize(predict.data,y=dummy,field="ensemble")

setwd("/Users/bgppermp/Dropbox/Sweden_SDM_course/r_code/scorpion/scorp/")
writeRaster(current.distribution,"current_distribution.tif",format="GTiff")
