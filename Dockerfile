FROM golang:alpine AS build

ARG GIT_TAG=v1.0.1

ENV CGO_ENABLED=0
ENV GO111MODULE=off

WORKDIR /go/src/github.com/mailhog/MailHog

RUN apk add --no-cache git

RUN git clone \
    --depth 1 \
    --branch $GIT_TAG \
    https://github.com/mailhog/MailHog.git \
    /go/src/github.com/mailhog/MailHog

RUN go build



FROM scratch

# ca-certificates are required for the "release message" feature:
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /go/src/github.com/mailhog/MailHog/MailHog /bin/MailHog

# Avoid permission issues with host mounts by assigning a user/group with
# uid/gid 1000 (usually the ID of the first user account on GNU/Linux):
USER 1000:1000

ENTRYPOINT ["MailHog"]

# Expose the SMTP and HTTP ports used by default by MailHog:
EXPOSE 1025 8025
