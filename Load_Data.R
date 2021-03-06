####UPDATING R TO MAKE SURE NO PACKAGES IS BROKEN###
###Run in R-GUI, not RStudio
### installing/loading the package:
#if(!require(installr)) {
#  install.packages("installr"); require(installr)} #load / install+load installr
#updateR() 
#version #to check version after updating, making sure things are alright
### this will start the updating process of your R installation.  
### It will check for newer versions, and if one is available, will guide you through the decisions you'd need to make.



####INSTALLING READ EXCEL PACKAGES####
####R core does not come with the ability to read excel
####Install packages to your flavor
####Check: http://stackoverflow.com/questions/7049272/importing-xlsx-file-into-r

#install.packages("readxl")
#library(readxl)

#install.packages("xlsx")
#library(xlsx)

####end####

####READ MCM DATA FILE####
####Change all the space in the file name to underscore
goodgrant_schoolID <- read_excel("C:/Users/Tra/Desktop/GoodGrantData/Problem_C__IPEDS_UID_for_Potential_Candidate_Schools.xlsx")
str(goodgrant_schoolID) #Learn its structure

goodgrant_score <- read_excel("C:/Users/Tra/Desktop/GoodGrantData/Problem_C__Most_Recent_Cohorts_Data_Scorecard Elements.xlsx")
str(goodgrant_score) #Learn its structure

goodgrant_dictionary <- read_excel("C:/Users/Tra/Desktop/GoodGrantData/Problem_C__CollegeScorecardDataDictionary_09082015.xlsx")
str(goodgrant_dictionary) #Learn its structure

####REPLACING VARIABLE NAME IN GOODGRANT SCORING METRIC WITH REAL MEANINGFUL NAME FROM DICTIONARY####
 
####WITH DEVELOPER FRIENDLY NAMES####
  goodgrant_dictionary_short <- goodgrant_dictionary[,c("developer-friendly name", "VARIABLE NAME")] #creating dataframe with just Variable name and meaning
  goodgrant_dictionary_short <- goodgrant_dictionary_short[rowSums(is.na(goodgrant_dictionary_short)) != ncol(goodgrant_dictionary_short),] #eliminating empty rows
  colnames(goodgrant_dictionary_short)[colnames(goodgrant_dictionary_short)== "VARIABLE NAME"] <- "VARIABLE" #rename column
  colnames(goodgrant_dictionary_short)[colnames(goodgrant_dictionary_short)== "developer-friendly name"] <- "NAME" #rename column
  
  for (i in 1:ncol(goodgrant_score)) {
    if (colnames(goodgrant_score[i]) %in% goodgrant_dictionary_short$VARIABLE) {
      foil_name <- colnames(goodgrant_score[i])
      foil <- goodgrant_dictionary_short[goodgrant_dictionary_short$VARIABLE == foil_name,]
      colnames(goodgrant_score)[i] <- foil$NAME
    }
  }

  score_name <- c(colnames(goodgrant_score))
  print <- data.frame(score_name)
  write.table(print, file = "C:/Users/Tra/Desktop/score_name.csv", eol = "\n", sep = " ", quote = FALSE) #print names in rows, need to be transposed
  

####WITH MEANINGFUL-FULL NAMES####

  goodgrant_dictionary_short <- goodgrant_dictionary[,c("NAME OF DATA ELEMENT", "VARIABLE NAME")] #creating dataframe with just Variable name and meaning
  goodgrant_dictionary_short <- goodgrant_dictionary_short[rowSums(is.na(goodgrant_dictionary_short)) != ncol(goodgrant_dictionary_short),] #eliminating empty rows
  colnames(goodgrant_dictionary_short)[colnames(goodgrant_dictionary_short)== "VARIABLE NAME"] <- "VARIABLE" #rename column
  colnames(goodgrant_dictionary_short)[colnames(goodgrant_dictionary_short)== "NAME OF DATA ELEMENT"] <- "NAME" #rename column
  
  for (i in 1:ncol(goodgrant_score)) {
    if (colnames(goodgrant_score[i]) %in% goodgrant_dictionary_short$VARIABLE) {
      foil_name <- colnames(goodgrant_score[i])
      foil <- goodgrant_dictionary_short[goodgrant_dictionary_short$VARIABLE == foil_name,]
      colnames(goodgrant_score)[i] <- foil$NAME
    }
  }
  #write/export - not working yet because /r and /n in values => make write.csv not exportable
write.csv(goodgrant_score, file = "C:/Users/Tra/Desktop/goodgrant_score.csv", quote = FALSE)
#or
write.xlsx(goodgrant_score, file = "C:/Users/Tra/Desktop/goodgrant_score.xls", sheetName="Sheet1", col.names=TRUE, row.names=TRUE, append=FALSE, showNA=TRUE) #non-functional as error with rJava

##################################################################################################################
######SPLITTING PUBLIC/PRIVATE INSTITUTE######
  goodgrant_score_public <- goodgrant_score[goodgrant_score$ownership == "1", ]
  goodgrant_score_public <- goodgrant_score_public[,grepl("private",colnames(test_df)) == FALSE] #erase column that include "private"// include only columes that doesn't include "private"
  
  goodgrant_score_private_non <- goodgrant_score[goodgrant_score$ownership == "2", ]
  goodgrant_score_private_non <- goodgrant_score_private_non[,grepl("public",colnames(test_df)) == FALSE]  #erase column that include "public"// include only columes that doesn't include "public"
  
  goodgrant_score_private_for <- goodgrant_score[goodgrant_score$ownership == "3", ]
  goodgrant_score_private_for <- goodgrant_score_private_for[,grepl("public",colnames(test_df)) == FALSE] #erase column that include "public"// include only columes that doesn't include "public"
  
  #test_df <- goodgrant_score_private_non[,]
  #test_df <- test_df[,grepl("public",colnames(test_df)) == FALSE]
##################################################################################################################
### Doc: https://cran.r-project.org/web/packages/R.matlab/R.matlab.pdf
# library(R.matlab)
 writeMat("goodgrant_score_public.mat", labpcexport = goodgrant_score_public) #write to matlab
 writeMat("goodgrant_score_private_non.mat", labpcexport = goodgrant_score_private_non) #write to matlab
 writeMat("goodgrant_score_private_for.mat", labpcexport = goodgrant_score_private_for) #write to matlab
 
#### writeMat is hard encoded in field of length of 32 int 
#=> fields with name longer than that gives error
# Need to scan for long names and shorten them

for (i in 1:ncol(goodgrant_score_private_for)) {
  if (nchar(colnames(goodgrant_score_private_for[i])) > 32) { #check if the column name has more than 32 char
    substring_names <- substring(colnames(goodgrant_score_private_for[i]), first = 1, last = 31) #make colname has only 31 char
    colnames(goodgrant_score_private_for[i]) <- substring_names
   ###Other non-functional alternatives
    #substring_names <- substring(colnames(goodgrant_score_private_for[i]), first = 1, last = 31)
    #colnames(goodgrant_score_private_for[i]) <- substring_names
    #goodgrant_score_private_for <- goodgrant_score_private_for[,substring(colnames(goodgrant_score_private_for[i]), first = 1, last = 31)] 
    #substring(colnames(goodgrant_score_private_for[i]), first = 1, last = 31) <- colnames(goodgrant_score_private_for[i])

  }}  

##################################################################################################################
####CREATING DESIRED OUTPUT FILES####
goodgrant_dictionary_criteria2 <- goodgrant_dictionary[c(8,11,15,20,25,118,152,166,267,270,272,274,279,281,283,285,290,292,293,294,295,296:329),] #substracting the rows (of picked criteria)


##################################################################################################################
####TURNING DATA TYPE INTO NUMERIC TYPE####

goodgrant_score <- transform(goodgrant_score, RELAFFIL = as.numeric(RELAFFIL))
goodgrant_score <- transform(goodgrant_score, SATVR25 = as.numeric(SATVR25))



for(x in seq(1,length(colnames(goodgrant_score)))){
  names <- colnames(goodgrant_score[x])
  goodgrant_score <- transform(goodgrant_score, names = as.numeric(names))}

library(dplyr)
goodgrant_score %>% 
  mutate_if(is.character, funs(as.numeric(as.character(.))))
