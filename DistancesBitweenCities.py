from geopy.geocoders import Nominatim
import sys

def get_geocode(city):
    nom = Nominatim(user_agent="geoapiExercises")
    location = nom.geocode(city)
    if location:
        return location.latitude, location.longitude
    else:
        return None, None

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("not found")
        sys.exit()

    agent_city = sys.argv[1]
    order_city = sys.argv[2]

    agent_lat, agent_lng = get_geocode(agent_city)
    order_lat, order_lng = get_geocode(order_city)

    if None in (agent_lat, agent_lng, order_lat, order_lng):
        print("not found")
    else:
        print(f"{agent_lat},{agent_lng};{order_lat},{order_lng}")

