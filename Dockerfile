FROM golang:1.19.0-alpine as build-env

RUN mkdir /app
WORKDIR /app

COPY go.mod ./

RUN go mod download

RUN addgroup -g 10014 choreo && \
    adduser  --disabled-password  --no-create-home --uid 10014 --ingroup choreo choreouser

# Copy the Go source code into the container
COPY docker-hello-world-manual-task .

ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -o /go/bin/app -buildvcs=false

FROM alpine
COPY --from=build-env /go/bin/app /go/bin/app

USER 10014
ENTRYPOINT ["/go/bin/app"]
