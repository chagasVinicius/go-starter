# Build the Go Binary.
FROM golang:1.20 as build_go-starter-api
ENV CGO_ENABLED 0
ARG BUILD_REF

# Copy the source code into the container.
COPY . /service

# Build the service binary. We are doing this last since this will be different
# every time we run through this process.
WORKDIR /service/app/services/go-starter-api
RUN go build -ldflags "-X main.build=${BUILD_REF}"

# Build the admin binary.
WORKDIR /service/app/tooling/admin
RUN go build -ldflags "-X main.build=${BUILD_REF}"


# Run the Go Binary in Alpine.
FROM alpine:3.17
ARG BUILD_DATE
ARG BUILD_REF
RUN addgroup -g 1000 -S appuser && \
    adduser -u 1000 -h /service -G appuser -S appuser
COPY --from=build_go-starter-api --chown=appuser:appuser /service/app/services/go-starter-api/go-starter-api /service/go-starter-api
COPY --from=build_go-starter-api --chown=appuser:appuser /service/app/tooling/admin/admin /service/admin

WORKDIR /service
USER appuser
CMD ["./go-starter-api"]
