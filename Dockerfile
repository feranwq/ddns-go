# build stage
FROM --platform=$BUILDPLATFORM golang:bullseye AS builder

WORKDIR /app
COPY . .
ARG TARGETOS TARGETARCH

RUN apt update && \
    apt install -y git make tzdata && \
    GOOS=$TARGETOS GOARCH=$TARGETARCH make clean build

# final stage
FROM debian:bullseye
LABEL name=ddns-go
LABEL url=https://github.com/jeessy2/ddns-go

WORKDIR /app
RUN apt update && \
    apt install -y bash dnsutils curl netcat iproute2
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
ENV TZ=Asia/Shanghai
COPY --from=builder /app/ddns-go /app/ddns-go
EXPOSE 9876
ENTRYPOINT ["/app/ddns-go"]
CMD ["-l", ":9876", "-f", "300"]
