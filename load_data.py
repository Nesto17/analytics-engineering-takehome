import pandas as pd
from sqlalchemy import create_engine
import gzip
import json
import pandas as pd
import numpy as np

# Create connection to PostgreSQL
db_connection_string = "postgresql://admin:admin@postgres:5432/olap"
engine = create_engine(db_connection_string)

# Ingest JSON files
brands = []
receipts = []
users = []

def load_json_lines(file_path, data_list):
    with gzip.open(file_path, 'rt', encoding='utf-8') as f:
        for line in f:
            line = line.strip() 
            if line: 
                try:
                    data_list.append(json.loads(line))
                except json.JSONDecodeError as e:
                    print(f"Error decoding JSON in {file_path}: {e} - Line: {line}")

load_json_lines('./data/brands.json.gz', brands)
load_json_lines('./data/receipts.json.gz', receipts)
load_json_lines('./data/users.json.gz', users)

# Map brands file to Pandas DataFrame
brands_df = pd.DataFrame(brands)

brands_df['brand_id'] = brands_df['_id'].apply(lambda x: x['$oid'])
brands_df['cpg'] = brands_df['cpg'].apply(lambda x: x['$id']['$oid'])

dim_brands = brands_df[['brand_id', 'barcode', 'category', 'categoryCode', 'cpg', 'name', 'topBrand', 'brandCode']].rename(
    columns={
        'categoryCode': 'category_code',
        'topBrand': 'top_brand',
        'brandCode': 'brand_code',
    }
)

# Map users file to Pandas DataFrame
users_df = pd.DataFrame(users)

users_df['user_id'] = users_df['_id'].apply(lambda x: x['$oid'])

users_df['created_date'] = users_df['createdDate'].apply(lambda x: pd.to_datetime(x['$date'], unit='ms'))
users_df['last_login'] = users_df['lastLogin'].apply(lambda x: pd.to_datetime(x['$date'], unit='ms') if x is not np.nan else pd.to_datetime('2000-01-01'))

dim_users = users_df[['user_id', 'active', 'created_date', 'last_login', 'role', 'signUpSource', 'state']].rename(
    columns={
        'signUpSource': 'signup_source'
    }
)

# Map receipt-items to Pandas DataFrame

schema = {
    'dim_receiptItems': {
        'receiptItem_id': 'varchar',
        'rewards_receipt_status': 'enum'
    },
    'fct_receiptItems': {
        'receiptItem_id': 'varchar',
        'user_id': 'varchar',
        'barcode': 'varchar',
        'receipt_id': 'varchar',
        'final_price': 'float',
        'item_price': 'float',
        'points_earned': 'float',
        'quantity_purchased': 'integer',
        'date_scanned': 'timestamp'
    }
}

fct_receiptItems = pd.DataFrame(columns=schema['fct_receiptItems'].keys())
dim_receiptItems = pd.DataFrame(columns=schema['dim_receiptItems'].keys())

for i, receipt in enumerate(receipts):
    if 'rewardsReceiptItemList' in receipt:
        for j, item in enumerate(receipt['rewardsReceiptItemList']):
            # quantitative
            fct_item = {}

            fct_item['receiptItem_id'] = f"{i}-{j}"
            fct_item['user_id'] = receipt['userId']
            fct_item['receipt_id'] = f"receipt-{i}"
            fct_item['date_scanned'] = pd.to_datetime(receipt['dateScanned']['$date'], unit='ms')
            # fct_item['finished_date'] = pd.to_datetime(receipt['finishedDate']['$date'], unit='ms') if receipt['finishedDate'] is not np.nan else pd.to_datetime('2000-01-01')

            if 'barcode' in item:
                fct_item['barcode'] = item['barcode']
            if 'finalPrice' in item:
                fct_item['final_price'] = item['finalPrice']
            if 'itemPrice' in item:
                fct_item['item_price'] = item['itemPrice']
            if 'pointsEarned' in item:
                fct_item['points_earned'] = item['pointsEarned']
            if 'quantityPurchased' in item:
                fct_item['quantity_purchased'] = item['quantityPurchased']

            # qualitative 
            dim_item = {}

            dim_item['receiptItem_id'] = f"{i}-{j}"
            dim_item['rewards_receipt_status'] = receipt['rewardsReceiptStatus']

            fct_receiptItems = pd.concat([fct_receiptItems, pd.DataFrame([fct_item])], ignore_index=True)
            dim_receiptItems = pd.concat([dim_receiptItems, pd.DataFrame([dim_item])], ignore_index=True)


# Load data into PostgreSQL
dim_users.to_sql('dim_users', engine, if_exists='replace', index=False)
dim_brands.to_sql('dim_brands', engine, if_exists='replace', index=False)
dim_receiptItems.to_sql('dim_receiptitems', engine, if_exists='replace', index=False)
fct_receiptItems.to_sql('fct_receiptitems', engine, if_exists='replace', index=False)

print("Data loaded successfully")

# print('USERS----------------')
# print(dim_users.head())
# print('BRANDS----------------')
# print(dim_brands.head())
# print('RECEIPT_DIM----------------')
# print(dim_receiptItems.head())
# print('RECEIPT_FACTS----------------')
# print(fct_receiptItems.head())