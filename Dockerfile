FROM golang:1.11-alpine

ARG DAPPER_HOST_ARCH
ENV ARCH $DAPPER_HOST_ARCH

RUN apk -U add bash git gcc musl-dev docker vim less file curl wget ca-certificates
RUN go get -d golang.org/x/lint/golint && \
    git -C /go/src/golang.org/x/lint/golint checkout -b current 06c8688daad7faa9da5a0c2f163a3d14aac986ca && \
    go install golang.org/x/lint/golint && \
    rm -rf /go/src /go/pkg
RUN go get -d golang.org/x/tools/cmd/goimports && \
    git -C /go/src/golang.org/x/tools/cmd/goimports checkout -b release-branch.go1.12 origin/release-branch.go1.12 && \
    go install golang.org/x/tools/cmd/goimports && \
    rm -rf /go/src /go/pkg

ENV DAPPER_ENV REPO TAG DRONE_TAG
ENV DAPPER_SOURCE /go/src/github.com/rancher/security-scan/
ENV DAPPER_OUTPUT ./bin ./dist
ENV DAPPER_DOCKER_SOCKET true
ENV HOME ${DAPPER_SOURCE}
WORKDIR ${DAPPER_SOURCE}

ENTRYPOINT ["./scripts/entry"]
CMD ["ci"]
