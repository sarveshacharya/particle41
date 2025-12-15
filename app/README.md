# SimpleTimeService (app)

A minimal NestJS service that returns the current timestamp and caller IP at the root path. This directory also contains the Dockerfile used to build a non-root container image for deployment.

## Local development
```bash
npm install
PORT=3002 npm run start:dev
or npm run start:prod after building
```
Request the service locally:
```bash
curl http://localhost:3002/
```

## Docker workflow
```bash
docker build -t particle41:latest .
docker run -p 3002:3002 -e PORT=3002 particle41:latest
```
Push the image to your registry and reference the tag from `terraform/terraform.tfvars` for infrastructure deployments.

Image is also built using github actions and pushed to docker registry.
