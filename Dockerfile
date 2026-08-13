# Stage 1: Builder
FROM golang:1.24.1-alpine AS builder

# Set build-time environment variables
ENV GO111MODULE=on
ENV CGO_ENABLED=0

WORKDIR /app

# Copy go.mod and go.sum and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the application source code
COPY . .

# Build the application
RUN go build -o /evilginx .

# Stage 2: Runner
FROM alpine:latest

WORKDIR /app

# Copy the built executable from the builder stage
COPY --from=builder /evilginx .

# Copy phishlets and redirectors
COPY phishlets/ ./phishlets/
COPY redirectors/ ./redirectors/

# Expose standard ports for HTTP, HTTPS, and DNS
EXPOSE 80
EXPOSE 443
EXPOSE 53/udp

# The command to run the application
# The BIND_IP and PORT environment variables will be used by the application
CMD ["./evilginx", "-p", "./phishlets", "-t", "./redirectors"]
