library(dplyr)
library(stringr)
library(ggplot2)

setwd(dirname(
  rstudioapi::getSourceEditorContext()$path))

source(".\\SQLMASTER.R")

vendedores <- unique(crm_data$vendedor)


estatus <- unique(crm_data$estatus)

divide_by <- function(x) {
                          x/rowSums(x)
} #funcion used to calculate percentages

contactos <- c()
for (i in estatus) contactos <- cbind(contactos, {
  lapply(vendedores, FUN = function(x)
    length(crm_data$estatus[
      which(
        crm_data$vendedor == x & crm_data$estatus == i)])
    )
  }
  )
rm(i)

contactos <- cbind(contactos, "suma" = rowSums(contactos))

contactos <- as.data.frame(contactos) %>%
    mutate_all(as.numeric) %>%
    `rownames<-`(vendedores) %>%
    `colnames<-`(estatus)
#omitir duplicados y equivocados
contactos <- subset(contactos, select = -c(duplicado, equivocado))
#anadir nombre vendedor y suma de contactos en tabla
contactos <- cbind(contactos, "suma" = rowSums(contactos))
contactos <- cbind("vendedor" = rownames(contactos), contactos)
contactos <- filter(contactos, suma > 15)
contactos_pct <- contactos
contactos_pct <- contactos_pct[,2:8]/contactos_pct$suma*100
contactos_pct <- cbind("vendedor" = contactos$vendedor, contactos_pct)
contactos_pct$vendedor <- substr(contactos_pct$vendedor,
                                 1,
                                 str_locate(contactos_pct$vendedor,"@")[,1]-1)


p <-ggplot(contactos_pct, aes(vendedor, cerrado))
p +geom_bar(stat = "identity")+ theme(axis.text.x = element_text(angle = 45, hjust = 1))