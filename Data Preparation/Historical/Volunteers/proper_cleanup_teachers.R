library(dplyr)
library(stringr)
library(tidyr)

setwd("/Users/Daniel/Desktop/Data/other")

#LESSON LEARNED: Sometimes, rather than trying to clean a bunch of messy data sets from start to finish using code, 
# it can be much more efficient to do the basic binning of relevant information manually with human knowledge
# as to how things should be, and then take care of the rest automatically. There was just way too much 
# variation and unclear recording practices from a machine-readable standpoint to try to do it all with code.

df <- read.csv('teachers_historical_1212.csv', stringsAsFactors = FALSE)
  
#Replacing blank strings with NA
df <- df %>% mutate(across(everything(), ~na_if(., "")))

#For multiple filter conditions, just use comma or &
#View(df %>% filter(!is.na(day) & is.na(name_1))) #which(!is.na(df$day) & is.na(df$name_1))

#Get rid of blank rows - all valid rows have volunteer name so
# we just get rid of rows that don't have volunteer name
df <- df %>% filter(!is.na(name_1))

#Filling in semester and year data
df <- df %>% fill(c(day,semester, year, class), .direction ='down')

#Separate out 2019 & 2020 data to combine two name columns into one
df_19 <- df %>% filter(year >= 2019)
df_rest <- df %>% filter(year < 2019) %>% rename(email_final=name_2, name=name_1, phone_1=email, phone_2=phone)

#Combining two name columns into one
df_19 <- df_19 %>% unite("name", name_1:name_2, sep=" ", remove=TRUE)
df_19 <- df_19 %>% rename(email_final=email, phone_1=phone)

#Bringing it back together
df <- bind_rows(df_rest, df_19)

#View(df %>% filter(!is.na(phone_1) & !is.na(phone_2)))

#Combining two columns into one (same as pd.combine_first from python)
df <- df %>% mutate(phone = coalesce(phone_1, phone_2), .before=semester) %>% 
             select(-c(phone_1,phone_2)) %>% rename(email=email_final)


#For indicator of new volunteer, newer years started using color or 
#bold type to indicate new volunteer rather than star, so had to go 
#through manually to add *. Not 100% positive on all cases but will 
#definitely be a closer tracker. Put together presentation to data collection
#team about certain best practices that will help minimize extra work

#I went through all years but seems like SUMMER 2013 is where stars stopped
#*Name -> already in spreadsheet
#Name* -> I manually added in to google spreadsheet

#Make sure that teacher names in Title Case


#Use str_detect, if punctuation at very beginning of col3 (so *), add YES
#To give idea of percentage new teacher vs returner
df <- df %>% mutate(new_volunteer = case_when(str_detect(name, pattern = "\\*") ~ "Yes", TRUE ~ 'No'), 
                    .before=semester, name = str_replace_all(name, pattern = "\\*", replacement = ""))


#Make sure no extra spaces - using new across method
df <- df %>% mutate(across(everything(), ~str_squish(.)))

#Format names
#df <- df %>% mutate(across(c(name, day), ~str_to_upper(.)))

df <- df %>% mutate(name = str_to_upper(name), 
                    day = str_to_title(day),
                    email = str_to_lower(email))

#Dropping duplicate rows
nrow(df)

#How to view duplicate rows
View(df %>% add_count(name, year, semester, class, day) %>% filter (n>1))

#Summer 2009 had weird way of listing people multiple times which is why
#there were a few dozen duplicates - other than that, all unique.
df <- distinct(df)

df <- df %>% mutate(category='teacher', .before=class)

write.csv(df, "All WEC Teacher Volunteers 2006 to Fall 2020.csv", row.names=FALSE)
