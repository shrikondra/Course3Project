# This is the Project main file

library(reshape2)

filename <- "getdata_UCI_HAR_dataset.zip"

## Download the file and unzip the dataset:
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}


# Load activity labels + features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
featuresWanted <- grep("mean\\(\\)|std\\(\\)",features[,2])
featureNames <- features[featuresWanted,2]
featureNames <- gsub('-mean', 'Mean', featureNames)
featureNames <- gsub('-std', 'Std', featureNames)
featureNames <- gsub('[-()]', '', featureNames)


# Load the train datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresWanted]
trainActivities <- read.table("UCI HAR Dataset/train/y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

# Load the test datasets
test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresWanted]
testActivities <- read.table("UCI HAR Dataset/test/y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge datasets and add labels
MergedData <- rbind(train, test)
colnames(MergedData) <- c("subject", "activity", featureNames)

# turn activities & subjects into factors
MergedData$activity <- factor(MergedData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
MergedData$subject <- as.factor(MergedData$subject)

MergedData.melted <- melt(MergedData, id = c("subject", "activity"))
FinalTidyData <- dcast(MergedData.melted, subject + activity ~ variable, mean)

# Write the dataset to a txt file
write.table(FinalTidyData, "tidy.txt", row.names = FALSE, quote = FALSE)

