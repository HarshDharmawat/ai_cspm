# the compilation phase

FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod ./
COPY main.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o payvault-app main.go

# the runtime phase

FROM alpine:3.19
RUN apk --no-cache add ca-certificates
WORKDIR /app
COPY --from=builder /app/payvault-app .
EXPOSE 8080
CMD [ "./payvault-app" ]
