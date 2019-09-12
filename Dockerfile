# build phase
FROM node:alpine as builder
WORKDIR '/app'
COPY package*.json ./section6-frontend
RUN npm install
COPY ./section6-frontend .
RUN npm run build

# run phase
FROM nginx:stable-alpine
EXPOSE 80
COPY --from=builder /app/build /usr/share/nginx/html # check nginx document for directory