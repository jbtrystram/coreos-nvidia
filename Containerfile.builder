ARG BASE_IMAGE
FROM ${BASE_IMAGE}
COPY scripts/builder.sh /
RUN /builder.sh
