archivos <- list.files("C:\\Users\\Andres\\Desktop\\zipppp\\")


extraer <- function(x){
  unzip(zipfile = paste("C:\\Users\\Andres\\Desktop\\zipppp\\", x, sep = ""),
      exdir = "C:\\Users\\Andres\\Desktop\\zipppp\\facturas1")
}

for (i in archivos){
  extraer(i)
}