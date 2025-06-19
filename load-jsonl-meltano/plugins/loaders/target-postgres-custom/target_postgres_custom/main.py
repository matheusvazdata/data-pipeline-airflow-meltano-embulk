import os
import sys
import json
import psycopg2
from pathlib import Path

def main():
    if len(sys.argv) != 2:
        print("Uso: python main.py <caminho_para_arquivo_jsonl>")
        sys.exit(1)

    filepath = sys.argv[1]
    if not os.path.isfile(filepath):
        print(f"[ERRO] Arquivo não encontrado: {filepath}")
        sys.exit(1)

    table_name = Path(filepath).stem

    conn = psycopg2.connect(
        host=os.getenv("PG_HOST"),
        port=os.getenv("PG_PORT"),
        dbname=os.getenv("PG_DATABASE"),
        user=os.getenv("PG_USER"),
        password=os.getenv("PG_PASSWORD"),
    )
    conn.autocommit = True
    cur = conn.cursor()

    buffer = []
    schema_keys = set()

    with open(filepath, "r", encoding="utf-8") as f:
        for line in f:
            try:
                record = json.loads(line)
                buffer.append(record)
                schema_keys.update(record.keys())
            except json.JSONDecodeError:
                continue

    if not buffer:
        print("[AVISO] Nenhum registro encontrado no arquivo.")
        return

    # Cria a tabela se não existir e apaga dados antigos
    columns = ", ".join([f"{col} TEXT" for col in schema_keys])
    cur.execute(f"CREATE TABLE IF NOT EXISTS {table_name} ({columns});")
    cur.execute(f"TRUNCATE TABLE {table_name};")

    # Insere os dados
    cols = list(schema_keys)
    placeholders = ", ".join(["%s"] * len(cols))
    insert_sql = f"INSERT INTO {table_name} ({','.join(cols)}) VALUES ({placeholders})"

    for row in buffer:
        values = [str(row.get(col, "")) for col in cols]
        cur.execute(insert_sql, values)

    print(f"[SUCESSO] {len(buffer)} registros inseridos na tabela '{table_name}'")

    cur.close()
    conn.close()

if __name__ == "__main__":
    main()