# NocoDB on Google Cloud Run

This is a **personal fork** of [NocoDB](https://github.com/nocodb/nocodb).  
Below are **quick instructions** to build and deploy it on **Google Cloud Run**.

## 1. Prerequisites

- **Google Cloud project** with [billing enabled](https://cloud.google.com/billing/docs/how-to/modify-project).
- **Google Cloud CLI** installed and authenticated:
  ```bash
  gcloud auth login
  gcloud config set project <YOUR_PROJECT_ID>
  ```
- **Docker** installed locally (to build and push the image).
- A **fork** (this repo) cloned locally.

## 2. Create or Update Your Dockerfile

In the root of this repo, ensure you have a `Dockerfile` that builds NocoDB.  
For example:

```dockerfile
# Use an official Node.js runtime as the base (Node 18 recommended)
FROM node:18-alpine

# Create app directory
WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml ./

# Install pnpm
RUN npm install -g pnpm

# Install dependencies
RUN pnpm install

# Copy the rest of your source code
COPY . .

# Build NocoDB
RUN pnpm run build

# Expose port 8080 (the default NocoDB port)
EXPOSE 8080

# Start the NocoDB server
CMD ["pnpm", "run", "start"]
```

Adjust commands (e.g., `build`, `start`) if your fork’s scripts differ.

## 3. Build & Push the Docker Image

From your local repo folder:

1. **Build** the image (replace `YOUR_PROJECT_ID` with your GCP project ID):
   ```bash
   docker build -t gcr.io/YOUR_PROJECT_ID/nocodb:latest .
   ```

2. **Enable** Container Registry (or Artifact Registry):
   ```bash
   gcloud services enable containerregistry.googleapis.com
   ```
   
3. **Push** the image:
   ```bash
   docker push gcr.io/YOUR_PROJECT_ID/nocodb:latest
   ```

*(If you prefer [Artifact Registry](https://cloud.google.com/artifact-registry), tag/push accordingly, e.g. `LOCATION-docker.pkg.dev/YOUR_PROJECT_ID/REPO_NAME/nocodb:latest`.)*

## 4. Deploy to Cloud Run

```bash
gcloud run deploy nocodb \
  --image gcr.io/YOUR_PROJECT_ID/nocodb:latest \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

- Replace `nocodb` with the service name you want.
- Replace `gcr.io/YOUR_PROJECT_ID/nocodb:latest` with your image path.
- Choose a region you prefer (e.g., `us-central1`).
- `--allow-unauthenticated` makes NocoDB public. (You can require auth if you’d like.)

When it finishes, you’ll get a URL to access NocoDB!

## 5. Configure for Persistent Storage (Optional)

By default, NocoDB uses **SQLite** stored in the container’s filesystem — data is **ephemeral** (lost if the container restarts).

To use a **managed Postgres** (e.g., [Cloud SQL for PostgreSQL](https://cloud.google.com/sql/docs/postgres)), set environment variables:

```bash
gcloud run services update nocodb \
  --region us-central1 \
  --update-env-vars=NC_DB="pg://<DB_HOST>:5432?u=<USER>&p=<PASS>&d=<DB_NAME>" \
  --update-env-vars=NC_AUTH_JWT_SECRET="random-secret-key"
```

You might also need a [Cloud SQL Auth Proxy or VPC connector](https://cloud.google.com/sql/docs/postgres/connect-run) for secure connectivity.

## 6. Done!

- Go to the **Cloud Run** URL from the deployment step.
- Complete NocoDB’s initial setup in the browser.
- Enjoy your self-hosted NocoDB on GCP!

---

### License

This project remains under [AGPLv3](./LICENSE), inherited from the upstream [NocoDB project](https://github.com/nocodb/nocodb).

### More Info

- [NocoDB Docs](https://docs.nocodb.com/)
- [NocoDB GitHub](https://github.com/nocodb/nocodb)
- [Google Cloud Run Docs](https://cloud.google.com/run/docs)

---

**Happy self-hosting!** If you have questions or issues, check the [NocoDB community on Discord](https://discord.gg/5RgZmkW) or the [GCP Cloud Run docs](https://cloud.google.com/run/docs).