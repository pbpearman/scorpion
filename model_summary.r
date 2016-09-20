models <- c("gam","gbm","glm","me")

auc.1 <- numeric()
model <- character()
data <- data.frame()
setwd("/Network/Servers/lsd/lud11/pearman/lud11_docs/wsl_research/projects/scorpion/r_code/scorp/scorp/summary_stat_models/")

for (i in models) {
  fname <- paste("sum.stat.",i,"_scorp.csv",sep="")
  data <- read.csv(fname)[-1]
  auc.1 <- rbind(auc.1,data)
  mod <- rep(i,5)
  mod2 <- matrix(mod,nrow=5,ncol=1)
  model <- rbind(model,mod2)  
}
data2 <- data.frame(data,model=model)

means <- colMeans(data2[,1:4])

sdev <- apply(data2[,1:4],2,sd)
rbind(means,sdev)
