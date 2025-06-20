import pandas as pd
import logging
import time
import os
from tqdm import tqdm
from sqlalchemy import create_engine

# ✅ Ensure the logs directory exists
os.makedirs("logs", exist_ok=True)

# ✅ Setup logging
logging.basicConfig(
    filename="logs/ingestion_db.log",
    level=logging.DEBUG,
    format="%(asctime)s - %(levelname)s - %(message)s",
    filemode="a"  # append
)

# ✅ Create SQLAlchemy engine for SQLite
engine = create_engine("sqlite:///inventory.db")

def ingest_db(df, table_name, engine):
    '''Ingest the DataFrame into the SQLite database'''
    df.to_sql(table_name, con=engine, if_exists='replace', index=False)
    logging.info(f"✅ Ingested table '{table_name}' with shape {df.shape}")

def load_raw_data():
    '''Load all CSV files from the data folder and ingest them into the DB'''
    start = time.time()
    data_dir = "data"
    csv_files = []

    # ✅ Collect .csv files (no list comprehension)
    for file in os.listdir(data_dir):
        if file.endswith(".csv"):
            csv_files.append(file)

    # ✅ Loop through CSVs with tqdm
    for file in tqdm(csv_files, desc="📥 Ingesting CSVs"):
        try:
            file_path = os.path.join(data_dir, file)
            df = pd.read_csv(file_path)
            table_name = file[:-4]  # remove ".csv"
            print(df.shape)
            logging.info(f"🔄 Ingesting {file} into table '{table_name}'")
            ingest_db(df, table_name, engine)
        except Exception as e:
            logging.error(f"❌ Failed to ingest {file}: {str(e)}")
            print(f"❌ Error importing '{file}': {str(e)}")

    end = time.time()
    total_time = round((end - start) / 60, 2)
    logging.info("🚀 Ingestion Complete")
    logging.info(f"🕒 Total Time Taken: {total_time} minutes")
    print(f"🎉 All files ingested in {total_time} minutes.")

if __name__ == '__main__':
    load_raw_data()
