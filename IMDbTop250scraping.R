# Load the libraries for scraping
library(rvest)
library(xml2)

# Load the libraries for plotting
library(dplyr)
library(ggplot2)



# Read the path to IMDbTop250Movies.html file
file_path <- "/path/to/your/file/IMDbTop250Movies.html" 
imdb_page <- read_html(file_path)



# Scraping movie Titles
titles_html <- html_nodes(imdb_page,'h3.ipc-title__text')
titles_data <- html_text(titles_html)

# Remove the first element (it scraped some useless data)
titles_data <- titles_data[-1]

# Keep only the Top 250 movie names (it scraped some useless data)
titles_data <- head(titles_data, 250)

# Create dataframe
titles_df <-  data.frame(Titles = titles_data)



# Scraping Year, Duration and Category of the movies
description_html <- html_nodes(imdb_page,'.sc-b189961a-8.kLaxqf.cli-title-metadata-item')
description_data <- html_text(description_html)



# ADD MISSING DATA
# Separate data into two parts (we need to add some missing data)
part1 <- description_data[1:180]
part2 <- description_data[181:length(description_data)]

# Add "2006" between 180 and 181
description_data <- c(part1, "2006", part2)

part1 <- description_data[1:237]
part2 <- description_data[238:length(description_data)]

# Add "1995" between 237 and 238
description_data <- c(part1, "1995", part2)

part1 <- description_data[1:252]
part2 <- description_data[253:length(description_data)]

# Add "1963" between 252 and 253
description_data <- c(part1, "1963", part2)

# Fill empty Categories with "Not Rated"
indices_not_rated <- c(60, 79, 84)
description_data[c(indices_not_rated * 3)] <- "Not Rated"



# Separate Year, Duration and Category into 3 columns in a dataframe
n <- length(description_data) / 3
data_matrix <- matrix(description_data, ncol = 3, byrow = TRUE)

# Create dataframe
description_data_df <- as.data.frame(data_matrix, stringsAsFactors = FALSE)

# Name of the columns
colnames(description_data_df) <- c("Year", "Duration", "Category")



# Convert 'Year' column to numeric
description_data_df$Year <- as.numeric(description_data_df$Year)



# Separate Hours and Minutes (original form e.g. 2h 33m)
split_data <- strsplit(description_data_df$Duration, "h |m")

split_data <- lapply(split_data, function(x) {
  x_clean <- gsub("h | m", "", x)
  return(x_clean)
})


# Convert hours and minutes to numeric and add 0 when we have NA
split_data <- lapply(split_data, function(x) {
  if (length(x) == 2) {
    hours <- as.numeric(x[1])
    minutes <- as.numeric(x[2])
  } else if (length(x) == 1 && grepl("h", x)) {
    hours <- as.numeric(gsub("h", "", x))
    minutes <- 0
  } else if (length(x) == 1 && grepl("m", x)) {
    hours <- 0
    minutes <- as.numeric(gsub("m", "", x))
  } else {
    hours <- 0
    minutes <- 0
  }
  return(c(hours = hours, minutes = minutes))
})


# Calculate total Duration (in minutes)
total_duration <- sapply(split_data, function(x) {
  hours <- x["hours"]
  minutes <- x["minutes"]
  total <- hours * 60 + minutes
  return(total)
})

# Update Duration column
description_data_df$Duration <- total_duration

# Correct some details
description_data_df$Duration[200] <- "45"



# Scraping movie Ratings
ratings_html <- html_nodes(imdb_page,'span.ipc-rating-star--base.ipc-rating-star--imdb')
ratings_data <- html_text(ratings_html)


# Keep only Rating number from the original form (original form e.g. 7.3 (2.9M))
clean_ratings <- gsub("\\s*\\(.*\\)", "", ratings_data)

# Create a dataframe
imdb_ratings_df <- data.frame(Ratings = clean_ratings)



# Create a dataframe with columns Title, Year, Duration, Category, Rating
imdb_df <- data.frame(
  Title = titles_df,
  Year = description_data_df$Year,
  Duration = description_data_df$Duration,
  Category = description_data_df$Category,
  Rating = imdb_ratings_df
)

# Write dataframe to CSV
write.csv(imdb_df, file = "imdb_top_250.csv", row.names = FALSE)



# Let's create some plots for some of the data


# A plot for the number of movies per year (from the Top 250 movies)

# Setting plot dimensions
dev.new(width = 12, height = 6)

# Group data by Year and count the movies
grouped_df <- imdb_df %>%
  group_by(Year) %>%
  summarize(movie_count = n())

# Create plot
ggplot(grouped_df, aes(x = Year, y = movie_count)) +
  geom_bar(stat = "identity", fill = "#5b7ff5") +
  labs(title = "Number of Movies per Year",
       x = "Year",
       y = "Number of Movies") +
  theme_minimal()



# A plot for the number of movies per category (from the Top 250 movies)

# Group data by Category and count the movies
grouped_df <- imdb_df %>%
  group_by(Category) %>%
  summarize(movie_count = n())

# Create plot
ggplot(grouped_df, aes(x = Category, y = movie_count)) +
  geom_bar(stat = "identity", fill = "#5b7ff5") +
  labs(title = "Number of Movies per Category",
       x = "Category",
       y = "Number of Movies") +
  theme_minimal()