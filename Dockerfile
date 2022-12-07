FROM nimlang/nim:latest-alpine-onbuild
RUN nimble front
ENTRYPOINT ["./app"]
