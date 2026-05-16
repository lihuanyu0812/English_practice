FROM node:24-alpine AS backend
WORKDIR /app/backend
COPY backend/package*.json ./
RUN npm install --omit=dev
COPY backend ./
EXPOSE 8016
CMD ["npm", "start"]

FROM node:24-alpine AS frontend-build
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm install
COPY frontend ./
RUN npm run build

FROM nginx:1.27-alpine AS frontend
COPY --from=frontend-build /app/frontend/dist /usr/share/nginx/html
COPY frontend/default.conf.template /etc/nginx/templates/default.conf.template
EXPOSE 80
