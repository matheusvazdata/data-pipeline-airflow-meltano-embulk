import os
from pyspark.sql import SparkSession

spark = SparkSession.builder.getOrCreate()

# Caminho do volume Databricks
volume_path = "/Volumes/northwind/bronze/source"

# Lista todos os arquivos parquet no volume
files = [f.path for f in dbutils.fs.ls(volume_path) if f.path.endswith(".parquet")]

for file_path in files:
    # Extrai nome da tabela com base no nome do arquivo
    table_name = os.path.basename(file_path).replace(".parquet", "")
    print(f"Ingerindo {table_name}...")

    df = spark.read.parquet(file_path)

    df.write.format("delta") \
        .mode("overwrite") \
        .saveAsTable(f"northwind.bronze.{table_name}")