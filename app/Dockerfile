FROM node:26-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 make g++ unixodbc-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /backend
COPY backend/package.json backend/package-lock.json ./
RUN npm ci 
COPY /backend ./
RUN npm run build

WORKDIR /frontend
COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci
COPY /frontend ./
RUN npm run build

ENV NODE_ENV=production \
    PORT=8080 \
    STANDALONE_MODE=true \
    HOST=0.0.0.0

RUN mkdir /backend/frontend-build
RUN cp -r /frontend/dist/. /backend/frontend-build/

WORKDIR /backend

EXPOSE ${PORT}

CMD [ "node", "--enable-source-maps", "dist/main.mjs" ]