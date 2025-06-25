# Use lightweight alpine Linux base image
FROM alpine:latest

# Install curl and bash
RUN apk add --no-cache curl bash

# Copy the load_simulator.sh script into the container
COPY load_simulator.sh /app/load_simulator.sh

# Make the script executable
RUN chmod +x /app/load_simulator.sh

# Set working directory
WORKDIR /app

# Run the load simulator script when the container starts
CMD ["./load_simulator.sh"]
