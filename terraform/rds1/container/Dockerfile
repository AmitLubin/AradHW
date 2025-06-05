FROM node:23-alpine
WORKDIR /app

COPY package.json .
RUN npm install

COPY . .

EXPOSE 3000

ENV AWS_REGION=il-central-1

CMD ["node", "server.js"]