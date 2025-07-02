#!/bin/bash

# Define the IP pattern and rate limit
IP_PATTERN="172."
RATE_LIMIT=5  # Number of requests per minute

# Function to lookup events and filter by IP pattern
lookup_events() {
  aws cloudtrail lookup-events --output json | jq '.Events[] | select(.SourceIPAddress | startswith("'"$IP_PATTERN"'"))'
}

# Main loop to enforce rate limit
while true; do
  lookup_events
  sleep $((8 / RATE_LIMIT))
done

