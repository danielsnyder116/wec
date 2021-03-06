library(dplyr)
library(stringr)
library(readxl)
library(tidyr)
library(lubridate)


setwd("/Users/Daniel/Desktop")
#-------------------------------------------------------------------------------------------------------
#-------------------------------
# STUDENT DATA
#-------------------------------
# 
# #Bring in blackbaud student data (2020-06 - PRESENT)
# df_bb <- read.csv("bb_student_export_2021-05-15.csv", stringsAsFactors = FALSE)
# 
# #Getting rid of columns we ended up not needing
# df_bb <- df_bb %>% select(-c(Graduation.year, Province, Created.on)) %>% 
#                    rename(name = Student.summary, address = Home.address,
#                           enroll_date = Enroll.date, city = City, 
#                           state = State, zip_code = Postal.zip,
#                           country = Country )
# 
# n_distinct(df_bb$name)
# 
# 
# #Bringing in google sheets data
# #-----------------------------------------------------------------------------
# df_gs_1 <- read.csv("gs_tutoring_2020-08.csv", stringsAsFactors = FALSE)
# df_gs_2 <- read.csv("gs_tutoring_2020-08_more.csv", stringsAsFactors = FALSE)
# 
# #Concatenating files and getting relevant columns
# df_gs <- as_tibble(bind_rows(df_gs_1, df_gs_2)) %>% select(c("Last.Name..Apellido",                                                                                                                                                                                                                
#                                                              "First.Name..Primer.Nombre",                                                                                                                                                                                                          
#                                                              "Street.Address..Dirección",                                                                                                                                                                                                          
#                                                              "City..State..Zip.Code.Country..Ciudad..Estado..Código..postal..País.",                                                                                                                                                              
#                                                              "Country.of.Origin..País.de.Nacimiento"))
# 
# names(df_gs) <- c("last_name", "first_name", "address", "location", "country")
# 
# df_gs <- df_gs %>% mutate(name = paste(first_name, last_name)) %>% 
#                    select(-c(last_name, first_name)) %>%
#                    select(name, everything())
# 
# 
# #Payment data without country info
# #-----------------------------------------------------------------------------
# df_pmt_1 <- read.csv("spring_2020_payment_info.csv") %>% select(c("Last.Name","First.Name",
#                                                                   "Date.added.to.Proactive",
#                                                                   "Course", "Returning.Student." )) %>% 
#                                                          mutate(country = NA_character_)
# 
# names(df_pmt_1) <- c("last_name", "first_name", "enroll_date", "course", "returning_student", "country")
# 
# df_pmt_1 <- df_pmt_1 %>% mutate(name=paste(first_name, last_name)) %>% 
#                          select(-c(last_name, first_name)) %>%
#                          select(name, everything())  %>% 
#                          distinct(name, .keep_all = TRUE)
# 
# df_pmt_2 <- read.csv("spring_2020_payment_second_file.csv") %>% select(c("Last.Name","First.Name",
#                                                                          "Registration.Date",
#                                                                          "Course" )) %>% 
#                                                                 mutate(returning_student = NA_character_,
#                                                                        country = NA_character_)
# 
# names(df_pmt_2) <- c("last_name", "first_name", "enroll_date", "course", "returning_student", "country")
# 
# df_pmt_2 <- df_pmt_2 %>% mutate(name=paste(first_name, last_name)) %>% 
#                          select(-c(last_name, first_name)) %>%
#                          select(name, everything()) %>% 
#                          distinct(name, .keep_all = TRUE)
# 
# df_pmt <- as_tibble(bind_rows(df_pmt_1, df_pmt_2)) %>% 
#               distinct(name, .keep_all = TRUE)
# 
# 
# 
# #Bringing it all together
# #-----------------------------------------------------------------------------
# 
# df_all <- as_tibble(bind_rows(df_bb, df_gs, df_pmt)) %>% mutate(name = str_to_upper(name)) %>%
#                     distinct(name, .keep_all = TRUE)
# 
# nrow(df_all)
# 
# 
# #Trying to bring in more country information for previous students
# #Improves it by about 10%, around 120 students out of 800
# 
# df_dem <- read.csv("2000-2019_student-demographics.csv", stringsAsFactors = FALSE) %>% 
#                     mutate(name = str_to_upper(paste(first_name, last_name))) %>%
#                     select(-c(first_name, last_name, zip_code)) %>%
#                     select(name, everything()) %>% distinct(name, .keep_all = TRUE)
# 
# glimpse(df_dem)
# df_better <- left_join(df_all, df_dem, by=c("name")) %>% 
#                 mutate(country = case_when(country.x %in% c("United States", "", NA_character_) &
#                                               !is.na(country.y) ~ country.y,
#                                            TRUE ~ country.x)) %>% 
#                 select(name, address, enroll_date, city, 
#                        state, zip_code, country, location,
#                        course, returning_student) %>% filter(name != "TEST STUDENT")
# 
# 
# 
# 
# #Calculating Number of Students by COUNTRY
# #-----------------------------------------------------------------------------
# df_stats <- df_better %>% mutate(country = str_squish(case_when(str_detect(country, "Bolivia, Plurinational St") ~ "Bolivia",
#                                                                 str_detect(country, "Georgeia") ~"Georgia",
#                                                                 str_detect(country, "Russian Federation") ~ "Russia",
#                                                                 str_detect(country, "Korea, Republic of") ~ "South Korea",
#                                                                 str_detect(country, "Venezuela, Bolivarian Rep") ~ "Venezuela",
#                                                                 country == "" ~ NA_character_,
#                                                                 TRUE ~ country))) 
# 
# 
# 
# #write.csv(df_stats, "virtual-students_locations.csv", row.names = FALSE)
# openxlsx::write.xlsx(df_stats, "virtual-students_locations.xlsx", row.names = FALSE)


df_stats <- read_excel("virtual-students_locations.xlsx")

#Clean Dates
df_stats <- df_stats %>% mutate(enroll_date = parse_date_time(enroll_date, c("Ymd", "dmY", "dmy","dmyHMS"))) %>% 
                         select(-c("location", "course", "returning_student")) %>%
                         mutate(enroll_date = str_squish(str_trunc(as.character(enroll_date), 10,
                                                        side=c("right"), ellipsis = "")),
                                id = seq(1:nrow(df_stats))) %>%
                         select(id, city, state, zip_code, country, enroll_date)

write.csv(df_stats, "all_wec_student_locations_deidentified_2020-03_2021-04.csv", row.names=FALSE)

#Since March 2020 we have had students from at least 43 countries (lots of unknowns)
student_countries <- df_stats %>% group_by(country) %>%
                                  summarize(n_students = n()) %>%
                                  arrange(desc(n_students)) 
        
student_states <- df_stats %>% group_by(state) %>%
                               summarize(n_students = n()) %>%
                               arrange(desc(n_students)) 

#Uncount from tidyr generates rows by count number - perfect for Tableau
counts_by_city <- df_stats %>% group_by(city, zip_code, state, country) %>%
                               summarize(n_students = n()) %>%
                               arrange(desc(n_students)) %>% uncount(n_students) %>%
                               mutate(city = str_replace(city, "do norte", "do Norte")) %>%
                               filter(city != "20008") %>%
                               drop_na(city) 

openxlsx::write.xlsx(counts_by_city, "student_counts_by_city_final.xlsx", row.names = FALSE)

counts_by_zip_code <- df_stats %>% group_by(zip_code) %>%
                                   summarize(n_students = n()) %>%
                                   arrange(desc(n_students))

#-------------------------------------------------------------------------------------------------------
#------------------------------------
#  VOLUNTEER PRE AND DURING PANDEMIC
#-----------------------------------

# Get all volunteer data for 2010 to Present
#---------------------------------------------
#First dataframe, 2010 to Fall 2020
df_v_1 <- read.csv("./WEC/Data/Historical (2006 - 2019)/Volunteers/Output/All Volunteers (Teachers, Tutors, Librarians, Special) from 2006 to Fall 2020_1212 - All Volunteers (Teachers, Tutors, Librarians, Special) from 2006 to Fall 2020_1212.csv",
                   stringsAsFactors = FALSE)

names(df_v_1) <- c("category", "day", "name", "email", "phone", "new_volunteer", "semester", "year",
                   "tutor_type", "class")

a <- df_v_2 %>% filter(year == 2020)

# Volunteer data, Winter 2021
#---------------------------------------------
df_v_2 <- read.csv("./WEC/Data/Current (2020 - Present)/Volunteers/Winter 2021 Volunteers/Output/All WEC Volunteers Winter 2021.csv", stringsAsFactors = FALSE)


# Volunteer data, Spring 2021
#---------------------------------------------
df_am <- read_excel("./WEC/Data/Covid (March 2020 - May 2021)/Volunteer/spring_2021_volunteers.xlsx", sheet = "AM") %>% select(1:8)
names(df_am) <- c("class", "time", "day", "name", "email", "phone", "nickname", "new_volunteer")

df_am <- df_am %>% mutate(class = str_replace(class, "ADDED.*|UPDATED", NA_character_),
                          semester = "SPRING", year = 2021,
                          category = "Teacher") %>%
                   filter(!is.na(time) & name != "SOLO") %>%
                   fill(c(class, day), .direction = "down") %>%
                   mutate(name = str_to_upper(name),
                          #Changing to match previous data and to be clearer and focus on minority (new volunteers)
                          new_volunteer = case_when(str_detect(new_volunteer, "yes|Yes|YES") ~ "No",
                                                    str_detect(new_volunteer, "no|No|NO") ~ "Yes"))
                   
df_pm <- read_excel("./WEC/Data/Covid (March 2020 - May 2021)/Volunteer/spring_2021_volunteers.xlsx", sheet = "PM") %>% select(1:8)
names(df_pm) <- c("class", "time", "day", "name", "email", "phone", "new_volunteer", "nickname")

df_pm <- df_pm %>% mutate(class = str_replace(class, "ADDED.*|Added.*|UPDATED.*", NA_character_),
                          semester = "SPRING", year = 2021, category = "Teacher") %>%
                   filter(!is.na(time) & name != "SOLO" & 
                          !str_detect(day, "PENDING|STATUS|Interview|INTERVIEW")) %>%
                   fill(c(class, day), .direction = "down") %>%
                   mutate(name = str_to_upper(name),
                          #Changing to match previous data and to be clearer and focus on minority (new volunteers)
                          new_volunteer = case_when(str_detect(new_volunteer, "yes|Yes|YES") ~ "No",
                                                    str_detect(new_volunteer, "no|No|NO") ~ "Yes"))

df_tutors <- read_excel("./WEC/Data/Covid (March 2020 - May 2021)/Volunteer/spring_2021_volunteers.xlsx", sheet = "Tutors") %>% select(1:5) 
names(df_tutors) <- c("name",  "day", "time", "email", "new_volunteer")

df_tutors <- df_tutors %>% mutate(semester = "SPRING", year = 2021, category = "Tutor",
                                  #Changing to match previous data and to be clearer and focus on minority (new volunteers)
                                  new_volunteer = case_when(str_detect(new_volunteer, "yes|Yes|YES") ~ "No",
                                                            str_detect(new_volunteer, "no|No|NO") ~ "Yes"),
                                  name = str_to_upper(name))


df_clubs <- read_excel("./WEC/Data/Covid (March 2020 - May 2021)/Volunteer/spring_2021_volunteers.xlsx", sheet = "Clubs") %>% 
                select(c( "Name", "Time", "Day", "Email", "Returning Volunteer?", "Club Name"))
names(df_clubs) <- c("name", "time", "day", "email", "new_volunteer", "club_name")

df_clubs <- df_clubs %>% filter(!is.na(club_name)) %>%
                         mutate(semester = "SPRING", year = 2021, category = "Club",
                                #Changing to match previous data and to be clearer and focus on minority (new volunteers)
                                new_volunteer = case_when(str_detect(new_volunteer, "yes|Yes|YES|Y|y") ~ "No",
                                                          str_detect(new_volunteer, "no|No|NO|n|N") ~ "Yes"),
                                name = str_to_upper(name))

#Bringing all Spring 2021 together
df_v_3 <- as_tibble(bind_rows(df_am, df_pm, df_tutors, df_clubs))

#Bringing it all together
df_v <- bind_rows(df_v_1, df_v_2, df_v_3)

#Saving all volunteer data for other tasks
write.csv(df_v, "/Users/Daniel/Desktop/WEC/Data/All (2006 - Present)/all_volunteers_2006_2021.csv", row.names = FALSE)



#Identify (filter) volunteers who had volunteered between
#first period AND second period
#---------------------------------------------

df_pre <- df_v %>% filter(year < 2020 | (year == 2020 & semester == "WINTER")) %>% 
                   distinct(name)

df_pan <- df_v %>% filter(year == 2021 | (year == 2020 & semester %in% c("SPRING", "SUMMER", "FALL"))) %>%
                   distinct(name)


#Anyone who had previously volunteered with WEC in person and volunteered virtually
# during the pandemic: 183
faithful_vols <- inner_join(df_pre, df_pan, by = c("name"))


#-------------------------------------------------------------------------------------------------------
#------------------------------------
#  VOLUNTEER DATA FOR MAP
#-----------------------------------

#We don't have it : / 
















#12:10 - 2:10 = 2 
#3:30 - 4:30 = 1
#10:40 - 11:40 = 1 

#4 hours

#Sunday
#1:30 - 1:45 = .25
#4:50 - 5:50 = 1 
#7:05 - 8:20 = 1.25
#8:30 - 9:30 = 1 

#3.5 hours


#Monday
#8:05 - 10:35 = 2.5
#10:40 - 11:30 = .75 
#11:50 - 12:45 = 1 

#4.25 hours 

#7.5 hours charged
#4.25 v

