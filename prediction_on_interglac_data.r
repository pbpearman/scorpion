
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


load("/home/pearman/lud11_docs/wsl_research/projects/scorpion/data/interglacial/bio/interglac_CLIM_SP_DF")



predict.data1 <- interglac.clim2
rm(interglac.clim2)

species <- c("scorp")
results.dir <- c("scorp")

#species <- c("abies.r","picea.nor")


           
calculation.folder <- paste("/home/pearman/lud11_docs/wsl_research/projects/scorpion/r_code/",results.dir,sep="")
setwd(calculation.folder)


models <- c("gam","glm","gbm","me")
para.sets <- c("vec2","vec3","vec4","vec5")       # c("vec1","vec2","vec3","vec4","vec5")  # adjust this

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
      fname = paste("INTERGLAC_PREDICTION_",k,sep="")  
      save(predict.data,file=fname)      
    }
  }

  
}

rm(list=ls())


load("./INTERGLAC_PREDICTION_scorp")
dummy <- raster("/home/pearman/lud11_docs/wsl_research/projects/scorpion/data/interglacial/bio/index_layer.tif")

models <- c("gam","glm","gbm","me")
para.sets <- c("vec1","vec2","vec3","vec4","vec5")

ensemble <- rep(0,dim(predict.data)[1])

for (i in models){
  for (j in para.sets) {
    eval(parse(text=paste("ensemble <- ensemble + predict.data@data$bi",i,j,sep="")))
  }
}

predict.data@data$ensemble <- ensemble

interglac.distribution <- rasterize(predict.data,y=dummy,field="ensemble")

setwd("/home/pearman/lud11_docs/wsl_research/projects/scorpion/r_code/scorp/")
writeRaster(interglac.distribution,"interglac_distribution.tif",format="GTiff")
