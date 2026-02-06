# ─── Stage 1: Build Flutter Web ───
FROM ghcr.io/cirruslabs/flutter:3.27.4 AS builder

WORKDIR /app

# Copy pubspec first for dependency caching
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy the rest of the project
COPY . .

# Build Flutter web (release)
RUN flutter build web --release --no-tree-shake-icons

# ─── Stage 2: Serve with Nginx ───
FROM nginx:alpine

# Remove default nginx page
RUN rm -rf /usr/share/nginx/html/*

# Copy Flutter web build output
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy custom nginx config (API proxy + SPA routing)
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
