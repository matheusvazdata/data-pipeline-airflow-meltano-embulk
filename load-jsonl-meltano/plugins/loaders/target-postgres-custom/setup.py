from setuptools import setup, find_packages

setup(
    name="target-postgres-custom",
    version="0.1.0",
    description="Custom Meltano target plugin for loading JSONL to PostgreSQL",
    author="Francisco Matheus",
    packages=find_packages(),
    install_requires=[
        "psycopg2-binary==2.9.9",
    ],
    entry_points={
        "console_scripts": [
            "target-postgres-custom=target_postgres_custom.main:main",
        ],
    },
)