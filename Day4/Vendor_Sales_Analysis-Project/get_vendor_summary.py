import sqlite3
import pandas as pd
import logging
from ingestion_db import ingest_db  # This should be your own helper module

# ✅ Setup logging
logging.basicConfig(
    filename="logs/get_vendor_summary.log",
    level=logging.DEBUG,
    format="%(asctime)s - %(levelname)s - %(message)s",
    filemode="a"  # Append mode
)

def create_vendor_summary(conn):
    """This function merges different tables to get the overall vendor summary and adds new columns."""
    
    query = """
    WITH FreightSummary AS (
        SELECT VendorNumber, SUM(Freight) AS FreightCost
        FROM vendor_invoice
        GROUP BY VendorNumber
    ),
    PurchaseSummary AS (
        SELECT 
            p.VendorNumber,
            p.VendorName,
            p.Brand,
            p.Description,
            p.PurchasePrice,
            pp.Price AS ActualPrice,
            pp.Volume,
            SUM(p.Quantity) AS TotalPurchaseQuantity,
            SUM(p.Dollars) AS TotalPurchaseDollars
        FROM purchases p
        JOIN purchase_prices pp ON p.Brand = pp.Brand
        WHERE p.PurchasePrice > 0
        GROUP BY p.VendorNumber, p.VendorName, p.Brand, p.Description, p.PurchasePrice, pp.Price, pp.Volume
    ),
    SalesSummary AS (
        SELECT 
            VendorNo,
            Brand,
            SUM(SalesQuantity) AS TotalSalesQuantity,
            SUM(SalesDollars) AS TotalSalesDollars,
            SUM(SalesPrice) AS TotalSalesPrice,
            SUM(ExciseTax) AS TotalExciseTax
        FROM sales
        GROUP BY VendorNo, Brand
    )
    SELECT 
        ps.VendorNumber,
        ps.VendorName,
        ps.Brand,
        ps.Description,
        ps.PurchasePrice,
        ps.ActualPrice,
        ps.Volume,
        ps.TotalPurchaseQuantity,
        ps.TotalPurchaseDollars,
        ss.TotalSalesQuantity,
        ss.TotalSalesDollars,
        ss.TotalSalesPrice,
        ss.TotalExciseTax,
        fs.FreightCost
    FROM PurchaseSummary ps
    LEFT JOIN SalesSummary ss ON ps.VendorNumber = ss.VendorNo AND ps.Brand = ss.Brand
    LEFT JOIN FreightSummary fs ON ps.VendorNumber = fs.VendorNumber
    ORDER BY ps.TotalPurchaseDollars DESC
    """

    return pd.read_sql_query(query, conn)


def clean_data(vendor_sales_summary):
    """This function cleans the data and adds analysis columns."""

    # Convert Volume to float
    vendor_sales_summary['Volume'] = vendor_sales_summary['Volume'].astype('float64')

    # Fill missing values
    vendor_sales_summary.fillna(0, inplace=True)

    # Remove leading/trailing spaces
    vendor_sales_summary['VendorName'] = vendor_sales_summary['VendorName'].str.strip()
    vendor_sales_summary['Description'] = vendor_sales_summary['Description'].str.strip()

    # Add calculated columns
    vendor_sales_summary['GrossProfit'] = vendor_sales_summary['TotalSalesDollars'] - vendor_sales_summary['TotalPurchaseDollars']
    vendor_sales_summary['ProfitMargin'] = (vendor_sales_summary['GrossProfit'] / vendor_sales_summary['TotalSalesDollars']) * 100
    vendor_sales_summary['StockTurnover'] = vendor_sales_summary['TotalSalesQuantity'] / vendor_sales_summary['TotalPurchaseQuantity']
    vendor_sales_summary['SalestoPurchaseRatio'] = vendor_sales_summary['TotalSalesDollars'] / vendor_sales_summary['TotalPurchaseDollars']

    return vendor_sales_summary


if __name__ == '__main__':
    # Create SQLite connection
    conn = sqlite3.connect('inventory.db')

    try:
        logging.info('Creating Vendor Summary Table...')
        summary_df = create_vendor_summary(conn)
        logging.info('Vendor summary created.')
        logging.info('\n' + summary_df.head().to_string())

        logging.info('Cleaning Data...')
        clean_df = clean_data(summary_df)
        logging.info('Data cleaned.')
        logging.info('\n' + clean_df.head().to_string())

        logging.info('Ingesting Data into DB...')
        ingest_db(clean_df, 'vendor_sales_summary', conn)
        logging.info('Ingestion complete.')

    except Exception as e:
        logging.error(f"An error occurred: {e}")

    finally:
        conn.close()
        logging.info('Database connection closed.')
