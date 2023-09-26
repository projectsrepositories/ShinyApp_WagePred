# 1. Get the dataset
# 2. Split into training and testing set
# 3. Train the model using Random Forest
# 4. Save the model

library(randomForest)
library(caret)
library(ISLR)

# Get the wage dataset
set.seed(20)
data(Wage)
Wage<-subset(Wage, select=-c(logwage, year, health, health_ins, region))
summary(Wage)

# Perform random split of the data set
inTrain <- createDataPartition(Wage$wage, p=0.8, list = FALSE)
training <- Wage[inTrain,] 
testing <- Wage[-inTrain,] 

write.csv(training, "training.csv")
write.csv(testing, "testing.csv")

trainSet <- read.csv("training.csv", header = TRUE)
trainSet <- trainSet[,-1]

# Build Random Forest model
model <- train(wage~.,method = "rf", data=training)

# Save model to RDS file
saveRDS(model, "model.rds")
