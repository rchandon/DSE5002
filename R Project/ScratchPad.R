# Last thing I want to do is to see if there is an appreciable difference between
# offshore wages and US wages, enough to justify going offshore.  We really need to
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
            ggtitle("Empirical Cost Benefit Realized from Offshoring ") +
            labs(fill="Salary Currency") +
            scale_x_continuous(labels = percent)

