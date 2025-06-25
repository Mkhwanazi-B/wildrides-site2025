const mqtt = require('mqtt');
const fs = require('fs');
const path = require('path');

// Replace with your AWS IoT endpoint, e.g. 'a1b2c3d4e5f6g7-ats.iot.us-east-1.amazonaws.com'
const host = 'a1ek90iefg9ozw-ats.iot.eu-north-1.amazonaws.com';
const topic = 'coldtracker/sensordata';

const options = {
  host,
  port: 8883,
  protocol: 'mqtts',
  clientId: 'ColdTrackerSimulator01',
  key: fs.readFileSync(path.join(__dirname, 'private.pem.key')),
  cert: fs.readFileSync(path.join(__dirname, 'device.pem.crt')),
  ca: fs.readFileSync(path.join(__dirname, 'AmazonRootCA1.pem'))
};

const client = mqtt.connect(options);

client.on('connect', () => {
  console.log('✅ Connected to AWS IoT');

  const payload = JSON.stringify({
    sensor_id: 'simulator01',
    temperature: 4.3,
    timestamp: new Date().toISOString(),
    location: {
      lat: -26.2041,
      lng: 28.0473
    }
  });

  client.publish(topic, payload, {}, (err) => {
    if (err) {
      console.error('❌ Publish failed:', err);
    } else {
      console.log('📤 Message sent:', payload);
    }
    client.end(); // Disconnect after sending
  });
});

client.on('error', (error) => {
  console.error('Connection error:', error);
  client.end();
});
