##For my LEGO business research I need to plot the average number of parts in LEGO sets over 
##the years (starting with whatever year this dataset starts and ending in whatever year this dataset ends)

##I need this to see if the sets have gotten more complex or less complex over the years.

library(readr)
library(ggplot2)
library(dplyr)

##Load the data
sets <- read_csv("sets.csv")

##Lets take a look at the structure
str(sets)
colnames(sets)

##Lets order the years from oldest to newest 
sets <- sets[order(sets$year),]

##Look at first five rows 
head(sets)

##Group by year, average the number of pieces in a set
avg_set <- sets %>% 
  group_by(year) %>% 
  summarise(avg_pieces = mean(num_parts, na.rm = T))

##Basic plot 
plot(avg_set$year, avg_set$avg_pieces)

##ggplot
ggplot(avg_set, aes(x = year, y = avg_pieces)) + 
  geom_point(color = 'darkred') + 
  geom_smooth(method = lm, se = FALSE, linewidth = 0.5)+ 
  theme_minimal() + 
  labs(title = 'Average Number of Lego Pieces by Year', x = 'Year', 
       y = 'Average Pieces in a Set') + 
  theme(plot.margin = margin(10,10,10,10, 'pt'))

##On average, how many colors were in a set at the beginning? As the sets got slowly bigger over time, 
##how did that  impact the colors in sets as time progressed? Bonus points. Make this data visualization 
##colorful and beautiful.
inventory_parts <- read.csv('inventory_parts.csv')
inventories <- read.csv('inventories.csv')
colors <- read.csv('colors.csv')

# Merge datasets, remove duplicates, and compute number of colors
result <- inventory_parts %>%
  left_join(inventories, by = c("inventory_id" = "id")) %>%
  left_join(sets, by = "set_num") %>%
  distinct(set_num, name, color_id, year) %>%
  group_by(set_num, name, year) %>%
  summarise(Number_of_Colors = n(), .groups = "drop")

##Order by year
result <- result[order(result$year),]

##Group number of colors by year
avg_color_year <- result %>% 
  group_by(year) %>% 
  summarise(avg_color = mean(Number_of_Colors, na.rm = T))

######Lets add the most used color per year to the dataset
# Merge the datasets
merged_data <- inventory_parts %>%
  left_join(inventories, by = c("inventory_id" = "id")) %>%
  left_join(sets, by = "set_num") %>%
  left_join(colors, by = c("color_id" = "id"))

# Group by year and color, summing up the quantities
color_counts_per_year <- merged_data %>%
  group_by(year, name.y) %>%
  summarise(total_quantity = sum(quantity, na.rm = TRUE), .groups = "drop")

# Determine the most used color for each year
most_used_color_per_year <- color_counts_per_year %>%
  arrange(year, desc(total_quantity)) %>%
  group_by(year) %>%
  slice_head(n = 1) %>%
  ungroup()

# Renaming columns for clarity
colnames(most_used_color_per_year) <- c('Year', 'Most Used Color', 'Total Quantity')

head(most_used_color_per_year)

###Add to avg_color_year dataset
avg_color_year$most_used_color <- most_used_color_per_year$`Most Used Color`

# Create a named vector of RGB values
color_mapping <- setNames(paste0("#", colors$rgb), colors$name)

# Plot with custom color mapping
ggplot(avg_color_year, aes(x = year, y = avg_color, color = most_used_color)) + 
  geom_point() +
  labs(title = "Average Number of Colors per Year",
       subtitle = "Points colored by the most used color each year",
       x = "Year",
       y = "Average Number of Colors") +
  scale_color_manual(values = color_mapping, name = "Most Used Color")

##Stakeholder: Which are the top 3 rarest colors? 
# Count occurrences of each color in inventory_parts
color_counts <- as.data.frame(table(inventory_parts$color_id))
colnames(color_counts) <- c('id', 'count')

# Merge with colors dataframe to get color names
merged_df <- merge(color_counts, colors, by = 'id', all.x = TRUE)

# Sort by count to get the rarest colors
rarest_colors <- head(merged_df[order(merged_df$count),], 3)

print(rarest_colors[,c('name', 'count')])

##Stakeholder: Which lego set is the most complex? aka has the most steps in the manual

##Stakeholder: which set has the highest number of pieces? what is its name, theme, year of release, cost?
themes <- read.csv('themes.csv')

# Finding the set with the highest number of pieces
most_complex_set <- sets[which.max(sets$num_parts),]

# Merging with themes to get the theme name
most_complex_set_theme <- merge(most_complex_set, themes, by.x = 'theme_id', by.y = 'id')

# Extracting relevant information
result <- most_complex_set_theme[, c('name.x', 'name.y', 'year', 'num_parts')]
colnames(result) <- c('Set Name', 'Theme', 'Year of Release', 'Number of Pieces')

# Display the result
print(result)
