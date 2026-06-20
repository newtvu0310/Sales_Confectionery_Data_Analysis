rm(list = ls())

library(readxl)
library(tidyverse)  #helps wrangle data
# Use the conflicted package to manage conflicts
library(conflicted)
library(ggplot2)
# Set dplyr::filter and dplyr::lag as the default choices
conflict_prefer("filter", "dplyr")
conflict_prefer("lag", "dplyr")

library(scales)
library(lubridate)


sample_data <- read_excel("C:/Users/Admin/Downloads/C&O_Recruitment test case_Oct 2025.xlsx",sheet = "Sample", skip = 7)
View(sample_data)


## SALE ANALYSIS
sale_corrected <- sample_data %>%
  filter(Transaction_type == "Sales") %>%
  mutate(
    Expected_Value = Quantity * Price,
    Error_Ratio = abs(Total_Value - Expected_Value) / pmax(abs(Total_Value), abs(Expected_Value), 1),
    Is_Extreme_Error = if_else(Error_Ratio > 0.10, TRUE, FALSE),
    Price_Corrected = if_else(Is_Extreme_Error == TRUE & Quantity != 0,
                              Total_Value / Quantity, Price)) %>%
  mutate(Price = Price_Corrected) 

count_fixed <- sum(sale_corrected$Is_Extreme_Error, na.rm = TRUE)
print(paste("Number of rows fixed:", count_fixed))

view(sale_corrected)

sale_corrected_final <- sale_corrected %>%
  select(-Expected_Value, -Error_Ratio, -Is_Extreme_Error, -Price_Corrected)

summary(sale_corrected_final)

data_corrected <- sample_data %>%
  mutate(
    Expected_Value = Quantity * Price,
    Error_Ratio = abs(Total_Value - Expected_Value) / pmax(abs(Total_Value), abs(Expected_Value), 1),
    Is_Extreme_Error = if_else(Error_Ratio > 0.10, TRUE, FALSE),
    Price_Corrected = if_else(Is_Extreme_Error == TRUE & Quantity != 0,
                              Total_Value / Quantity, Price)) %>%
  mutate(Price = Price_Corrected)
summary(data_corrected)

# TOTAL VALUE SEGMENTATION
summary(sale_corrected_final$Total_Value)

Q1_total_val <- 1.303e+06 
Q3_total_val<- 5.180e+07
IQR_Value <- Q3_total_val - Q1_total_val 

# Define Outliers
upper_threshold <- Q3_total_val + 1.5 * IQR_Value
lower_threshold <- Q1_total_val - 1.5 * IQR_Value
print(paste("upper threshold:", format(round(upper_threshold, 0), big.mark = ",")))
print(paste("lower threshold:", format(round(lower_threshold, 0), big.mark = ",")))
# Count Outliers
outliers_total_value <- sale_corrected_final %>%
  filter(Total_Value < lower_threshold |
         Total_Value > upper_threshold)
view(outliers_total_value)

Total_val_no_outlier<- sale_corrected_final %>%
  filter(Total_Value >= lower_threshold,
         Total_Value <= upper_threshold)
describe(Total_val_no_outlier$Total_Value)

N_outliers <- nrow(outliers_total_value)

print(paste("Number of outliers:", N_outliers))

# Box plot of total value
Total_val_no_outlier %>%
  ggplot(aes(y = Total_Value)) +
  
  geom_boxplot(
    fill = "blue",
    color = "navy",
    width = 0.5,
    outlier.color = "red",
    outlier.shape = 8) +
  
  labs(
    title = "Total value distribution without outliers",
    y = "Total Value",
    x = "") +
  scale_y_continuous(
    labels = scales::label_number(scale = 1/1000000, suffix = "M")) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.text.x = element_blank())

view(Total_val_no_outlier)

df_simple_bar <- Total_val_no_outlier %>%
  mutate(
    Date = as.Date(Date),
    Month_Date = floor_date(Date, "month")
  ) %>%
  filter(Month_Date >= as.Date("2022-07-01")) %>%
  group_by(Month_Date) %>%
  summarise(
    Total_Revenue = sum(Total_Value, na.rm = TRUE),
    .groups = "drop")

simple_bar_chart <- ggplot(df_simple_bar, aes(x = Month_Date, y = Total_Revenue)) +
  

  geom_col(fill = "navy", width = 20) +
  
  
  geom_text(
    aes(label = format(round(Total_Revenue / 1000000, 0), big.mark = ",")),
    vjust = -0.5,       
    size = 3.5,       
    fontface = "bold", 
    color = "black") +
  
  scale_y_continuous(
    labels = scales::label_number(scale = 1/1000000, suffix = " M"),
    expand = expansion(mult = c(0, 0.1)) ) +

  scale_x_date(date_breaks = "1 month", date_labels = "%m-%Y") +
  labs(
    title = " Total Revenue in Standard Segment",
    subtitle = "Millions",
    x = "Time",
    y = "Total Revenue") +
  
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
    plot.subtitle = element_text(hjust = 0.5, color = "gray50"),
    axis.title = element_text(face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank())


print(simple_bar_chart)


df_mom_chart <- Total_val_no_outlier %>%
  mutate(
    Date = as.Date(Date),
    Month_Date = floor_date(Date, "month")) %>%
  filter(Month_Date >= as.Date("2022-07-01")) %>%
  group_by(Month_Date) %>%
  summarise(
    Net_Revenue = sum(Total_Value, na.rm = TRUE),
    .groups = "drop") %>%
  mutate(
    MoM_Growth = (Net_Revenue / lag(Net_Revenue) - 1) * 100,
    Growth_Color = ifelse(MoM_Growth >= 0, "Positive", "Negative")) %>%
  filter(!is.na(MoM_Growth))

# LINE CHART GROWTH
mom_chart <- ggplot(df_mom_chart, aes(x = Month_Date, y = MoM_Growth)) +
  
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50", size = 0.8) +
  
 
  geom_line(color = "black", size = 1.2, group = 1) +
  

  geom_point(aes(color = Growth_Color), size = 4) +
  
  
  geom_text(
    aes(label = paste0(round(MoM_Growth, 1), "%"), 
        color = Growth_Color),
    vjust = -1, 
    size = 3.5, fontface = "bold", show.legend = FALSE) +
  
  scale_color_manual(values = c("Positive" = "forestgreen", "Negative" = "red")) +
  scale_y_continuous(
    labels = scales::label_number(suffix = "%"),

    expand = expansion(mult = c(0.1, 0.2))) +
  
  scale_x_date(date_breaks = "1 month", date_labels = "%m-%Y") +
  labs(
    title = "Total Revenue MoM Growth Rate",
    subtitle = "Compare % change in the previous month",
    x = "Time",
    y = "Growth Rate (%)",
    color = "Status"
  ) +
  
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
    plot.subtitle = element_text(hjust = 0.5, color = "gray50"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "top")

print(mom_chart)


# CREATE HIGH-VALUE CUSTOMER LIST
list_outlier_customers <- unique(outliers_total_value$Customer_code)


print(paste("Number of customers with high value order:", length(list_outlier_customers)))

# CUSTOMER BEHAVIOR ANALYSIS
customer_history <- sale_corrected_final %>%
  filter(Customer_code %in% list_outlier_customers) %>%
  group_by(Customer_code) %>%
  summarise(
    Total_Transactions = n(), 
    Lifetime_Value = sum(Total_Value, na.rm = TRUE),
    Last_Purchase_Date = max(as.Date(Date)),
    Outlier_Transactions = sum(Total_Value > upper_threshold),
    .groups = "drop") %>%
  mutate(
    Customer_Type = ifelse(Total_Transactions > 1, "Recurring", "One-off")) %>%
  arrange(desc(Lifetime_Value))

print(head(customer_history, 10))

view(customer_history)

# CREATE PLOT FOR HIGH-VALUE CUSTOMER
p1 <- ggplot(outliers_total_value, aes(x = as.Date(Date), y = Total_Value)) +
  geom_point(color = "red", alpha = 0.6, size = 3) +
  scale_y_continuous(labels = label_number(scale = 1/1000000, suffix = "M")) +
  scale_x_date(date_breaks = "1 month", date_labels = "%m-%Y") +
  labs(
    title = "Distribution of exceptional orders over time",
    x = "Time",
    y = "Order Value"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

#NUMBER OF RECURRING AND ONE-OFF
p2 <- ggplot(customer_history, aes(x = Customer_Type, fill = Customer_Type)) +
  geom_bar() +
  geom_text(stat='count', aes(label=..count..), vjust=-0.5, fontface = "bold") +

  scale_fill_manual(values = c("orange", "navy")) + 

labs(
  title = "Outlier Customer Profile: One-off vs. Recurring",
  subtitle = "Number of customers with high-value transactions",
  x = "Customer Type",
  y = "Count of Customers"
) +
  theme_minimal() +
  theme(legend.position = "none")

print(p1)
print(p2)


#TOP PRODUCTS
top5_products_list <- sale_corrected_final %>%
  filter(Transaction_type == "Sales") %>%
  group_by(Product_Name) %>%
  summarise(Total_Revenue = sum(Total_Value, na.rm = TRUE)) %>%
  arrange(desc(Total_Revenue)) %>%
  slice(1:5) %>%
  pull(Product_Name)

print(top5_products_list)

#PLOT FOR TOP PRODUCTS
top5_trend <- sale_corrected_final %>%
  filter(
    Product_Name %in% top5_products_list, 
    Transaction_type == "Sales",
    Date >= as.Date("2022-07-01")) %>%
  mutate(Month_Date = floor_date(as.Date(Date), "month")) %>%
  group_by(Product_Name, Month_Date) %>%
  summarise(Monthly_Revenue = sum(Total_Value, na.rm = TRUE), .groups = "drop")

peak_time_analysis <-top5_trend %>%
  group_by(Product_Name) %>%
  filter(Monthly_Revenue == max(Monthly_Revenue)) %>%
  select(Product_Name, Month_Date, Monthly_Revenue) %>%
  arrange(desc(Monthly_Revenue))

trend_plot <- ggplot(top5_trend, aes(x = Month_Date, y = Monthly_Revenue, color = Product_Name)) +
  
  geom_line(linewidth = 1) + 
  geom_point(size = 2) +
  
  geom_point(data = peak_time_analysis, aes(x = Month_Date, y = Monthly_Revenue), 
             color = "black", shape = 1, size = 4, stroke = 1.5) + # Vòng tròn đen quanh đỉnh
  
  scale_y_continuous(labels = scales::label_number(scale = 1/1000000, suffix = " M")) +
  scale_x_date(date_breaks = "1 month", date_labels = "%b-%Y") +
  
  labs(
    title = "Top 5 Best-Selling Products: Revenue Trend",
    subtitle = "Black circles indicate the peak sales month for each product",
    x = "Timeline",
    y = "Monthly Revenue",
    color = "Product Name") +
  
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom",
    panel.grid.minor = element_blank())

print(trend_plot)

# Market distribution of top products
market_breakdown <- sale_corrected_final %>%
  filter(
    Transaction_type == "Sales",
    Product_Name %in% top5_products_list) %>%
  group_by(Product_Name, Region) %>%
  summarise(
    Revenue = sum(abs(Total_Value), na.rm = TRUE),
    .groups = "drop") %>%
  group_by(Product_Name) %>%
  mutate(Percent_Share = Revenue / sum(Revenue))

# STACKED BAR CHART (PRODUCT X REGION)
plot_product_market <- ggplot(market_breakdown, aes(x = Product_Name, y = Revenue, fill = Region)) +
  

  geom_col(position = "fill", width = 0.6) +
  
  geom_text(
    aes(label = ifelse(Percent_Share > 0.05, percent(Percent_Share, accuracy = 1), "")), 
    position = position_fill(vjust = 0.5),
    size = 3.5,
    color = "white",
    fontface = "bold") +
  
  scale_y_continuous(labels = percent_format()) +
  
  labs(
    title = "Market Distribution of Top 5 Products",
    subtitle = "Which Region consumes the most of our best-sellers?",
    x = "Top Products",
    y = "Revenue Share (%)",
    fill = "Region") +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    axis.text.x = element_text(face = "bold"),
    legend.position = "bottom")

print(plot_product_market)

# FIND OUT THE CHEAPEST MANUFACTURER
manufacturer_analysis <- sale_corrected_final %>%
  filter(
    Transaction_type == "Sales",
    Product_Name %in% top5_products_list,
    abs(Quantity) > 0) %>%
  group_by(Product_Name, Manufacturer) %>%
  summarise(
    Avg_Unit_Price = sum(abs(Total_Value)) / sum(abs(Quantity)),
    Total_Quantity = sum(abs(Quantity)),
    .groups = "drop") %>%
  group_by(Product_Name) %>%
  mutate(
    Is_Cheapest = if_else(Avg_Unit_Price == min(Avg_Unit_Price), "YES (Cheapest)", "No"),
    Is_Main_Source = if_else(Total_Quantity == max(Total_Quantity), "YES (Main Source)", "No")) %>%
  arrange(Product_Name, Avg_Unit_Price)

print(manufacturer_analysis)

#PLOT FOR CHEAPEST MANUFACTURER
multi_source_products <- manufacturer_analysis %>%
  group_by(Product_Name) %>%
  filter(n() > 1) 

if(nrow(multi_source_products) > 0) {
  plot_manufacturer <- ggplot(multi_source_products, 
                              aes(x = Total_Quantity, y = Avg_Unit_Price, color = Manufacturer)) +
    geom_point(size = 5, alpha = 0.8) +
    
    geom_text(aes(label = paste(Is_Cheapest, "\n", Is_Main_Source)), 
              vjust = 1.5, size = 3, check_overlap = TRUE) +
    
    facet_wrap(~Product_Name, scales = "free") +
    
    scale_x_continuous(labels = comma_format()) +
    scale_y_continuous(labels = comma_format()) +
    
    labs(
      title = "Manufacturer Selection: Price vs. Volume",
      subtitle = "Are we buying the most volume from the cheapest manufacturer?",
      x = "Total Volume (Quantity)",
      y = "Average Unit Price") +
    theme_minimal() +
    theme(legend.position = "bottom")
  
  print(plot_manufacturer)
} else {
  print("The product has just 1 manufacturer")
}

products_to_plot <- unique(manufacturer_analysis$Product_Name)

for (prod in products_to_plot) {
  
  single_prod_data <- manufacturer_analysis %>% 
    filter(Product_Name == prod)
  
  p <- ggplot(single_prod_data, aes(x = Total_Quantity, y = Avg_Unit_Price, color = Manufacturer)) +
    
   
    geom_point(size = 6, alpha = 0.8) +
    
    geom_text(
      aes(label = paste(Manufacturer, "\n", Is_Cheapest, "\n", Is_Main_Source)), 
      vjust = -0.5,
      size = 3.5, 
      fontface = "bold",
      check_overlap = FALSE) +
    
    scale_x_continuous(labels = comma_format(), expand = expansion(mult = c(0.2, 0.2))) +
    scale_y_continuous(labels = comma_format(), expand = expansion(mult = c(0.2, 0.2))) +
    
    labs(
      title = paste("Manufacturer Analysis:", prod), 
      subtitle = "Comparison of Price vs. Volume supplied",
      x = "Total Volume (Quantity)",
      y = "Average Unit Price"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(face = "bold", size = 14, color = "navy"),
      legend.position = "none")
  
  print(p)
}


geo_performance <- sale_corrected_final %>%
  filter(Transaction_type == "Sales") %>%
  rename(Province = `City/Province`) %>% 
  group_by(Province, Region) %>%
  summarise(
    Total_Revenue = sum(Total_Value, na.rm = TRUE),
    Total_Orders = n(),
    .groups = "drop") %>%
  arrange(desc(Total_Revenue)) %>%
  slice(1:10)


plot_province <- ggplot(geo_performance, aes(x = reorder(Province, Total_Revenue), y = Total_Revenue)) +
  geom_col(fill = "navy", width = 0.7) + 
  
  geom_text(
    aes(label = format(round(Total_Revenue / 1000000000, 1), nsmall = 1)), 
    hjust = -0.2, size = 3.5, fontface = "bold") +
  
  scale_y_continuous(labels = scales::label_number(scale = 1/1000000000, suffix = " B"), expand = expansion(mult = c(0, 0.15))) +
  coord_flip() +
  
  labs(
    title = "Top 10 Provinces by Revenue",
    subtitle = "Key markets driving the business performance",
    x = "Province",
    y = "Total Revenue") +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    axis.text.y = element_text(face = "bold"))

print(plot_province)

view(sale_corrected_final)

## COST ANALYSIS
check_negative_cost <- data_corrected %>%
  filter(Total_Cost_Transportation < 0) %>%
  group_by(Transaction_type) %>%
  summarise(
    Count = n(),
    Mean_Cost = mean(Total_Cost_Transportation),
    Min_Cost = min(Total_Cost_Transportation))
print(check_negative_cost)

summary(data_corrected$Total_Value)

data_for_cost_analysis <- data_corrected %>%
  mutate(
    Abs_Value = abs(Total_Value),
    Abs_Cost  = abs(Total_Cost_Transportation),
    
    Real_Ratio = if_else(Abs_Value == 0, 0, Abs_Cost / Abs_Value)) %>%
  
  mutate(
    Total_Cost_Transportation_Cleaned = case_when(
      Transaction_type == "Free Sample/Gift" & Abs_Cost > 1000000 ~ NA_real_, # Lớn hơn 1 triệu -> Lỗi
      Transaction_type == "Free Sample/Gift" ~ Abs_Cost, # Còn lại -> Giữ (đã chuyển thành Dương)
      (Real_Ratio > 0.1 & Abs_Value > 3.547e+07 ) ~ NA_real_,
      TRUE ~ Abs_Cost)) %>%
  as_tibble()

# CHECK FOR RESULT
summary_report <- data_for_cost_analysis %>%
  group_by(Transaction_type) %>%
  summarise(
    Original_Count = n(),
    Valid_Obs = sum(!is.na(Total_Cost_Transportation_Cleaned)),
    Avg_Clean_Cost = mean(Total_Cost_Transportation_Cleaned, na.rm = TRUE),
    Max_Clean_Cost = max(Total_Cost_Transportation_Cleaned, na.rm = TRUE),
    Min_Clean_Cost = min(Total_Cost_Transportation_Cleaned, na.rm = TRUE))

print(summary_report)

# DOUBLE CHECK FOR COST
health_check_sales <- data_for_cost_analysis %>% 
  filter(Transaction_type == "Sales" & !is.na(Total_Cost_Transportation_Cleaned)) %>%
  summarise(
    Avg_Revenue = mean(Abs_Value, na.rm = TRUE),
    Avg_Cost = mean(Total_Cost_Transportation_Cleaned, na.rm = TRUE),
    Avg_Cost_Ratio = sum(Total_Cost_Transportation_Cleaned) / sum(Abs_Value))

print(health_check_sales)

gift_reversals <- data_corrected %>%
  filter(
    Transaction_type == "Free Sample/Gift",
    Quantity < 0) %>%
  group_by(Product_Name) %>%
  summarise(
    Reversal_Count = n(), 
    Total_Reversed_Qty = sum(abs(Quantity)),
    .groups = "drop") %>%
  arrange(desc(Total_Reversed_Qty))

print("TOP RETURN SAMPLE/GIFT")
print(head(gift_reversals, 10))


top_returned_products <- data_corrected %>%
  filter(Transaction_type == "Return") %>%
  group_by(Product_Name) %>%
  summarise(
    Return_Txn_Count = n(), # Số lần bị trả
    Total_Returned_Qty = sum(abs(Quantity), na.rm = TRUE),
    Total_Returned_Value = sum(abs(Total_Value), na.rm = TRUE),
    .groups = "drop") %>%
  arrange(desc(Total_Returned_Qty)) 

print("TOP 10 RETURN PRODUCT")
print(head(top_returned_products, 10))


# PLOT FOR RETURN PRODUCT
plot_return <- ggplot(head(top_returned_products, 10), 
                      aes(x = reorder(Product_Name, Total_Returned_Qty), y = Total_Returned_Qty)) +
  geom_col(fill = "orange") + # Màu đỏ cảnh báo
  coord_flip() + # Xoay ngang
  labs(
    title = "Top 10 Most Returned Products",
    subtitle = "Based on Total Returned Quantity",
    x = "Product Name",
    y = "Total Quantity Returned"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold"))

print(plot_return)

# PRODUCT THAT NEED TO STOP SELLING
product_sales_stats <- data_corrected %>%
  filter(Transaction_type == "Sales") %>%
  group_by(Product_Name) %>%
  summarise(
    Total_Sales_Value = sum(abs(Total_Value), na.rm = TRUE),
    .groups = "drop")

top_returned_products <- data_corrected %>%
  filter(Transaction_type == "Return") %>%
  group_by(Product_Name) %>%
  summarise(
    Return_Txn_Count = n(),
    
    Total_Returned_Qty = sum(abs(Quantity), na.rm = TRUE),
    Total_Returned_Value = sum(abs(Total_Value), na.rm = TRUE),
    .groups = "drop") %>%
  
  left_join(product_sales_stats, by = "Product_Name") %>%
  
  mutate(
    Total_Sales_Value = coalesce(Total_Sales_Value, 0),
    Return_Rate_Pct = if_else(Total_Sales_Value == 0, 0, (Total_Returned_Value/Total_Sales_Value)*100)) %>%
arrange(desc(Total_Returned_Qty)) 



print(head(top_returned_products, 10))
view(top_returned_products)

# FILTER OUT THE PRODUCT THAT HAVE HIGH RETURN NO SALE
final_product_review <- top_returned_products %>%
  mutate(
    Category = case_when(
      Return_Rate_Pct > 100 ~ "Outlier (Low Sales Volume)",
      Return_Rate_Pct > 20  ~ "Critical Quality Issue",
      Return_Rate_Pct > 5   ~ "Warning",
      TRUE ~ "Safe"))

# BAD PRODUCT THAT HAVE HIGH RETURN
real_problems <- final_product_review %>%
  filter(Category == "Critical Quality Issue") %>%
  select(Product_Name, Total_Returned_Value, Total_Sales_Value, Return_Rate_Pct) %>%
  arrange(desc(Return_Rate_Pct))

print(real_problems)

#PLOT FOR PRODUCT NEED TO STOP SELLING
plot_data <- final_product_review %>%
  filter(Category == "Critical Quality Issue") %>%
  mutate(Product_Name = reorder(Product_Name, Return_Rate_Pct))

plot_critical <- ggplot(plot_data, aes(x = Return_Rate_Pct, y = Product_Name)) +

  geom_col(fill = "navy", width = 0.7) +

  geom_text(
    aes(label = paste0(round(Return_Rate_Pct, 1), "%")), 
    hjust = -0.1,
    size = 3.5, 
    fontface = "bold") +

  scale_x_continuous(
  
    expand = expansion(mult = c(0, 0.15)) ) +

  labs(
    title = "CRITICAL QUALITY ISSUES: High Return Rate Products",
    subtitle = "Products with Return Rate between 20% - 100% (Need Immediate Review)",
    x = "Return Rate % (Returned Value / Sales Value)",
    y = "Product Name") +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14, color = "navy"),
    axis.text.y = element_text(face = "bold"),
    panel.grid.major.y = element_blank()) 

print(plot_critical)


channel_ranking <- data_corrected %>%
  filter(Transaction_type == "Sales") %>%
  group_by(Channel) %>%
  summarise(
    Total_Revenue = sum(abs(Total_Value), na.rm = TRUE),
    .groups = "drop") %>%
  arrange(desc(Total_Revenue)) %>%
  mutate(
    Revenue_Share = Total_Revenue / sum(Total_Revenue))


print(channel_ranking)


plot_channel <- ggplot(channel_ranking, aes(x = reorder(Channel, Total_Revenue), y = Total_Revenue)) +
  geom_col(fill = "navy", width = 0.6) +
  geom_text(aes(label = paste0(round(Revenue_Share * 100, 1), "%")), 
            hjust = -0.2, size = 4, fontface = "bold") +
  scale_y_continuous(labels = label_number(scale = 1/1000000000, suffix = "B")) + # Đơn vị Tỷ
  coord_flip() +
  labs(
    title = "Top Sales Channels by Revenue",
    subtitle = "Which channel is the main revenue driver?",
    x = "Channel",
    y = "Total Revenue (Billion VND)"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14))

print(plot_channel)


channel_segment_matrix <- sample_data %>%
  filter(Transaction_type == "Sales") %>%
  group_by(Channel, Segment) %>%
  summarise(
    Total_Revenue = sum(abs(Total_Value), na.rm = TRUE),
    .groups = "drop") %>%
  mutate(Share_of_Total = Total_Revenue / sum(Total_Revenue))


plot_matrix <- ggplot(channel_segment_matrix, aes(x = Segment, y = Channel, fill = Total_Revenue)) +
  

  geom_tile(color = "white") +
  
  scale_fill_gradient(low = "orange", high = "forestgreen", 
                      labels = label_number(scale = 1/1000000000, suffix = "B")) +
  
  geom_text(aes(label = paste0(round(Total_Revenue / 1000000000, 1), "B\n(", 
                               round(Share_of_Total * 100, 1), "%)")), 
            size = 3.5, fontface = "bold") +
  
  labs(
    title = "Revenue Matrix: Channel vs. Segment",
    subtitle = "Identify the 'Golden Combination' (Highest Revenue Cell)",
    x = "Customer Segment",
    y = "Sales Channel",
    fill = "Revenue") +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid = element_blank())

print(plot_matrix)

data_corrected %>%
  filter(Transaction_type == "Sales") %>% 
  group_by(Domestic_export) %>%
  summarise(Total_Revenue = sum(abs(Total_Value), na.rm = TRUE)) %>% 
  mutate(Share = Total_Revenue / sum(Total_Revenue)) %>% 
  

  ggplot(aes(x = reorder(Domestic_export, -Total_Revenue), y = Total_Revenue, fill = Domestic_export)) +
  geom_col(width = 0.5) +
  scale_fill_manual(values = c("Domestic" = "navy", "Export" = "darkorange")) + 
  geom_text(aes(label = paste0(round(Share * 100, 1), "%")), 
            vjust = -0.5, size = 5, fontface = "bold") +
  scale_y_continuous(labels = label_number(scale = 1/1000000000, suffix = "B")) +
  labs(
    title = "Market Structure: Domestic vs. Export",
    subtitle = "Based on Total Revenue",
    x = "Market Type",
    y = "Total Revenue") +
  theme_minimal() +
  theme(legend.position = "none", plot.title = element_text(face="bold"))
