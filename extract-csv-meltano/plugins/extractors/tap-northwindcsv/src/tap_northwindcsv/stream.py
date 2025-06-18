import csv
from singer_sdk import Stream
from singer_sdk.typing import PropertiesList, Property, IntegerType, NumberType, StringType

class OrderDetailsStream(Stream):
    name = "order_details"
    primary_keys = ["order_id", "product_id"]
    replication_key = None

    schema = PropertiesList(
        Property("order_id", IntegerType),
        Property("product_id", IntegerType),
        Property("unit_price", NumberType),
        Property("quantity", IntegerType),
        Property("discount", NumberType),
    ).to_dict()

    def get_records(self, context):
        path = self.config["csv_path"]
        with open(path, "r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            for row in reader:
                yield {
                    "order_id": int(row["order_id"]),
                    "product_id": int(row["product_id"]),
                    "unit_price": float(row["unit_price"]),
                    "quantity": int(row["quantity"]),
                    "discount": float(row["discount"]),
                }