# read settings from shell
args <- commandArgs()
n <- args[length(args)]
index <- as.numeric(n)

library(foreign)

load("/home/pearman/lud11_docs/wsl_research/projects/scorpion/data/PSEUDO_ABS_CLIMATE")
pseudo.abs$ID <- NULL
pseudo.abs$index.2 <- NULL

set.seed <- 123456
pseudo.abs1 <- pseudo.abs[sample(dim(pseudo.abs)[1],2000,replace=FALSE),]

pseudo.abs <- pseudo.abs1

# load the species and climate data

load("/home/pearman/lud11_docs/wsl_research/projects/scorpion/data/PRESENCE_CLIMATE")
occs1$index.2 <- NULL

# run the models

setwd("/home/pearman/lud11_docs/wsl_research/projects/scorpion/r_code/")

source("ctf_run4models_function.r")



#  specify parameter sets here
vec1 <- c("bio3","bio8","bio15","bio18")   #OK
vec2 <- c("bio1","bio2","bio8","bio17")    #OK
vec3 <- c("bio2","bio5","bio15","bio18")   #OK
vec4 <- c("bio5","bio6","bio13","bio15")   #OK
vec5 <- c("bio2","bio8","bio11","bio14")   #OK

# here you specify the species names as a single value or a vector.
# resdir, below, could potentially be a vector, for example if models were to built with two different datasets
# otherwise, each of the species directories will be set up in the results directory

#species <- names(data.a)[index]
resdir <- "scorp"
species <- resdir

data1 <- rbind(occs1,pseudo.abs)


# calculation of number of occurrences and the prevalence of each lineage or species
occurrences <- sum(data1[,species])



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

