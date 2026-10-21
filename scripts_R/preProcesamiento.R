# ==============================================================================
# SCRIPT 2: PREPROCESAMIENTO AVANZADO DE DATOS
# ==============================================================================

library(tidyverse)

print("🧹 Iniciando la fase avanzada de preprocesamiento de datos...")
df <- read_csv("airbnb_sudamerica_master.csv")

# =====================================================================
# RETO 1: TRATAMIENTO DE VALORES NULOS (MISSING VALUES)
# =====================================================================
print("\n1️⃣ Tratando valores nulos...")

# Imputamos 'bedrooms' y 'beds' con la mediana de la región usando mutate y group_by
df <- df %>% 
  group_by(region_origen) %>% 
  mutate(
    bedrooms = ifelse(is.na(bedrooms), median(bedrooms, na.rm = TRUE), bedrooms),
    beds = ifelse(is.na(beds), median(beds, na.rm = TRUE), beds)
  ) %>% 
  ungroup() # Importante desagrupar tras realizar el cálculo regional

# Para las puntuaciones nulas, creamos una columna bandera (Flag) antes de rellenar.
df <- df %>% 
  mutate(
    has_no_reviews = ifelse(is.na(review_scores_rating), 1, 0),
    review_scores_rating = ifelse(is.na(review_scores_rating), 0, review_scores_rating),
    host_is_superhost = ifelse(is.na(host_is_superhost), "f", host_is_superhost)
  )

print(paste("   ✅ Nulos solventados. Habitaciones vacías restantes:", sum(is.na(df$bedrooms))))


# =====================================================================
# RETO 2: GESTIÓN DE OUTLIERS (VALORES ATÍPICOS EN PRECIOS)
# =====================================================================
print("\n2️⃣ Filtrando valores atípicos (Outliers) en precios...")

filas_originales <- nrow(df)

# 1 y 2. LIMPIEZA Y CONVERSIÓN: En R read_csv ya suele detectar números, por seguridad forzamos la limpieza numérica
df <- df %>% 
  mutate(
    price = str_replace_all(as.character(price), fixed("$"), ""),
    price = str_replace_all(price, fixed(","), ""),
    price = as.numeric(price)
  )

# 3. FILTRADO: Aplicamos el filtro de negocio
df <- df %>% filter(price >= 10 & price <= 1000)

filas_filtradas <- filas_originales - nrow(df)
print(paste("   ✅ Outliers eliminados: Se descartaron", filas_filtradas, "filas fuera del rango [10€ - 1000€]."))


# =====================================================================
# RETO 3: INGENIERÍA DE CARACTERÍSTICAS (FEATURE ENGINEERING)
# =====================================================================
print("\n3️⃣ Ejecutando Ingeniería de Características...")

# Extraer el número de baños desde la columna de texto 'bathrooms_text'
df <- df %>% 
  mutate(
    bathrooms_text = ifelse(is.na(bathrooms_text), "1", bathrooms_text),
    bathrooms_text = str_to_lower(bathrooms_text),
    
    # Usamos expresiones regulares (regex) para extraer el primer número decimal o entero
    bathrooms_num = as.numeric(str_extract(bathrooms_text, "\\d+\\.?\\d*")),
    
    # Si el texto dice 'half-bath' (medio baño) y quedaba nulo, le asignamos 0.5
    bathrooms_num = ifelse(str_detect(bathrooms_text, "half") & is.na(bathrooms_num), 0.5, bathrooms_num),
    
    # Cualquier otro caso nulo que quede lo dejamos en 1 baño (el mínimo estándar)
    bathrooms_num = ifelse(is.na(bathrooms_num), 1.0, bathrooms_num)
  ) %>% 
  # Eliminamos la columna de texto original para limpiar el archivo final
  select(-bathrooms_text)

print("   ✅ Columna numérica 'bathrooms_num' creada con éxito a partir de texto.")


# =====================================================================
# GUARDAR DATASET FINAL Y LIMPIO
# =====================================================================
archivo_final <- "airbnb_sudamerica_clean.csv"
write_csv(df, archivo_final)

print("\n🎉 ¡Preprocesamiento avanzado finalizado!")
print("📊 Dataset listo para análisis en R y Power BI.")
print(paste("💾 Guardado como:", archivo_final, "(Total filas:", nrow(df), ")"))
