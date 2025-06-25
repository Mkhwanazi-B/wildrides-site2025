# Use official Node.js LTS image
FROM node:18-alpine

# Create app directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json if you have them
# (optional if you have dependencies)
COPY package*.json ./

# Install dependencies (mqtt)
RUN npm install mqtt

# Copy your source files (index.js + certs)
COPY index.js .
COPY private.pem.key .
COPY device.pem.crt .
COPY AmazonRootCA1.pem .

# Command to run the simulator
CMD ["node", "index.js"]
