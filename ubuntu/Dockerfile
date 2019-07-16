FROM gitlab/gitlab-runner:ubuntu

ENV APP_VERSION=v0.3.1

RUN apt-get update \ 
   && apt-get install -y ca-certificates apt-utils
RUN apt-get install -y software-properties-common \
   && add-apt-repository ppa:longsleep/golang-backports\
   && apt-get update\
   && apt-get install -y gcc g++ musl-dev golang-go build-essential \
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
   && apt-get purge -y apt-utils gcc g++ musl-dev golang-go build-essential\
   && apt-get autoremove -y\
   && rm -rf /go

