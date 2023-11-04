library(dplyr)
library(readr)
library(tidyr)
library(tidyverse)

#import data
#cran_data2 <- read_csv('data/raw/cran_package_200911.csv', col_names = TRUE)

pkg_df <- tools::CRAN_package_db()


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


cran_data <- pkg_df %>% 
  select_all(tolower) %>%
  select(all_of(colnames))


cran_data %>% head(100) %>% View()

# working with datetime

data_split <- cran_data %>% 
  mutate(`date/publication` = lapply(`date/publication`, function(x) trimws(gsub(" UTC$", "", x))),
         published_datetime = paste(unlist((`date/publication`))),
         published_datetime = as.POSIXct(published_datetime , tz='UTC', format = "%Y-%m-%d %H:%M:%S"),
         published_date = as.Date(published_datetime)
  )

# data_split %>% head(n=100) %>% View()


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
    maintainer_name = gsub("<[^>]+>", "", maintainer),
    maintainer_name = trimws(maintainer_name)
  )

# split the imports column into individual package name
data_split <- data_split %>%
  # Split the date column to datatime and normal date values
  separate_rows(imports, sep = ",") %>% 
  mutate(imports = sub(" ", "", imports)) %>% 
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

data_split1 <- data_split

# 
# data_split1 %>%  
#   filter(package %in%  c('MASS', 'DBI', 'duckplyr', 'abjutils')) %>% View("dateclean")


# to do: case when null = N/A
data_split <- data_split %>% 
  mutate(sponsor = str_extract(author, ".*(?= \\[cph, fnd\\]| \\[fnd\\]| \\[fnd, cph\\])"),
         #sponsor = str_extract(author, ".*(?= \\[fnd, cph\\])"),
         author = str_replace(author, ".*(?= \\[cph, fnd\\]| \\[fnd\\]|\\[fnd, cph\\])",""),
         author = str_replace(author, ".*(?= \\[fnd, cph\\])",""))

data_split <- data_split %>%
  mutate(
    author = gsub("\\[ctb\\]|\\[cph\\]|\\[cre\\]|\\[cre, aut\\]|\\[aut, cre\\]|\\[aut\\]|\\[cet\\]|\\[cph, fnd\\]| \\[fnd\\]|\\[aut, cre, cph\\]|\\[trl\\]|\\[fnd, cph\\]","", author),
    author = gsub("\\s*,\\s*", ", ", author),  # Remove extra spaces after removal
    author = trimws(author)  # Remove leading/trailing spaces
  )

data_split %>% 
  filter(package %in%  c('MASS', 'DBI', 'duckplyr', 'abjutils' , 'ABC.RAP', 'dm')) %>% View("data_split5")
# Split the "author" column into separate authors
data_split <- data_split %>%
  separate_rows(author, sep = ", ") %>%
  mutate(author = trimws(author))  # Remove leading/trailing spaces

data_split <- data_split %>%
  mutate(
    author = gsub("\\s*\\([^)]*\\)", "", author),  # Remove anything within parentheses
    author = gsub("\\s*,\\s*", ", ", author),  # Remove extra spaces after removal
    author = trimws(author),  # Remove leading/trailing spaces
    author = gsub(',', "", author)
  )

data_split <- data_split %>% 
  mutate(
    sponsor = ifelse(author == "RStudio" | package == 'ABC.RAP', "RStudio", sponsor),
    sponsor = trimws(sponsor),
    sponsor = case_when(
      sponsor %in% c("RStudio, Pbc.", "Posit PBC", "RStudio", "Posit Software, PBC") ~ "Posit, PBC",
      sponsor %in% c("R Consortium","The R Consortium") ~ "R Consortium",
      sponsor == "2744/3-4)" ~ "N/A",
      is.na(sponsor) ~ "N/A",
      sponsor %in% c("'FCT, I.P.","FCT", "FCT, I.P.") ~ "FCT, I.P.",
      sponsor == "<doi:10.13039/501100011033>" ~ "N/A",
      is.null(sponsor) ~ "N/A",
      sponsor == "" ~ "N/A",
      TRUE ~ sponsor
  )) %>% 
  filter(author != "RStudio") %>% 
  filter(author != "Rstudio") %>% 
  filter(author != "") %>% 
  filter(maintainer_username != "")

## Check the sponsor column
# data_split %>% 
#   select(sponsor) %>%
#   distinct() %>% 
#   View()

## Split the "depends" column into individual dependency values
data_split <- data_split %>% 
  separate_rows(depends, sep = ", ") #%>%
#filter(!grepl("^R \\(>=", depends))


## Replace NA values in imports with values from depends
data_split <- data_split %>% 
  mutate(imports = ifelse(imports == "" | is.na(imports), depends, imports))

# Remove single quotes and double quotes from the "description" column
data_split <- data_split %>%
  mutate(description = gsub("['\"]", "", description),
         description = gsub('"', '', description),
         description = gsub('\\\\', '', description),
         author = gsub("['\"]", "", author),
         author = gsub('\\\\', '', author),
         author = gsub('"', '', author))

# Create the "company" column based on domain and institution
data_split <- data_split %>%
  mutate(company = institution,
         institution = ifelse(domain == "edu", "Academic",
                              ifelse(company %in% c("gmail", "hotmail", "outlook"), "Undefined", "Industry"))
  )

# Replace NA values with "N/A" for all columns
data_split <- data_split %>%
  mutate_at(vars(-published_date, -published_datetime), ~ifelse(is.na(.), "N/A", .))

# data_split2 %>% 
#   head(n=100) %>% 
#   View()
# 
# 
# data_split %>% 
#   head(n=1000) %>% 
#   View()

nrow(data_split) #406714 #342245

processed_df <- data_split %>% 
  select(package, version, depends,imports, license, md5sum, author, description, encoding, maintainer_name, maintainer_email, institution, domain, published_date, sponsor)


processed_df %>% 
  filter(package %in%  c('MASS', 'DBI', 'duckplyr', 'abjutils' , 'ABC.RAP', 'dm')) %>% View("authorclean")

processed_df %>% 
  filter(maintainer_name == 'Kirill Müller') %>% 
  View()



fileEncoding <- "UTF-8"

# Export the data to a CSV file with the specified encoding
write.csv(processed_df, "data/processed/cran_database_data2.csv", fileEncoding = fileEncoding, quote = FALSE)
# EXporting data to csv file

readr::write_csv(processed_df, "data/processed/cran_process_data.csv")



library(jsonlite)

json_data <- toJSON(processed_df, pretty = TRUE)

# export to json file
write_json(json_data, 'data/processed/cran_data.json')


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
#   View()\

processed_df %>% head()

processed_df %>% 
  filter(package == 'boot') %>% View()

processed_df %>% distinct(package) %>% nrow()

write.