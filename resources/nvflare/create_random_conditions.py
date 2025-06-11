import csv
import random
import sys
from datetime import datetime, timedelta


NUM_ENTRIES = 5000
MIN_CONDITION_DURATION = 1
MAX_CONDITION_DURATION = 10
MAX_DATE = datetime.now()
DATE_FORMAT = "%m/%d/%Y"

with open("/workspace/labels.csv") as f:
    reader = csv.reader(f)
    CONDITIONS = [row for row in reader]

CONDITIONS_SAMPLE = CONDITIONS[:int(NUM_ENTRIES / 50)]

def create_row(conditions_list):
    start_date = MAX_DATE - timedelta(days=random.randint(MAX_CONDITION_DURATION, 500))
    end_date = start_date + timedelta(days=random.randint(MIN_CONDITION_DURATION, MAX_CONDITION_DURATION))
    return {
        "condition_era_id": random.randint(10000, 100000),
        "person_id": random.randint(0, 1000),
        "condition_concept_id": random.choice(conditions_list)[0],
        "condition_era_start_date": start_date.strftime(DATE_FORMAT),
        "condition_era_end_date": end_date.strftime(DATE_FORMAT),
        "condition_occurrence_count": 1,
    }


def main(args):
    try:
        seed = int(args[1]) if len(args) > 1 else random.randint(0, 1000)
        print(f"Dataset id: {seed}")
        random.seed(seed)
    except ValueError as e:
        raise ValueError("If an argument is given, it should be an integer") from e

    headers = [
        "condition_era_id",
        "person_id",
        "condition_concept_id",
        "condition_era_start_date",
        "condition_era_end_date",
        "condition_occurrence_count"
    ]

    with open("condition_era.csv", "w") as f:
        writer = csv.DictWriter(f, headers)
        writer.writeheader()
        rows = [create_row(CONDITIONS_SAMPLE) for _ in range(NUM_ENTRIES)]

        writer.writerows(rows)


if __name__ == "__main__":
    main(sys.argv)