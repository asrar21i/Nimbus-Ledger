import boto3
import csv
from datetime import datetime

def get_s3_buckets ():
    response = boto3.client('s3').list_buckets()
    return [
        {"asset_name": bucket["Name"],"creation_date": bucket["CreationDate"]}
        for bucket in response["Buckets"] 
        ]

def write_inventory_csv(buckets):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open (r"01-iso27001-nist-csf\evidence\asset_inventory.csv","w", newline="") as file:
        writer = csv.DictWriter(file, fieldnames=["asset_name", "creation_date", "timestamp"])
        writer.writeheader()
        for bucket in buckets:
            writer.writerow({**bucket, "timestamp": timestamp})

def main():
    buckets = get_s3_buckets()
    write_inventory_csv(buckets)
    print(f"Inventory written for {len(buckets)} buckets")

if __name__ == "__main__":
    main()

