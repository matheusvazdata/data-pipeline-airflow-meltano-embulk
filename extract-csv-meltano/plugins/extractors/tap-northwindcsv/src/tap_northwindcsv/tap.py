from singer_sdk import Tap
from singer_sdk import typing as th

from tap_northwindcsv.stream import OrderDetailsStream

class TapNorthwindCSV(Tap):
    name = "tap-northwindcsv"

    config_jsonschema = th.PropertiesList(
        th.Property(
            "csv_path",
            th.StringType,
            description="Path para o arquivo CSV de entrada"
        )
    ).to_dict()

    def discover_streams(self):
        return [OrderDetailsStream(tap=self)]

# Ponto de entrada CLI
cli = TapNorthwindCSV.cli

def main():
    cli()  # <-- aqui estava o detalhe!