import os
from pyspark.sql import SparkSession
from pyspark.sql.functions import col
from pyspark.sql.types import StringType

# Cria sessão Spark
spark = SparkSession.builder.getOrCreate()

# Caminho do volume no DBFS
volume_path = "/Volumes/northwind/00_raw/source"

# Lista os arquivos .parquet
files = [f.path for f in dbutils.fs.ls(volume_path) if f.path.endswith(".parquet")]

for file_path in files:
    # Nome da tabela
    table_name = os.path.basename(file_path).replace(".parquet", "")
    print(f"[INFO] Ingerindo arquivo: {file_path} como tabela: {table_name}")

    # Leitura e conversão para String
    df = spark.read.parquet(file_path)
    for field in df.schema.fields:
        df = df.withColumn(field.name, col(field.name).cast(StringType()))

    # Escrita com overwrite do schema (ESSENCIAL)
    df.write.format("delta") \
        .mode("overwrite") \
        .option("overwriteSchema", "true") \
        .saveAsTable(f"northwind.00_raw.{table_name}")

    print(f"[SUCESSO] Tabela northwind.00_raw.{table_name} criada com sucesso.")