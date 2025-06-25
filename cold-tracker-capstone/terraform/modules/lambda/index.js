const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();
const sns = new AWS.SNS();

const TABLE_NAME = process.env.DYNAMODB_TABLE;
const SNS_TOPIC_ARN = process.env.SNS_TOPIC_ARN;

// Hardcoded beer drinker location (Johannesburg)
const beerDrinkerLocation = { lat: -26.2041, lng: 28.0473 };

// Haversine distance function
function getDistanceKm(lat1, lon1, lat2, lon2) {
  const R = 6371;
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * Math.PI / 180) *
      Math.cos(lat2 * Math.PI / 180) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

exports.handler = async (event) => {
  // Support both API Gateway and IoT Core event formats
  const body = event.body
    ? (typeof event.body === 'string' ? JSON.parse(event.body) : event.body)
    : event;

  const { sensor_id, temperature, timestamp, location } = body;

  // Save sensor data to DynamoDB
  await dynamodb
    .put({
      TableName: TABLE_NAME,
      Item: {
        sensor_id,
        timestamp,
        temperature,
        location,
      },
    })
    .promise();

  // Check temperature and location alert condition
  if (temperature > 6.0 && location) {
    const distance = getDistanceKm(
      location.lat,
      location.lng,
      beerDrinkerLocation.lat,
      beerDrinkerLocation.lng
    );

    if (distance <= 15) {
      const message = `🍺 Warm beer alert! ${sensor_id} is reporting ${temperature}°C just ${distance.toFixed(
        1
      )} km from you.`;

      await sns
        .publish({
          Message: message,
          TopicArn: SNS_TOPIC_ARN,
        })
        .promise();
    }
  }

  return {
    statusCode: 200,
    body: JSON.stringify({ message: 'Sensor data processed successfully.' }),
  };
};
