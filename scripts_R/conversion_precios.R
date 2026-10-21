# ==============================================================================
# SCRIPT 4: CONVERSIÓN DE MONEDAS VECTORIZADA
# ==============================================================================

library(tidyverse)

archivo_entrada <- "airbnb_sudamerica_clean.csv"
archivo_salida <- "airbnb_sudamerica_precios_convertidos.csv"

print("🚀 Iniciando el proceso de conversión de precios...")

tryCatch({
  # 2. Cargar el archivo CSV
  df <- read_csv(archivo_entrada)
  print(paste("   📊 Archivo cargado con éxito. Total de registros:", nrow(df)))

  # 3. Limpieza de seguridad de la columna 'price'
  df <- df %>% 
    mutate(
      price = str_replace_all(as.character(price), fixed("$"), ""),
      price = str_replace_all(price, fixed(","), ""),
      price = as.numeric(price)
    )

  # 4 y 5. Aplicar la conversión vectorizada (Equivalente exacto a np.select de numpy)
  # Usamos case_when, la función nativa más potente de R para condiciones múltiples
  df <- df %>% 
    mutate(
      price = case_when(
        region_origen == "Rio De Janeiro" ~ price * 0.18,
        region_origen == "Sao Paulo"      ~ price * 0.18,
        region_origen == "Bogota"         ~ price * 0.00028,
        region_origen == "Buenos Aires"   ~ price * 0.00059,
        region_origen == "Santiago"       ~ price * 0.00091,
        TRUE                              ~ price  # Valor por defecto (mantiene el original)
      ),
      # Redondeamos a 2 decimales para que queden precios limpios
      price = round(price, 2)
    )

  print("   ✅ Conversión de precios aplicada correctamente.")

  # 6. Guardar los resultados en un nuevo archivo
  write_csv(df, archivo_salida)
  print(paste("💾 Archivo guardado con éxito como:", archivo_salida))

}, error = function(e) {
  print(paste("❌ Ocurrió un error durante la ejecución:", e$message))
})
