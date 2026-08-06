import boto3
import csv
from datetime import datetime

def get_access_key_last_used(access_key_id):
    client = boto3.client('iam')
    response = client.get_access_key_last_used(AccessKeyId=access_key_id)
    return response["AccessKeyLastUsed"]["LastUsedDate"]

def flag_risky_users(users):
    flagged = []
    for user in users:
        if user["days_old"] > 90 or (user["is_admin"] and user["days_old"] > 30):
            flagged.append(user)
    return flagged

def write_access_review_csv(flagged_users):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(r"01-iso27001-nist-csf\evidence\sample_flagged_users_output.csv", "w", newline="") as file:
        writer = csv.DictWriter(file, fieldnames=["username", "is_admin", "days_old", "timestamp"])
        writer.writeheader()
        for user in flagged_users:
            writer.writerow({**user, "timestamp": timestamp})

def main():
    # Sample data below stands in for a real IAM user pull in production —
    # each user's real "days_old" would come from get_access_key_last_used().
    users = [
        {"username": "alice", "is_admin": False, "days_old": 5},
        {"username": "bob", "is_admin": False, "days_old": 120},
        {"username": "carol", "is_admin": True, "days_old": 45},
    ]
    flagged_users = flag_risky_users(users)
    write_access_review_csv(flagged_users)
    print(f"Access review written for {len(flagged_users)} users")


if __name__ == "__main__":
    main()