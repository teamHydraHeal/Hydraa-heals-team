# ─── Serve pre-built Flutter web with Nginx ───
# Run `flutter build web --release` on the host before building this image.
FROM nginx:alpine

# Remove default nginx page
RUN rm -rf /usr/share/nginx/html/*

# Copy pre-built Flutter web output (built on host)
COPY build/web /usr/share/nginx/html

# Copy custom nginx config (API proxy + SPA routing)
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
