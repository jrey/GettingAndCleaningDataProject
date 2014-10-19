GettingAndCleaningDataProject
=============================

The file "readdata.R" has code to load, tidy up and save the "Human 
Activity Recognition Using Smartphones Dataset" downloaded from 

[https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)

This script uses the library dplyr, you may install it by executing:

```R
install.packages("dplyr")
```

# Quick start
To get a clean data set from the downloaded file:

1. unzip the file "getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
2. run R
3. execute the command: ```build.tidy.data("UCI HAR Dataset")```
4. exit R

The file ```tidy.txt``` should have the result

