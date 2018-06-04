library(rvest)
library(dplyr)
library(DBI)
library(RPostgres)




segmentdb <- read.csv("C:/Users/Andres/Desktop/Elon/SQL/segment.txt") %>%
  mutate_all(as.character)

#conexion Segment
con <- dbConnect(RPostgres::Postgres(),
                 host = segmentdb$host,
                 port = segmentdb$port,
                 dbname = segmentdb$dbname,
                 user = segmentdb$user,
                 password = segmentdb$password
)
rm(segmentdb)

segment <- dbSendQuery(con,
                       "select * from elonseguros.pages
                       where path='/new_lead/'
                       order by received_at desc
                       ") %>%
  dbFetch() %>%
  mutate(value = substr(received_at, 1, 16))



#CONEXION CRM
crm <- read.csv("C:/Users/Andres/Desktop/Elon/SQL/crm.txt") %>%
  mutate_all(as.character)

con <- dbConnect(RPostgres::Postgres(),
                 host = crm$host,
                 port = crm$port,
                 dbname = crm$dbname,
                 user = crm$user,
                 password = crm$password
)
rm(crm)

#SQL QUERY
crm_data <- dbSendQuery(con,
                        'select
                          core_cotizacion.timestamp,
                          core_contacto.nombre_completo,
                          core_contacto.email,
                          core_contacto.telefono,
                          core_cotizacion.id,
                          core_cotizacion.estatus,
                          core_contacto.fecha_nacimiento,
                          core_contacto.cp,
                          concat(upper(core_auto.marca),\' \',upper(core_auto.modelo),\' \',upper(core_auto.year)) as "auto",
                          core_contacto.source,
                          core_customuser.email as "vendedor"
                        from core_cotizacion
                        inner join core_contacto on core_cotizacion.contacto_id=core_contacto.id
                        inner join core_customuser on core_contacto.vendedor_responsable_id=core_customuser.id
                        inner join core_auto on core_cotizacion.auto_id=core_auto.id
                        order by timestamp DESC') %>%
    dbFetch() %>%
    mutate(value = substr(timestamp, 1, 16)) %>%
    left_join(
              segment[,c("context_ip","value","context_user_agent")],
              by = "value"
              )


crm_data <- filter(crm_data,
                   substr(value,1,7) == "2018-04")


write.csv(filter(crm_data,
                 substr(value,1,7) == "2018-04")
          ,"C:/Users/Andres/Desktop/Elon/SQL/fff.csv")
