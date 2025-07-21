from setuptools import setup, find_packages

setup(
    name="tap-northwindcsv",
    version="0.1.0",
    description="Singer tap for extracting CSV data from Northwind",
    author="Matheus Vaz",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    install_requires=[
        "singer-sdk>=0.29.0",
        "pandas"
    ],
    entry_points={
        "console_scripts": [
            "tap-northwindcsv=tap_northwindcsv.tap:main",
        ],
    },
    include_package_data=True,
)