FROM node:14.17-alpine AS builder
RUN apk add --no-cache curl
ARG VERSION
ENV COMMIT_TAG=${VERSION}
RUN mkdir /build && \
    curl -fsSL "https://github.com/sct/overseerr/archive/${VERSION}.tar.gz" | tar xzf - -C "/build" --strip-components=1 && \
    cd /build && \
    yarn --frozen-lockfile --network-timeout 1000000 && \
    yarn build && \
    yarn install --production --ignore-scripts --prefer-offline && \
    yarn cache clean

FROM cr.hotio.dev/hotio/base@sha256:51b4032b5584538d5987a759e74201ef2626502750efe77d4f7124eb56284c4e

EXPOSE 5055

RUN apk add --no-cache yarn

COPY --from=builder /build/dist "${APP_DIR}/dist"
COPY --from=builder /build/.next "${APP_DIR}/.next"
COPY --from=builder /build/node_modules "${APP_DIR}/node_modules"

ARG VERSION
RUN curl -fsSL "https://github.com/sct/overseerr/archive/${VERSION}.tar.gz" | tar xzf - -C "${APP_DIR}" --strip-components=1 && \
    echo '{"commitTag": "'"${VERSION}"'"}' > "${APP_DIR}/committag.json" && \
    rm -rf "${APP_DIR}/config" && ln -s "${CONFIG_DIR}" "${APP_DIR}/config" && \
    chmod -R u=rwX,go=rX "${APP_DIR}"

COPY root/ /
