library(dplyr)
library(readr)
library(tidyr)

#import data
cran_data <- read_csv('data/raw/cran_package_200911.csv', col_names = TRUE)

colnames = c("package", "version","depends", "imports", "suggests", "license", "md5sum", "author", "authors@r", "date/publication", "description", "encoding", "maintainer", "packaged")

cran_data %>% 
  select_all(tolower) %>%
  select(all_of(colnames)) %>% 
  mutate(imports = gsub("[[:punct:]]", "", import)) %>% 
  filter(package == 'dbplyr') %>% 
  View()

cran_data %>% 
  filter(Imports %in% 'DBI (>= 1.0.0)')


cran_data <- cran_data %>% 
  select_all(tolower) %>%
  select(all_of(colnames))

cran_data %>% head()

# split the imports column into individual package name
data_split <- cran_data %>% 
  separate_rows(imports, sep = ", ") %>% 
  mutate(imports = gsub("\\s*\\(>=.*?\\)", "", imports)) # remove version specifications

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

# Split the "imports" column into individual package names
# Extract the institution and domain from the "maintainer" column
data_split <- data_split %>%
  separate_rows(imports, sep = ",") %>%
  mutate(imports = gsub("\\s*\\(>=.*?\\)", "", imports),
         institution = sub(".*@(.+?)\\..*", "\\1", maintainer),
         domain = sub(".*\\.(.+?)$>", "\\1", maintainer),
         maintainer_email = sub(".*<(.+)>", "\\1", maintainer),
         maintainer_name = gsub("<[^>]+>", "", maintainer))

## Split the "depends" column into individual dependency values
data_split <- data_split %>% 
  separate_rows(depends, sep = ", ") #%>%
  #filter(!grepl("^R \\(>=", depends))



nrow(data_split) #406714 #342245

# Extract the institution from the "maintainer" column using regex
data_split %>%
  head(n = 100) %>% 
  View()



data_split %>% 
  mutate(
    email = sub(".*<(.+)>", "\\1", maintainer),
    institution = sub(".*@(.+?)\\..*", "\\1", maintainer),
    domain = sub(".*\\.(.+?)$", "\\1", maintainer),
    name = sub("(.+?) <", "\\1", maintainer)
  ) %>% 
  head(1000) %>% 
  View()
