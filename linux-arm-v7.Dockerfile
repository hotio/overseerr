FROM node:12.18-alpine AS builder
RUN apk add --no-cache curl python3
ARG VERSION
RUN mkdir /build && \
    curl -fsSL "https://github.com/sct/overseerr/archive/v${VERSION}.tar.gz" | tar xzf - -C "/build" --strip-components=1 && \
    cd /build && \
    yarn --frozen-lockfile && \
    yarn build && \
    yarn install --production --ignore-scripts --prefer-offline && \
    yarn cache clean

FROM hotio/base@sha256:82a916191ff569cb247ee6895beac151cb867e518b932f7105c0ef9c560dfbae

EXPOSE 5055

RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community yarn

COPY --from=builder /build/dist "${APP_DIR}/dist"
COPY --from=builder /build/.next "${APP_DIR}/.next"
COPY --from=builder /build/node_modules "${APP_DIR}/node_modules"

ARG VERSION
RUN curl -fsSL "https://github.com/sct/overseerr/archive/v${VERSION}.tar.gz" | tar xzf - -C "${APP_DIR}" --strip-components=1 && \
    rm -rf "${APP_DIR}/config" && ln -s "${CONFIG_DIR}/app" "${APP_DIR}/config" && \
    chmod -R u=rwX,go=rX "${APP_DIR}"

COPY root/ /
