library(dplyr)
library(readr)
library(tidyr)

#import data
cran_data <- read_csv('data/raw/cran_package_200911.csv', col_names = TRUE)

colnames = c("package", "version","depends", "imports", "suggests", "license", "md5sum", "author", "authors@r", "date/publication", "description", "encoding", "maintainer", "packaged")

# cran_data %>% 
#   select_all(tolower) %>%
#   select(all_of(colnames)) %>% 
#   mutate(imports = gsub("[[:punct:]]", "", import)) %>% 
#   filter(package == 'dbplyr') %>% 
#   View()
# 
# cran_data %>% 
#   filter(Imports %in% 'DBI (>= 1.0.0)')


cran_data <- cran_data %>% 
  select_all(tolower) %>%
  select(all_of(colnames))



# working with datetime

data_split <- cran_data %>% 
  mutate(`date/publication` = lapply(`date/publication`, function(x) trimws(gsub(" UTC$", "", x))),
         published_datetime = paste(unlist((`date/publication`))),
         published_datetime = as.POSIXct(published_datetime , tz='UTC', format = "%Y-%m-%d %H:%M:%S"),
         published_date = as.Date(published_datetime)
  )


# Extract username from the packaged column using ";" as the separator
data_split <- data_split %>% 
  mutate(maintainer_username = sub(".*; ", "", packaged))

# Split the "imports" column into individual package names
# Extract the institution, email and domain from the "maintainer" column
data_split <- data_split %>%
  mutate(
    institution = sub(".*@(.+?)\\..*", "\\1", maintainer),
    domain = sub(".*\\.(.+?)$", "\\1", maintainer),
    domain = gsub(">", "", domain),
    maintainer_email = sub(".*<(.+)>", "\\1", maintainer),
    maintainer_name = gsub("<[^>]+>", "", maintainer)
  )

# split the imports column into individual package name
data_split <- data_split %>%
  # Split the date column to datatime and normal date values
  separate_rows(imports, sep = ", ") %>% 
  mutate(imports = gsub("\\s*\\(>=.*?\\)", "", imports),
         imports = gsub("\\s*\\(>=.*?\\)", "", imports)) # remove version specifications

nrow(data_split) # 90552
nrow(cran_data)

# # split the author column and keep only the names
# data_split <- data_split %>% 
#   separate_rows(author, sep = ",") %>% 
#   mutate(author = gsub("\\s*\\[.*?\\]", "", author), # Remove brackets and their contents
#          author = trimws(author)) #Remove leading/trailing spaces
# 
# data_split <- data_split %>%
#   mutate(author = gsub("\\[aut, cre\\]|\\[cre", "", author))  # Remove "[aut, cre]" and "[cre"

# Remove "[aut, cre]", "[aut]", and "[cet]" from the "author" column
# data_split <- data_split %>%
#   mutate(author = gsub("\\[aut, cre\\]|\\[aut\\]|\\[cet\\]", "", author))  # Remove "[aut, cre]", "[aut]", and "[cet]"
# 
# # Split the "author" column into separate authors
# data_split <- data_split %>%
#   separate_rows(author, sep = ",") %>%
#   mutate(author = trimws(author))  # Remove leading/trailing spaces

# Remove specified author entries and clean the "author" column
data_split <- data_split %>%
  mutate(
    author = gsub("\\[ctb\\]|\\[cph\\]|\\[cre, aut\\]|\\[aut, cre\\]|\\[aut\\]|\\[cet\\]", "", author),
    author = gsub("\\s*,\\s*", ", ", author),  # Remove extra spaces after removal
    author = trimws(author)  # Remove leading/trailing spaces
  )

# Split the "author" column into separate authors
data_split <- data_split %>%
  separate_rows(author, sep = ",") %>%
  mutate(author = trimws(author))  # Remove leading/trailing spaces

data_split <- data_split %>%
  mutate(
    author = gsub("\\s*\\([^)]*\\)", "", author),  # Remove anything within parentheses
    author = gsub("\\s*,\\s*", ", ", author),  # Remove extra spaces after removal
    author = trimws(author)  # Remove leading/trailing spaces
  )


## Split the "depends" column into individual dependency values
data_split <- data_split %>% 
  separate_rows(depends, sep = ", ") #%>%
#filter(!grepl("^R \\(>=", depends))


## Replace NA values in imports with values from depends
data_split <- data_split %>% 
  mutate(imports = ifelse(imports == "" | is.na(imports), depends, imports))


nrow(data_split) #406714 #342245

processed_df <- data_split %>% 
  select(package, version, depends,imports, license, md5sum, author, description, encoding, maintainer_username, maintainer_name,  maintainer_email, institution, domain, published_date, published_datetime)


readr::write_csv(processed_df, "data/processed/cran_process_data.csv")


## Replace NA values in imports with values from depends
processed_df %>% 
  mutate(imports = ifelse(imports == "" | is.na(imports), depends, imports)) %>% 
  #filter(package == 'ABACUS') %>% 
  head(n = 1000) %>% 
  View()

# data_split %>% 
#   mutate(
#     email = sub(".*<(.+)>", "\\1", maintainer),
#     institution = sub(".*@(.+?)\\..*", "\\1", maintainer),
#     domain = sub(".*\\.(.+?)$", "\\1", maintainer),
#     name = sub("(.+?) <", "\\1", maintainer)
#   ) %>% 
#   head(1000) %>% 
#   View()
