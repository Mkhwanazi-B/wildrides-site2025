FROM alpine:latest

RUN apk add --no-cache bash curl

COPY load_simulator.sh /usr/local/bin/load_simulator.sh

RUN chmod +x /usr/local/bin/load_simulator.sh

CMD ["/usr/local/bin/load_simulator.sh"]
