FROM gitlab/gitlab-runner:alpine-v11.5.1

ENV APP_VERSION=v0.2.0

RUN apk add --no-cache ca-certificates
RUN apk --no-cache add --virtual build-dependencies gcc g++ musl-dev go \
    && export GOPATH=/go \
    && export PATH=$GOPATH/bin:$PATH \
    && mkdir $GOPATH \
    && chmod -R 777 $GOPATH \
    && APP_REPO=github.com/awslabs/amazon-ecr-credential-helper \
    && git clone https://$APP_REPO $GOPATH/src/$APP_REPO \
    && cd $GOPATH/src/$APP_REPO \
    && git checkout $APP_VERSION \
    && GOOS=linux CGO_ENABLED=1 go build -installsuffix cgo \
       -a -ldflags '-s -w' -o /usr/bin/docker-credential-ecr-login \
       ./ecr-login/cli/docker-credential-ecr-login \
    && cd / \
    && apk del --purge -r build-dependencies \
    && rm -rf /go

