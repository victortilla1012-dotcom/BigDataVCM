import numpy as np
import pandas as pd

# 1. Configuración de nombres de archivos
archivo_entrada = "airbnb_sudamerica_clean.csv"  # Modifica esto si tu archivo se llama diferente
archivo_salida = "airbnb_sudamerica_precios_convertidos.csv"

print("🚀 Iniciando el proceso de conversión de precios...")

try:
    # 2. Cargar el archivo CSV
    df = pd.read_csv(archivo_entrada)
    print(f"   📊 Archivo cargado con éxito. Total de registros: {len(df)}")

    # 3. Limpieza de seguridad de la columna 'price'
    # Si la columna viene con '$' o comas de texto, las limpiamos primero
    if df["price"].dtype == "object":
        df["price"] = (
            df["price"]
            .astype(str)
            .str.replace("$", "", regex=False)
            .str.replace(",", "", regex=False)
        )

    # Convertimos la columna a tipo numérico float
    df["price"] = pd.to_numeric(df["price"], errors="coerce")

    # 4. Definición de las condiciones y factores de conversión de moneda
    condiciones = [
        df["region_origen"] == "Rio De Janeiro",
        df["region_origen"] == "Sao Paulo",
        df["region_origen"] == "Bogota",
        df["region_origen"] == "Buenos Aires",
        df["region_origen"] == "Santiago",
    ]

    factores = [
        df["price"] * 0.18,  # Rio De Janeiro
        df["price"] * 0.18,  # Sao Paulo
        df["price"] * 0.00028,  # Bogota
        df["price"] * 0.00059,  # Buenos Aires
        df["price"] * 0.00091,  # Santiago
    ]

    # 5. Aplicar la conversión vectorizada
    # Si la región no coincide con ninguna de las anteriores, mantiene su valor original
    df["price"] = np.select(condiciones, factores, default=df["price"])

    # Redondeamos a 2 decimales para que queden precios limpios de moneda (ej: 45.12)
    df["price"] = df["price"].round(2)

    print("   ✅ Conversión de precios aplicada correctamente.")

    # 6. Guardar los resultados en un nuevo archivo
    df.to_csv(archivo_salida, index=False)
    print(f"💾 Archivo guardado con éxito como: '{archivo_salida}'")

except FileNotFoundError:
    print(
        f"❌ Error: No se pudo encontrar el archivo '{archivo_entrada}'. Asegúrate de que esté en la misma carpeta que este script."
    )
except KeyError as e:
    print(
        f"❌ Error: Falta una columna obligatoria en tu archivo CSV. Detalle: {e}"
    )
except Exception as e:
    print(f"❌ Ocurrió un error inesperado durante la ejecución: {e}")
