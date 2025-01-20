# Use an official Node.js runtime as the base
FROM node:18-alpine

# Create app directory
WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml ./

# Install pnpm (NocoDB uses pnpm in the monorepo)
RUN npm install -g pnpm

# Install dependencies
RUN pnpm install

# Copy the rest of the repo
COPY . .

# Build the NocoDB packages
RUN pnpm run build

# Expose port 8080 (the default NocoDB port)
EXPOSE 8080

# Start NocoDB server
CMD ["pnpm", "run", "start"]
