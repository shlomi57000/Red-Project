FROM node:latest
WORKDIR /app
COPY . .
ARG server_ip
ENV REACT_APP_BACKEND $server_ip
RUN npm install
RUN REACT_APP_BACKEND=${server_ip} \
    npm run build
EXPOSE 3000
CMD ["npm", "start"]