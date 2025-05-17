#!/bin/bash

deg2rad() {
  echo "$1 * 0.017453292519943295" | bc -l
}

haversine_distance() {
  lat1=$(deg2rad "$1")
  lon1=$(deg2rad "$2")
  lat2=$(deg2rad "$3")
  lon2=$(deg2rad "$4")

  dlat=$(echo "$lat2 - $lat1" | bc -l)
  dlon=$(echo "$lon2 - $lon1" | bc -l)

  sin_dlat=$(echo "s($dlat / 2)" | bc -l)
  sin_dlon=$(echo "s($dlon / 2)" | bc -l)
  cos_lat1=$(echo "c($lat1)" | bc -l)
  cos_lat2=$(echo "c($lat2)" | bc -l)

  a=$(echo "$sin_dlat * $sin_dlat + $cos_lat1 * $cos_lat2 * $sin_dlon * $sin_dlon" | bc -l)
  sqrt_a=$(echo "sqrt($a)" | bc -l)
  sqrt_1_a=$(echo "sqrt(1 - $a)" | bc -l)
  c=$(echo "2 * a(1) * a($sqrt_a / $sqrt_1_a)" | bc -l)
  distance=$(echo "6371 * $c" | bc -l)

  echo "$distance"
}

#################

#our files
AGENTS_FILE="agents_data.csv"      # File with agents
ORDERS_FILE="orders_data.csv"      # File with orders
OUTPUT_FILE="assigned_orders.csv"           # Output file to save results
COORDINATE_SCRIPT="DistancesBitweenCities.py"  # Python script to calculate distance

if [[ ! -f "$AGENTS_FILE" || ! -f "$ORDERS_FILE" || ! -f "$COORDINATE_SCRIPT" ]]; then
  echo " Requiresd files are missing! ."
  exit 1
fi

#Work on the output  file
echo "OrderID,FromCity,ToCity,ItemType,best_agent,best_city,best_distance" > "$OUTPUT_FILE"

#Lop over all orders 
tail -n +2 "$ORDERS_FILE" | while IFS=',' read -r OrderID FromCity ToCity ItemType IsFragile Size Priority OrderTime
do
  echo "Processing order $OrderID from $FromCity to $ToCity ..."
  
  best_agent=""
  best_city=""
  best_distance=1000000

  #Loop over all agents to find the closest One 
  tail -n +2 "$AGENTS_FILE" | while IFS=',' read -r AgentID Name City Availability VehicleType CanCarryFragile 
  do
    coords=$(python3 "$COORDINATE_SCRIPT" "$City" "$FromCity")

    if [[ "$coords" == "not found" ]]; then
      continue
    fi

    agent_lat=$(echo "$coords" | cut -d';' -f1 | cut -d',' -f1)
    agent_lng=$(echo "$coords" | cut -d';' -f1 | cut -d',' -f2)
    order_lat=$(echo "$coords" | cut -d';' -f2 | cut -d',' -f1)
    order_lng=$(echo "$coords" | cut -d';' -f2 | cut -d',' -f2)

    distance=$(haversine_distance "$agent_lat" "$agent_lng" "$order_lat" "$order_lng")
    
    echo "looking agent city '$City', to order city '$FromCity' => result '$distance'"
    if [[ "$distance" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then

      comp=$(echo "$distance < $best_distance" | bc)
      if [[ "$comp" -eq 1 ]]; then
        best_agent="$AgentID"
        best_city="$AgentCity"
        best_distance="$distance"
      fi
    fi
  done

  if [[ -n "$best_agent" ]]; then
    echo "$OrderID,$FromCity,$ToCity,$ItemType,$best_agent,$best_city,$best_distance" >> "$OUTPUT_FILE"
    
  else
    echo "No suitable agent found for Order $OrderID"
  fi
done


    
    
    
    

