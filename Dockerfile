# Lightweight Nginx image to serve the static College Event website
FROM nginx:1.27-alpine

# Remove default nginx site content
RUN rm -rf /usr/share/nginx/html/*

# Copy our custom server config (adds /healthz and /nginx_status)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the static website
COPY app/ /usr/share/nginx/html/

# Generate a simple build-info.json at image build time so the site can show
# which build/version is currently deployed (visible at the bottom of Home page)
ARG BUILD_VERSION=v1
RUN BUILD_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ") && \
    echo "{\"version\":\"${BUILD_VERSION}\",\"buildTime\":\"${BUILD_TIME}\"}" \
    > /usr/share/nginx/html/build-info.json

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://localhost/healthz || exit 1

CMD ["nginx", "-g", "daemon off;"]
