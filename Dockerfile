FROM ghcr.io/graalvm/graalvm-community:21 AS build
WORKDIR /app
COPY . .

# Build the native image
RUN chmod +x ./mvnw
RUN ./mvnw clean install -Pnative

FROM debian:trixie-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends sendmail sendmail-cf m4 sasl2-bin && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /etc/mail

COPY ./scripts/sendmail.mc /etc/mail/sendmail.mc
RUN m4 /etc/mail/sendmail.mc > /etc/mail/sendmail.cf && \
    echo "Connect:172 RELAY" >> /etc/mail/access && \
    echo "Connect:10 RELAY" >> /etc/mail/access && \
    make

WORKDIR /app

COPY --from=build /app/target/send-mail-server /app/send-mail-server
RUN chmod +x /app/send-mail-server

ENV PORT=80

EXPOSE 25
EXPOSE 80

USER root

SHELL ["/bin/bash", "-c"]
ENTRYPOINT sendmail -bd -q15m && cat /etc/hosts && ./send-mail-server && echo 'Subject: sendmail test' | sendmail -v test@gmail.com
