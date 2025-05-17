import sys
import csv

def get_coords(city):
    with open("cities_coordinates.csv", "r") as f:
        reader = csv.DictReader(f)
        for row in reader:
            if row["City"].strip().lower() == city.strip().lower():
                return row["Latitude"], row["Longitude"]
    return None, None

if _name_ == "_main_":
    if len(sys.argv) != 3:
        print("not found")
        sys.exit()

    agent_city = sys.argv[1]
    order_city = sys.argv[2]

    agent_lat, agent_lng = get_coords(agent_city)
    order_lat, order_lng = get_coords(order_city)

    if None in (agent_lat, agent_lng, order_lat, order_lng):
        print("not found")
    else:
        print(f"{agent_lat},{agent_lng};{order_lat},{order_lng}")
