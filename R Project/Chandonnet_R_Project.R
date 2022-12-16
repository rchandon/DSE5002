library(dplyr)
library(tidyr)
library(ggplot2)
library(stringr)
library(lubridate)
library(scales)
jobs_data <- read.csv("data.csv")  #read in salary data
colnames(jobs_data)[1] <- "row_num" #fix first column name
# First eliminate all data for jobs that aren't full-time since we want a full-time hire 
jobs_data <- jobs_data[jobs_data$employment_type=="FT",]
# Now create a list of all job title / experience level combos - we can then evaluate
# these combos to narrow the list of titles that would satisfy our hiring need, and the
# salary data to evaluate
jobs_by_title <- jobs_data %>%
  group_by(job_title,experience_level) %>%
  summarize(count = length(row_num)) 
# I don't know whether the company prefers to hire a data engineer first, a data scientist
# first, or someone who can do both.  Based on my research, very senior data scientists
# can do enough data engineering to do get us started with both.  I am also assuming 
# we do not want to start by hiring an AI / Machine learning person first as this is 
# highly specialized and we want to walk before we run.  These assumptions require me
# to break down the data into "specialties" based on their job title/seniority.
# To do this, I exported the "jobs_by_title" table to Excel, researched the different titles 
# as best as I could, and tagged each title with a "speciality" out of:
#                     - Engineering
#                     - Analytics   (generic term for data science)
#                     - Both
#                     - AI
#
# I then saved that as a SCV file called "speciality_data.csv"
# From here, I import that data and use it to "enrich" the jobs data so I can isolate 
# salaries based on the specialization I want to hire in later steps
specialties <- read.csv("specialty_data.csv") # read the file
jobs_data <- left_join(jobs_data,specialties, by="job_title")
# For readability, I want to create better labels for the experience level of each
# job vetted.  I do this with a simple data frame. This will be joined to 
# my imported data when I start analyzing and plotting it
exp_codes <- data.frame(c("EN","MI","SE","EX"),
                                c("Entry-Level / Junior",
                                  "Mid-Level / Intermediate",
                                  "Senior Level / Expert",
                                  "Executive Level / Director"))
colnames(exp_codes) <- c("experience_level","level")

# The first thing I want to do is demonstrate how much salaries have gone up this year
# This section supports first graphic which shows growth in overall salaries 
# in $ and % terms,

# This first section looks at average salaries by year for all jobs
# First aggregate the data by year, calculating average (mean) salary
avg_sal_by_yr <- jobs_data %>%
  group_by(work_year) %>%
  summarize(avg_salary = mean(salary_in_usd)) 
# Now, further calculate annual growth rate% in salary year by year
work_year <- avg_sal_by_yr$work_year
AGR <- c()
for (counter in 1:length(work_year)) {
  ifelse(counter == 1,
         AGR[counter] <= NA,
         AGR[counter] <- avg_sal_by_yr$avg_salary[counter]/
           avg_sal_by_yr$avg_salary[counter-1]-1)
}
# create a data frame of years and AGR%, and then join it to the avg_sal frame
avg_sal_growth <- data_frame(work_year,AGR) #c
avg_sal_by_yr <- left_join(avg_sal_by_yr,avg_sal_growth,by="work_year")
# Now plot the y-o-y change in average salaries
avg_sal_by_yr %>%
  ggplot(aes(x = work_year,
             y = avg_salary
  )) +
  geom_point(size=3) +
  geom_line() +
  xlab("Year") +
  ylab("Average Salary in $USD") +
  ggtitle("Average Salaries for Data Professionals - All Types/Countries") +
  scale_y_continuous(labels = comma) +
  scale_x_continuous(breaks = breaks_pretty(2))
# Now plot the annual growth rate in % terms
avg_sal_by_yr %>%
  ggplot(aes(x = work_year,
             y = AGR
  )) +
  geom_point(size=3) +
  geom_line() +
  xlab("Year") +
  ylab("Annual % Change") +
  ggtitle("Annual Growth in Salaries for Data Professionals - All Types/Countries") +
  scale_y_continuous(labels = percent) +
  scale_x_continuous(breaks = breaks_pretty(2))
#
# Now start breaking it down further:
# First off, I determine based on future growth plans that we only want to hire 
# Senior Level / Expert or Executive Level.  So subset the data for those experience
# levels, aggregate by year and level to recalculate averages, and plot
sr_jobs_data <- jobs_data[jobs_data$experience_level %in% c("SE","EX"),]
sr_jobs_data <- mutate(sr_jobs_data,
                       domicile = ifelse(employee_residence == "US","US-Based","Offshore"))
avg_sal_by_yr_exp <- sr_jobs_data %>%
  group_by(work_year,experience_level,domicile) %>%
  summarize(avg_salary = mean(salary_in_usd)) 

# Now plot this, using the long version of experience codes for readability
avg_sal_by_yr_exp <- left_join(avg_sal_by_yr_exp, exp_codes, by = "experience_level")
avg_sal_by_yr_exp %>%
  ggplot(aes(x = work_year,
             y = avg_salary,
             group = level,
             color = level
  )) +
  geom_point(size=3) +
  geom_line() +
  xlab("Year") +
  ylab("Average Salary in $USD") +
  ggtitle("Average Salaries for SENIOR Data Professionals - By Experience Level") +
  scale_y_continuous(labels = comma) +
  scale_x_continuous(breaks = breaks_pretty(2)) +
  facet_wrap(~domicile)

# Now I want to look at how much difference the individual's "specialty" makes (based 
# on my earlier enrichment, so I need to aggregate the data by that as well and plot it
# separately.   
avg_sal_by_yr_exp_spec <- sr_jobs_data %>%
  group_by(work_year,experience_level,specialty,domicile) %>%
  summarize(avg_salary = mean(salary_in_usd)) 
# Eliminate the AI roles
avg_sal_by_yr_exp_spec <- 
  avg_sal_by_yr_exp_spec[(avg_sal_by_yr_exp_spec$specialty != "AI"),]
# Now plot this, using the long version of experience codes for readability
avg_sal_by_yr_exp_spec <- left_join(avg_sal_by_yr_exp_spec, 
                                    exp_codes, 
                                    by = "experience_level")
avg_sal_by_yr_exp_spec %>%
  ggplot(aes(x = work_year,
             y = avg_salary,
             group = level,
             color = level
  )) +
  geom_point(size=3) +
  geom_line() +
  facet_wrap(specialty~domicile,ncol=2,scales="free_y") +
  xlab("Year") +
  ylab("Average Salary in $USD") +
  ggtitle("Average Salaries for SENIOR Data Professionals - By Experience Level") +
  scale_y_continuous(labels = comma) +
  scale_x_continuous(breaks = breaks_pretty(2))
# Last thing I want to do is to see where the big differences are between US wages
# and offshore wages paid in non-USD enough to justify going offshore.  We really need to
# compare like job titles / experience levels for the same year, so first I summarize 
# by country, job_title and experience
jobs_by_country <- jobs_data %>%
  group_by(employee_residence,salary_currency,job_title,experience_level,work_year) %>%
  summarize(count = length(row_num),
            avg_USD_salary = mean(salary_in_usd),
            avg_salary = mean(salary))
domestic_USD_jobs <- as.data.frame(jobs_by_country[jobs_by_country$employee_residence=="US" &
                                                     jobs_by_country$salary_currency=="USD" &
                                                     jobs_by_country$count>=2,])
domestic_USD_jobs <- select(domestic_USD_jobs,
                            -c(employee_residence,
                               salary_currency,
                               avg_USD_salary))
colnames(domestic_USD_jobs)[5] <- "domestic_salary"
offshore_FX_jobs <- jobs_by_country[jobs_by_country$employee_residence !="US" &
                                      jobs_by_country$salary_currency !="USD" &
                                      jobs_by_country$count>=2,]
colnames(offshore_FX_jobs)[7] <- "FX_salary_converted_USD"
colnames(offshore_FX_jobs)[8] <- "FX_salary"
jobs_that_match <- inner_join(domestic_USD_jobs,
                              offshore_FX_jobs,
                              by=c("job_title","experience_level","work_year"))
jobs_that_match <- jobs_that_match %>%
  mutate(offshore_savings = 1 - FX_salary_converted_USD / domestic_salary,
         exchange_rate = FX_salary / FX_salary_converted_USD)

offshore_savings <- jobs_that_match %>%
  group_by(salary_currency) %>%
  summarize(avg_domestic_salary = mean(domestic_salary),
            avg_offshore_US_salary = mean(FX_salary_converted_USD),
            avg_offshore_savings = mean(offshore_savings),
            avg_exch_rate = mean(exchange_rate)) 
ggplot(offshore_savings,
       aes(x=avg_offshore_savings,
           y=salary_currency,
           fill=salary_currency)) +
  geom_bar(stat="identity") +
  xlab("% Saved by hiring offshore") +
  ylab("Currency used for payment offshore") +
  ggtitle("Empirical Cost Benefit Realized from Offshoring / Paying in FX") +
  labs(fill="Salary Currency") +
  scale_x_continuous(labels = percent)