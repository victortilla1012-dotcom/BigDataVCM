# ==============================================================================
# SCRIPT 3: BATERÍA DE CONSULTAS DE EXPLORACIÓN (EDA)
# ==============================================================================

library(tidyverse)

# Cargamos el dataset preprocesado y limpio
df <- read_csv("airbnb_sudamerica_clean.csv")
print("🔍 Dataset cargado. Iniciando batería de consultas de exploración...")

# =====================================================================
# EJERCICIO 1: Top 5 de Alojamientos Más Caros
# Muestra cómo ordenar datos y seleccionar columnas específicas.
# =====================================================================
print("\n📌 1. TOP 5 ALOJAMIENTOS MÁS CAROS:")

top_caros <- df %>% 
  arrange(desc(price)) %>% 
  select(name, region_origen, price, room_type) %>% 
  head(5)

print(as.data.frame(top_caros)) # Convertimos a data.frame básico para una impresión limpia en consola


# =====================================================================
# EJERCICIO 2: Precio Promedio y Total de Alojamientos por Región
# Enseña el uso fundamental de group_by() y summarise().
# =====================================================================
print("\n📌 2. RESUMEN DEL MERCADO POR REGIÓN (Precio Promedio y Volumen):")

resumen_region <- df %>% 
  group_by(region_origen) %>% 
  summarise(
    precio_promedio = round(mean(price, na.rm = TRUE), 2),
    total_alojamientos = n() # n() cuenta los registros en R, equivalente a count
  ) %>% 
  arrange(desc(precio_promedio))

print(resumen_region)


# =====================================================================
# EJERCICIO 3: El Efecto "Superhost"
# Filtrado analítico para comprobar métricas de comportamiento de hosts.
# =====================================================================
print("\n📌 3. COMPARATIVA: ¿SER SUPERHOST MARCA LA DIFERENCIA?")

efecto_superhost <- df %>% 
  filter(review_scores_rating > 0) %>% 
  group_by(host_is_superhost) %>% 
  summarise(
    precio_medio = round(mean(price, na.rm = TRUE), 2),
    puntuacion_media = round(mean(review_scores_rating, na.rm = TRUE), 2),
    total_propiedades = n()
  )

print(efecto_superhost)


# =====================================================================
# EJERCICIO 4: Filtrado Avanzado Multicriterio (Oportunidades de Inversión)
# Simula una petición real mediante condiciones lógicas cruzadas complejas.
# =====================================================================
print("\n📌 4. BÚSQUEDA DE OPORTUNIDADES (Filtro Cruzado Complejo):")

# En R se usa el operador lógico & de forma directa dentro de filter()
oportunidades <- df %>% 
  filter(
    region_origen == "Bogota" & 
    room_type == "Entire home/apt" & 
    price < 80 & 
    accommodates >= 4 & 
    review_scores_rating >= 4.5
  )

print(paste("🎯 Se han encontrado", nrow(oportunidades), "opciones que cumplen los requisitos del inversor."))

# Mostramos solo las primeras 5 seleccionando columnas de interés
oportunidades_vista <- oportunidades %>% 
  select(name, neighbourhood_cleansed, price, review_scores_rating) %>% 
  head(5)

print(as.data.frame(oportunidades_vista))


# =====================================================================
# EJERCICIO 5: Distribución del Tipo de Alojamiento por Región (Matriz de Contingencia)
# Muestra cómo cruzar dos variables categóricas. Ideal antes de hacer un ggplot.
# =====================================================================
print("\n📌 5. MATRIZ DE DISTRIBUCIÓN: TIPO DE ALOJAMIENTO POR REGIÓN:")

# En R, la función nativa table() genera la matriz de contingencia exacta de un crosstab
matriz_tipos <- table(df$region_origen, df$room_type)
print(matriz_tipos)


