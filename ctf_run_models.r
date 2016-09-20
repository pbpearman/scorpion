# read settings from shell
args <- commandArgs()
n <- args[length(args)]
index <- as.numeric(n)

library(foreign)

load("/home/pearman/lud11_docs/wsl_research/projects/hyla_arenicolor/data/climate_data/PSEUDO_ABS_CLIMATE")
var.names <- paste("bio",1:19,sep="")
names(pseudo.abs)[1:19] <- var.names
pseudo.abs <- pseudo.abs[which(!is.na(pseudo.abs$bio1)),]


set.seed <- 123456
pseudo.abs1 <- pseudo.abs[sample(dim(pseudo.abs)[1],1000,replace=FALSE),]

pseudo.abs <- pseudo.abs1


pseudo.sp <- rep(0,dim(pseudo.abs)[1])
# run the models

setwd("/home/pearman/lud11_docs/wsl_research/projects/hyla_arenicolor/r_code/")

source("ctf_run4models_function.r")

# set working directory to directory with species data structures

setwd("/home/pearman/lud11_docs/wsl_research/projects/hyla_arenicolor/gis/shapefiles/")

# load the species and climate data

data.a <- read.dbf("lineages_climate_obs.dbf")
names(data.a)[13:31] <- var.names

#load weights for climate polygons, must be vector on 1's if not used
#and the length of this vector must be as long as dim(data.a)[1]



#  specify parameter sets here
vec1 <- c("bio3","bio8","bio15","bio18")   #OK
vec2 <- c("bio1","bio2","bio8","bio17")    #OK
vec3 <- c("bio2","bio5","bio18","bio19")   #OK
vec4 <- c("bio5","bio6","bio13","bio15")   #OK
vec5 <- c("bio2","bio8","bio11","bio14")   #OK

# here you specify the species names as a single value or a vector.
# resdir, below, could potentially be a vector, for example if models were to built with two different datasets
# otherwise, each of the species directories will be set up in the results directory
species <- names(data.a)[index]
resdir <- species

occs <- data.a[which(data.a[species]==1),]
occs <- occs[!duplicated(occs$index),]

occs.1 <- occs[,species]
occs.1a <- c(occs.1,pseudo.sp)
occs.2 <- occs[,13:31]
occs.2a <- rbind(occs.2,pseudo.abs[,1:19])


data1 <- data.frame(occs.1a,occs.2a)
names(data1)[1] <- species


# calculation of number of occurrences and the prevalence of each lineage or species
occurrences <- sum(data1[,species])

setwd("/home/pearman/lud11_docs/wsl_research/projects/hyla_arenicolor/r_code/")  
# write.table(occ.number, "occurrences.csv", sep = ",")
#prevalence <-occurrences/dim(data1)[1]
#names(prevalence)[1] <- "prev"

# these directories are necessary for smooth running of maxent
# full path names are needed for ME to work on Mac.  Maybe on windoze too.
me.dir1 <- paste(getwd(),"/",resdir,"/me_main",sep="")
me.dir2 <- paste(getwd(),"/",resdir,"/me_cv",sep="")



# make sure that these next two items have the same structure
vars <- list(vec1,vec2,vec3,vec4,vec5)
para.names <- c("vec1","vec2","vec3","vec4","vec5")

# here is where the data set is specified
data <- data1



# if there are a bunch of species, here you should set up a loop to run through the vector of species (or lineage) names
run4models(data=data,
                     species=species,
                     paraset=vars,
                     para.names=para.names,
                     models=c('me','glm','gam','gbm'),
                     atlas=FALSE,
                     climate.weights=NULL,
                     k=10,
                     resdir=resdir,
                     me.dir1=me.dir1,
                     me.dir2=me.dir2,
                     gbm.args=list(n.trees=10000,shrinkage.bound=c(0.01,0.0005),interaction.depth=3,maxiter=15),
                     maxent.args=c('-J','-P','threshold=false','product=false','quadratic=false'), #,'linear=false'),
                     seed=123456,
                     plot=FALSE,
                     help=FALSE)

cat(paste(species," ran successfully\n",sep=""),file="logfile.log",append=TRUE)

