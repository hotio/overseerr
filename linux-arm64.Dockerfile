FROM node:14.17-alpine AS builder
RUN apk add --no-cache curl build-base python3 python2 sqlite
ARG VERSION
ENV COMMIT_TAG=${VERSION}
RUN mkdir /build && \
    curl -fsSL "https://github.com/sct/overseerr/archive/v${VERSION}.tar.gz" | tar xzf - -C "/build" --strip-components=1 && \
    cd /build && \
    yarn --frozen-lockfile --network-timeout 1000000 && \
    yarn build && \
    yarn install --production --ignore-scripts --prefer-offline && \
    yarn cache clean

FROM cr.hotio.dev/hotio/base@sha256:9f4741371043929c19ed6b7468b18aa9e07c66143ffe92bf8c2e2ff78d0193fa

EXPOSE 5055

RUN apk add --no-cache yarn

COPY --from=builder /build/dist "${APP_DIR}/dist"
COPY --from=builder /build/.next "${APP_DIR}/.next"
COPY --from=builder /build/node_modules "${APP_DIR}/node_modules"

ARG VERSION
RUN curl -fsSL "https://github.com/sct/overseerr/archive/v${VERSION}.tar.gz" | tar xzf - -C "${APP_DIR}" --strip-components=1 && \
    echo '{"commitTag": "'"${VERSION}"'"}' > "${APP_DIR}/committag.json" && \
    rm -rf "${APP_DIR}/config" && ln -s "${CONFIG_DIR}" "${APP_DIR}/config" && \
    chmod -R u=rwX,go=rX "${APP_DIR}"

COPY root/ /
