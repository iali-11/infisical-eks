FROM node:26-slim AS backend

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 make g++ unixodbc-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /backend
COPY backend/package.json backend/package-lock.json ./
RUN npm ci 
COPY /backend ./
RUN npm run build && npm ci --omit=dev

FROM node:26-slim AS frontend

WORKDIR /frontend
COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci
COPY /frontend ./
RUN npm run build

FROM node:26-slim AS runtime

RUN apt-get update && apt-get install -y --no-install-recommends \
    unixodbc-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /backend
COPY --from=backend /backend/dist/ ./dist
COPY --from=backend /backend/node_modules/ ./node_modules
COPY --from=backend /backend/package.json/ ./
COPY --from=frontend /frontend/dist/. ./frontend-build

ENV NODE_ENV=production \
    PORT=8080 \
    STANDALONE_MODE=true \
    HOST=0.0.0.0

EXPOSE ${PORT}

CMD [ "node", "--enable-source-maps", "dist/main.mjs" ]