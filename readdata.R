library(dplyr)

# load.data - loads smartphone data set in data.frame
#
# This function loads train and test data sets from given directory 
# adds subject and activity labels to each data set and, returns a
# single dataset with all the data.
# Column names are clean up from puntuation
#
# RETURNS: a data.frame with all the data
#
load.data <- function(directory) {
    # Make a file path in a portable way
    rootPath <- function(name) file.path(directory, sprintf("%s.txt",name), fsep = .Platform$file.sep)

    # Make unique and friendly names
    #
    # feature.txt have duplicated labels that also have special chars.
    # This closure rename labels so they are unique and punctuation free
    used_labels <- new.env()        # Store eache label with a count of usage
    cleanFeatureName <- function(x) {
        x<-gsub("[(,)-]",".",x)     # Replace each of "(,)-" for a "_"
        x<-gsub("\\.+",".",x)       # Replace repeated "_" for a single "_"
        x<-gsub("\\.+$","",x)       # delete "_" at the end of labels

        # Unambiguate repeated labels
        if (exists(x, used_labels)) {
            # Label has been use before, get a new version of it
            used_labels[[x]] <- used_labels[[x]] + 1
            x <- paste(x, used_labels[[x]], sep=".")
        } else {
            used_labels[[x]] <- 1
        }
        x
    }

    # Load features and make a vector of cleaned features name
    features <- read.table(rootPath("features"), header=FALSE, col.names=c("fnum","feature"))
    featureNames <- sapply(features$feature, cleanFeatureName)

    # Load activity labels
    activities <- read.table(rootPath("activity_labels"), header=FALSE, col.names=c("anum","activity.label"))


    # read a dataset which may be train or test
    read.dataset <- function(dataset) {
        dataPath <- function(name) {
            file.path(directory, dataset, sprintf("%s_%s.txt",name,dataset), fsep = .Platform$file.sep)
        }

        # Read subjects
        s <- read.table(dataPath("subject"), header=FALSE, col.names=c("subject"))

        # Read samples
        x <- read.table(dataPath("X"), header=FALSE, col.names=featureNames)

        # Read activities and merge with its descriptive name
        y <- read.table(dataPath("y"), header=FALSE, col.names=c("anum"))
        y <- merge(y, activities, by="anum")

        x <- cbind(s, activity=y$activity, x)
    }

    testDataSet <- read.dataset("test")
    trainDataSet <- read.dataset("train")

    # Concatenate both tables in a single data.table
    rbind(testDataSet, trainDataSet)
}

# makeDescriptiveName - make column names descriptive
#
# This function receives a feature name and returns a friendly
# column name by replacing abbreviations with full names
makeDescriptiveName <- function(x) {
    x<-sub("Acc","Acceleration",x)
    x<-sub("Gyro","AngularVelocity",x)
    x<-sub("Mag","Magnitude",x)
    x<-sub("^t","time",x)
    x<-sub("^f","frequency",x)
    x<-sub("angle\\.t","angle.time",x)
    x
}

# tidy.data - create a tidy dataset
#
# selects only the measurements on the mean and standard deviation,
# sumarises them using the mean function and set descriptive names for
# the columns
tidy.data <- function(data) {
    # Extracts only the measurements on the mean and standard deviation for each measurement
    # and sumarises them using the mean function
    tidy <- data %>%
        select(matches("subject|activity|\\.(mean|std)\\b")) %>%
        group_by("subject","activity") %>%
        summarise_each(funs(mean))

    # Appropriately labels the data set with descriptive variable names
    colnames(tidy) <- lapply(colnames(tidy), makeDescriptiveName)
    
    tidy    # returns the tidy data
}

# build.tidy.data - create a tidy dataset from data
#
# loads the data from directory, tidies it up, and saves it to the file
build.tidy.data <- function(directory, file="tidy.txt") {
    # Loads and merges data to create one data set with descriptive activity names
    data <- load.data(directory)
    data <- tidy.data(data)
    write.table(data, file=file, row.name=FALSE)
}
