library(rvest)
library(dplyr)
library(DBI)
library(RPostgres)

segment <- read.csv("..csv")


segment$ip_location <- lapply(segment$ip, FUN = function(x)
    paste("http://www.ip-tracker.org/locator/ip-lookup.php?ip=",x, sep="") %>%
    read_html()%>%
    html_nodes(css = ".vazno") %>%
    html_text()
)
segment <- mutate_all(segment, as.character)

write.csv(segment, file = "..csv")

