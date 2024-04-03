## CRAN mirror to use
CRAN_page <- function(...) {
    file.path('https://cran.rstudio.com/src/contrib', ...)
}

parse_apache_directory_listing <- function(url) {
    rbindlist(lapply(
        htmllistparse$fetch_listing(url)[[2]], function(item) data.table(
            Name = item$name,
            `Last modified` = as.POSIXct(time$strftime('%Y-%m-%d %H:%M:%S', item$modified)),
            Size = ifelse(is.null(item$size), 0, item$size))))
}

## we love data.table
library(data.table)

## get list of currently available packages on CRAN
library(reticulate)
use_python('C:/Python39/python.exe', required = TRUE)

htmllistparse <- import('htmllistparse')
time <- import('time')

pkgs <- parse_apache_directory_listing(CRAN_page())

saveRDS(pkgs, file = 'history_r.rds')
## drop directories
pkgs <- pkgs[Size != 0]
## drop files that does not seem to be R packages
pkgs <- pkgs[grep('tar.gz$', Name)]

## package name should contain only (ASCII) letters, numbers and dot
pkgs[, name := sub('^([a-zA-Z0-9\\.]*).*', '\\1', Name)]

## grab date from last modified timestamp
pkgs[, date := as.character(`Last modified`)]

## keep date and name
pkgs <- pkgs[, .(name, date)]

## list of packages with at least one archived version
archives <- parse_apache_directory_listing(CRAN_page('00Archive'))

## keep directories
archives <- archives[grep('/$', Name)]

## add packages not found in current list of R packages
archives[, Name := sub('/$', '', Name)]
pkgs <- rbind(pkgs,
              archives[!Name %in% pkgs$name, .(name = Name)],
              fill = TRUE)

## reorder pkg in alphabet order
setorder(pkgs, name)

## number of versions released is 1 for published packages
pkgs[, versions := 0]
pkgs[!is.na(date), versions := 1]

## mark archived pacakges
pkgs[, archived := FALSE]
pkgs[name %in% archives$Name, archived := TRUE]

## NA date of packages with archived versions
pkgs[archived == TRUE, date := NA]

## lookup release date of first version & number of releases
saveRDS(pkgs, 'pkgs.RDS')
pkgs[is.na(first_release), c('first_release', 'versions') := {
    cat(name, '\n')
    pkgarchive <- parse_apache_directory_listing(CRAN_page('00Archive', name))
    list(as.character(min(pkgarchive$`Last modified`)), versions + nrow(pkgarchive))
}, by = name]

## rename cols
setnames(pkgs, 'date', 'first_release')

## order by date & alphabet
setorder(pkgs, first_release, name)
pkgs[, index := .I]
pkgs[c(250, 500, (1:13)*1000)]


library(ggplot2)
ggplot(pkgs, aes(as.Date(first_release), index)) +
  geom_line(size = 2) +
  scale_x_date(date_breaks = '1 year', date_labels = '%Y') +
  scale_y_continuous(breaks = seq(0, 16000, 1000)) +
  xlab('') + ylab('') + theme_bw() +
  ggtitle('Number of R packages ever published on CRAN')
ggsave('number-of-submitted-packages-to-CRAN.png')