import pandas as pd
import os 
from geopy.geocoders import Nominatim

os.listdir() # List files in current directory 


def load_csv(file_name): # mitigate the risk of FileNotFoundError
    if not os.path.exists(file_name):
        raise FileNotFoundError(f"Data file '{file_name}' missing")
    return pd.read_csv(file_name)

dfAgent = load_csv("expanded_agents_data.csv") # Agent location
dforder = load_csv("expanded_orders_data.csv") # Order destination

# Initialize geocoder
nom = Nominatim(user_agent="find the latitude and longitude")

def get_geocode(city): # find the latitude and longitude from the city name
    location = nom.geocode(city)
    if location: # if the location is found
        return location.latitude, location.longitude
    else:
        print(location," not found.")
def get_coordinates(agent_city,order_city): # get the latitude and longitude
    agent_lat, agent_lng = get_geocode(agent_city)
    order_lat, order_lng = get_geocode(order_city)
    
    print("agent_lat: ", agent_lat,"\tagent_lng: "
    ,agent_lng,"\norder_lat: ",order_lat,"\torder_lng: ",order_lng)

agent_city = input("Enter the agent city: ")
order_city = input("Enter the order city: ")

get_coordinates(agent_city, order_city)

