ARG BASE_IMAGE
ARG STREAM
FROM ${BASE_IMAGE}:${STREAM}
COPY scripts/builder.sh /
RUN /builder.sh
