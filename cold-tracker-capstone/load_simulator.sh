# Send a single POST request

sensor_id="sensor_1"
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
temperature=$(( RANDOM % 30 - 10 ))  # random temp between -10 and +19

curl -s -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -d "{\"sensor_id\":\"$sensor_id\", \"timestamp\":\"$timestamp\", \"temperature\":$temperature}"

echo "1 request sent."

