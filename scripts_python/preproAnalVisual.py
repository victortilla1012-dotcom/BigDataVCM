import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Configuración estética de los gráficos
sns.set_theme(style="whitegrid")
plt.rcParams['figure.figsize'] = [10, 6]

# ==========================================
# 1. CARGA Y LIMPIEZA INICIAL DE DATOS
# ==========================================

# ⚠️ Cambia 'tu_dataset_unificado.csv' por el nombre real de tu archivo
df = pd.read_csv('tu_dataset_unificado.csv')

print("--- Dimensiones del dataset unificado ---")
print(df.shape)

# Limpieza de precios: eliminar símbolos si vienen como texto (ej: '$150')
if df['price'].dtype == 'object':
    df['price'] = df['price'].astype(str).str.replace(r'[\$,]', '', regex=True).astype(float)

# Tratamiento de Outliers en Precio (Eliminar el 1% más caro para no deformar los gráficos)
q_high = df['price'].quantile(0.99)
df_filtered = df[(df['price'] > 0) & (df['price'] < q_high)].copy()

print(f"\n--- Dataset filtrado (sin precios extremos mayores a ${q_high:.2f}) ---")
print(df_filtered.shape)


# ==========================================
# 2. GENERACIÓN DE ANÁLISIS VISUAL
# ==========================================

# Gráfico 1: Distribución de Precios (Histograma)
plt.figure()
sns.histplot(data=df_filtered, x='price', bins=50, kde=True, color='skyblue')
plt.title('Distribución de los Precios por Noche (Filtrado)', fontsize=14)
plt.xlabel('Precio', fontsize=12)
plt.ylabel('Cantidad de Alojamientos', fontsize=12)
plt.savefig('1_distribucion_precios.png', dpi=300, bbox_inches='tight')
plt.show()

# Gráfico 2: Tipos de Propiedad / Habitación
plt.figure()
room_counts = df_filtered['room_type'].value_counts()
plt.pie(room_counts, labels=room_counts.index, autopct='%1.1f%%', startangle=140, colors=sns.color_palette('pastel'))
plt.title('Distribución por Tipo de Habitación', fontsize=14)
plt.savefig('2_tipos_habitacion.png', dpi=300, bbox_inches='tight')
plt.show()

# Gráfico 3: Top 10 Barrios con más Oferta
plt.figure()
# Cambia 'neighbourhood' por el nombre exacto de tu columna de barrios
top_barrios = df_filtered['neighbourhood'].value_counts().head(10)
sns.barplot(x=top_barrios.values, y=top_barrios.index, palette='viridis')
plt.title('Top 10 Barrios con Mayor Cantidad de Alojamientos', fontsize=14)
plt.xlabel('Número de Alojamientos', fontsize=12)
plt.savefig('3_top_barrios.png', dpi=300, bbox_inches='tight')
plt.show()

# Gráfico 4: Precio Promedio por Tipo de Habitación
plt.figure()
sns.barplot(data=df_filtered, x='room_type', y='price', estimator='mean', errorbar=None, palette='muted')
plt.title('Precio Promedio según el Tipo de Habitación', fontsize=14)
plt.xlabel('Tipo de Habitación', fontsize=12)
plt.ylabel('Precio Medio', fontsize=12)
plt.savefig('4_precio_por_tipo.png', dpi=300, bbox_inches='tight')
plt.show()

# Gráfico 5: Mapa de Calor de Correlación entre Variables Numéricas
plt.figure(figsize=(8, 6))
# Seleccionamos variables numéricas típicas de Airbnb
cols_interes = ['price', 'minimum_nights', 'number_of_reviews', 'reviews_per_month', 'availability_365']
# Nos aseguramos de usar solo las que existan en tu dataset
cols_validas = [c for c in cols_interes if c in df_filtered.columns]

corr = df_filtered[cols_validas].corr()
sns.heatmap(corr, annot=True, cmap='coolwarm', fmt=".2f", linewidths=0.5)
plt.title('Matriz de Correlación', fontsize=14)
plt.savefig('5_matriz_correlacion.png', dpi=300, bbox_inches='tight')
plt.show()

print("\n¡Proceso completado! Los gráficos se han mostrado en pantalla y guardado como imágenes en tu carpeta de trabajo.")
