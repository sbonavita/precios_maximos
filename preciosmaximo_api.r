library(rvest)
library(jsonlite)
library(httr)
library(openxlsx)

provincias <- c("Buenos Aires","Catamarca","Chaco","Chubut","Córdoba",
                "Corrientes","Entre Ríos","Formosa","Jujuy","La Pampa",
                "La Rioja","Mendoza","Misiones","Neuquén","Río Negro",
                "Salta","San Juan","San Luis","Santa Cruz","Santa Fe",
                "Santiago del Estero","Tierra del Fuego","Tucumán")
provincias <- gsub(" ","%20",provincias)

for (i in 1:length(provincias)){
  url_pmaximos <- paste0("https://preciosmaximos.argentina.gob.ar/api/products?pag=1&Provincia=",
                     provincias[i],
                     "&regs=300000")
  leo_url <- GET(url_pmaximos)
  leo_url_txt <- content(leo_url,"text")#convierto a txt
  leo_json <- fromJSON(leo_url_txt)#COnvierto a json
  leo_dataframe <- as.data.frame(leo_json)
  ifelse(exists("data.total"),
         data.total <- rbind(data.total,leo_dataframe),
         data.total <- leo_dataframe)
}

columas_finales <- c("result.Precio.sugerido","result.Producto_s_tilde",
                     "result.Provincia","result.Region","result.categoria",
                     "result.id_producto","result.marca","result.subcategoria")
base_final <- data.total[,columas_finales]
nombres.columnas <- c("precio.Max","producto","provincia","region",
                      "categoria","ean","marca","subcategoria")
colnames(base_final) <- nombres.columnas

eans_unicos <- unique(base_final$ean)

hojas <- list(
  "precios_maximo" = as.data.frame(base_final),
  "eans" = as.data.frame(eans_unicos)
)

write.xlsx(hojas,
           paste0(
  "/home/santiago/Nextcloud/Scanntech/Proyectos R/Reportes Periodicos/results/preciosmaximos/",
  Sys.Date(),
  "-precios_maximos.xlsx"),
  row.names = FALSE
  )
