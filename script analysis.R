library(readxl)
library(dplyr)
retail <- read_excel("Data/Online Retail.xlsx")
# Inspect the dataset
head(retail)
str(retail)
dim(retail)
summary(retail) 

# Check missing values
colSums(is.na(retail))

# Check negative quantities
sum(retail$Quantity < 0)

# Check negative prices
sum(retail$UnitPrice < 0)

# Check invoices beginning with "C"
sum(grepl("^C", retail$InvoiceNo))

# Look at some cancelled transactions
retail[grepl("^C", retail$InvoiceNo), ][1:10, ]

# Compare quantities for cancelled and non-cancelled transactions
table(grepl("^C", retail$InvoiceNo), retail$Quantity < 0) 

# Investigate negative quantities without a C invoice number
retail[retail$Quantity < 0 & !grepl("^C", retail$InvoiceNo), ][1:20, ]

# Investigate negative unit prices
retail[retail$UnitPrice < 0, ] 

# Check zero unit prices
sum(retail$UnitPrice == 0)

# Check zero quantities
sum(retail$Quantity == 0)

# Check invoice prefixes
table(substr(retail$InvoiceNo, 1, 1))

# Investigate transactions with zero unit price
retail[retail$UnitPrice == 0, ][1:20, ]

# Count zero-price transactions by invoice type
table(substr(retail$InvoiceNo, 1, 1), retail$UnitPrice == 0)

# Look at descriptions of zero-price transactions
head(unique(retail$Description[retail$UnitPrice == 0]), 30)

# Create cleaned sales dataset
sales <- retail %>%
  filter(
    !grepl("^C", InvoiceNo),
    !grepl("^A", InvoiceNo),
    Quantity > 0,
    UnitPrice > 0
  )
# Check cleaned dataset
dim(sales)
head(sales)
summary(sales)
# retail = original UCI Online Retail dataset
# sales = cleaned dataset used for the statistical analysis
dim(sales)
# Calculate transaction revenue
sales$Revenue <- sales$Quantity * sales$UnitPrice

# Check revenue
summary(sales$Revenue)

# Number of countries
length(unique(sales$Country))

# Number of transactions by country
sort(table(sales$Country), decreasing = TRUE)

# Select UK and Germany transactions
uk_germany <- sales %>%
  filter(Country %in% c("United Kingdom", "Germany"))

# Check the number of transactions in each country
table(uk_germany$Country)

# Descriptive statistics by country
uk_germany %>%
  group_by(Country) %>%
  summarise(
    n = n(),
    mean_revenue = mean(Revenue),
    median_revenue = median(Revenue),
    sd_revenue = sd(Revenue),
    min_revenue = min(Revenue),
    max_revenue = max(Revenue)
  )
# Compare transaction revenue distributions
boxplot(
  Revenue ~ Country,
  data = uk_germany,
  main = "Transaction Revenue: UK vs Germany",
  xlab = "Country",
  ylab = "Revenue (£)"
)
# Compare revenue distributions using a logarithmic scale
boxplot(
  Revenue ~ Country,
  data = uk_germany,
  log = "y",
  main = "Transaction Revenue: UK vs Germany",
  xlab = "Country",
  ylab = "Revenue (£, log scale)"
)
# Histograms of transaction revenue
hist(
  uk_germany$Revenue[uk_germany$Country == "Germany"],
  main = "Germany Transaction Revenue",
  xlab = "Revenue (£)"
)
hist(
  uk_germany$Revenue[uk_germany$Country == "United Kingdom"],
  main = "UK Transaction Revenue",
  xlab = "Revenue (£)"
)
# Q-Q plots for transaction revenue

par(mfrow = c(1, 2))
qqnorm(
  uk_germany$Revenue[uk_germany$Country == "Germany"],
  main = "Q-Q Plot: Germany"
)
qqline(
  uk_germany$Revenue[uk_germany$Country == "Germany"]
)
qqnorm(
  uk_germany$Revenue[uk_germany$Country == "United Kingdom"],
  main = "Q-Q Plot: United Kingdom"
)
qqline(
  uk_germany$Revenue[uk_germany$Country == "United Kingdom"]
)
par(mfrow = c(1, 1))

# Compare variability between countries
var(uk_germany$Revenue[uk_germany$Country == "Germany"])
var(uk_germany$Revenue[uk_germany$Country == "United Kingdom"])

# Create customer-level revenue
customer_revenue <- sales %>%
  filter(
    Country %in% c("United Kingdom", "Germany"),
    !is.na(CustomerID)
  ) %>%
  group_by(Country, CustomerID) %>%
  summarise(
    TotalRevenue = sum(Revenue),
    .groups = "drop"
  )
# Check number of customers by country
table(customer_revenue$Country)

# Descriptive statistics for customer revenue
customer_revenue %>%
  group_by(Country) %>%
  summarise(
    n = n(),
    mean_revenue = mean(TotalRevenue),
    median_revenue = median(TotalRevenue),
    sd_revenue = sd(TotalRevenue),
    min_revenue = min(TotalRevenue),
    max_revenue = max(TotalRevenue)
  )
# Log-transform customer revenue
customer_revenue$LogRevenue <- log(customer_revenue$TotalRevenue)

# Descriptive statistics for log-transformed revenue
customer_revenue %>%
  group_by(Country) %>%
  summarise(
    n = n(),
    mean_log_revenue = mean(LogRevenue),
    median_log_revenue = median(LogRevenue),
    sd_log_revenue = sd(LogRevenue)
  )
# Q-Q plots for log-transformed revenue
par(mfrow = c(1, 2))

qqnorm(
  customer_revenue$LogRevenue[
    customer_revenue$Country == "Germany"
  ],
  main = "Q-Q Plot: Germany (Log Revenue)"
)
qqline(
  customer_revenue$LogRevenue[
    customer_revenue$Country == "Germany"
  ]
)
qqnorm(
  customer_revenue$LogRevenue[
    customer_revenue$Country == "United Kingdom"
  ],
  main = "Q-Q Plot: United Kingdom (Log Revenue)"
)
qqline(
  customer_revenue$LogRevenue[
    customer_revenue$Country == "United Kingdom"
  ]
)
par(mfrow = c(1, 1))

# Boxplot of log-transformed customer revenue
boxplot(
  LogRevenue ~ Country,
  data = customer_revenue,
  main = "Customer Revenue: UK vs Germany",
  xlab = "Country",
  ylab = "Log(Total Revenue)"
)

# Shapiro-Wilk normality tests
shapiro.test(
  customer_revenue$LogRevenue[
    customer_revenue$Country == "Germany"
  ]
)
shapiro.test(
  customer_revenue$LogRevenue[
    customer_revenue$Country == "United Kingdom"
  ]
)
# Variance comparison
var(
  customer_revenue$LogRevenue[
    customer_revenue$Country == "Germany"
  ]
)
var(
  customer_revenue$LogRevenue[
    customer_revenue$Country == "United Kingdom"
  ]
)
var(
  customer_revenue$LogRevenue[
    customer_revenue$Country == "Germany"
  ]
)
# Welch two-sample t-test
test_result <- t.test(
  LogRevenue ~ Country,
  data = customer_revenue,
  var.equal = FALSE
)
test_result

# Difference in mean log revenue
mean(
  customer_revenue$LogRevenue[
    customer_revenue$Country == "Germany"
  ]
) -
  mean(
    customer_revenue$LogRevenue[
      customer_revenue$Country == "United Kingdom"
    ]
  )
# Ratio of geometric mean customer revenue
exp(
  mean(
    customer_revenue$LogRevenue[
      customer_revenue$Country == "Germany"
    ]
  ) -
    mean(
      customer_revenue$LogRevenue[
        customer_revenue$Country == "United Kingdom"
      ]
    )
)
test_result
boxplot(
  LogRevenue ~ Country,
  data = customer_revenue,
  main = "Customer Revenue: Germany vs United Kingdom",
  xlab = "Country",
  ylab = "Log(Total Revenue)"
)

# Final comparison table
customer_revenue %>%
  group_by(Country) %>%
  summarise(
    Customers = n(),
    Mean_Revenue = mean(TotalRevenue),
    Median_Revenue = median(TotalRevenue),
    SD_Revenue = sd(TotalRevenue),
    Mean_Log_Revenue = mean(LogRevenue)
  )

# Difference and ratio of geometric means
mean_difference <- mean(
  customer_revenue$LogRevenue[
    customer_revenue$Country == "Germany"
  ]
) -
  mean(
    customer_revenue$LogRevenue[
      customer_revenue$Country == "United Kingdom"
    ]
  )

geometric_mean_ratio <- exp(mean_difference)

mean_difference
geometric_mean_ratio
mean_difference <- mean(
  customer_revenue$LogRevenue[customer_revenue$Country == "Germany"]
) -
  mean(
    customer_revenue$LogRevenue[customer_revenue$Country == "United Kingdom"]
  )

geometric_mean_ratio <- exp(mean_difference)
mean_difference
geometric_mean_ratio
exp(test_result$conf.int)
final_summary <- customer_revenue %>%
  group_by(Country) %>%
  summarise(
    Customers = n(),
    Mean_Revenue = mean(TotalRevenue),
    Median_Revenue = median(TotalRevenue),
    SD_Revenue = sd(TotalRevenue),
    Mean_Log_Revenue = mean(LogRevenue)
  )

final_summary
write.csv(
  customer_revenue,
  "customer_revenue.csv",
  row.names = FALSE
)


















