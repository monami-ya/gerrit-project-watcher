FROM debian:10-slim

WORKDIR /app
ADD entrypoint.sh .
RUN chmod a+x entrypoint.sh && \
    apt-get update && apt-get install -y curl jq && apt-get clean -y

ENTRYPOINT [ "/app/entrypoint.sh" ]
