FROM golang:1.17-alpine as builder

WORKDIR /go/src/github.com/micromdm/micromdm/

ARG TARGETARCH
ARG TARGETOS

ENV CGO_ENABLED=0 \
	GOARCH=$TARGETARCH \
	GOOS=$TARGETOS

COPY . .

RUN apk --update add ca-certificates git

RUN go build -o build/linux/micromdm ./cmd/micromdm
RUN go build -o build/linux/mdmctl ./cmd/mdmctl

FROM scratch

COPY --from=builder /go/src/github.com/micromdm/micromdm/build/linux/micromdm /usr/bin/
COPY --from=builder /go/src/github.com/micromdm/micromdm/build/linux/mdmctl /usr/bin/
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

EXPOSE 80 443
VOLUME ["/var/db/micromdm"]
CMD ["micromdm", "serve"]
