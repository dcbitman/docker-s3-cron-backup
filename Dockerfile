FROM alpine:latest

RUN \
 apk -Uuv add curl groff less unzip openjdk8-jre bc && \
 curl -fL -o /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
 curl -fL -o /tmp/alpine-pkg-glibc.json https://api.github.com/repos/sgerrand/alpine-pkg-glibc/releases/latest && \
 latestReleaseTag=$(cat /tmp/alpine-pkg-glibc.json | grep '"tag_name"' | cut -d '"' -f4 | tr -d '\n' ) && \
 curl -fL -o /tmp/glibc-$latestReleaseTag.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$latestReleaseTag/glibc-$latestReleaseTag.apk && \
 apk add --no-cache /tmp/glibc-$latestReleaseTag.apk && \
 ln -s /lib/libz.so.1 /usr/glibc-compat/lib/ && \
 ln -s /lib/libc.musl-x86_64.so.1 /usr/glibc-compat/lib/ && \
 
 # Install libgcc_s.so.1 for pthread_cancel to work, see:
 # https://github.com/instrumentisto/gitlab-builder-docker-image/issues/6
 apk add --update --no-cache libgcc  && \
 ln -s /usr/lib/libgcc_s.so.1 /usr/glibc-compat/lib/ && \
 mkdir -p /aws && \
 curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscli-exe-linux-x86_64.zip  && \
 unzip awscli-exe-linux-x86_64.zip && \
 ./aws/install --bin-dir /usr/bin && \
 apk --purge -v del curl unzip && \
 rm -rf /var/cache/apk/* /tmp/* awscli-exe-linux-x86_64.zip && \
 aws --version
