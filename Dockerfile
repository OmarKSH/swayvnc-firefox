ARG SWAYVNC_VERSION=latest
ARG GECKODRIVER_VERSION=0.31.0
FROM ghcr.io/bbusse/swayvnc:${SWAYVNC_VERSION}
LABEL maintainer="Björn Busse <bj.rn@baerlin.eu>"
LABEL org.opencontainers.image.source https://github.com/bbusse/swayvnc-firefox

ARG GECKODRIVER_VERSION

ENV ARCH="x86_64" \
    USER="firefox-user" \
    APK_ADD="python3 py3-pip firefox" \
    APK_DEL=""

# Add packages
USER root

# Add application user and application
# Cleanup: Remove files and users
RUN addgroup -S $USER && adduser -S $USER -G $USER -G abuild \
    # https://gitlab.alpinelinux.org/alpine/aports/-/issues/11768
    && sed -i -e 's/https/http/' /etc/apk/repositories \
    && apk add --no-cache ${APK_ADD} \
    && apk del --no-cache ${APK_DEL} \
    && rm -rf \
      /usr/share/man/* \
      /usr/includes/* \
      /var/cache/apk/* \

    # Get geckodriver
    && wget https://github.com/mozilla/geckodriver/releases/download/v${GECKODRIVER_VERSION}/geckodriver-v${GECKODRIVER_VERSION}-linux64.tar.gz \
    && tar -xzf geckodriver-v${GECKODRIVER_VERSION}-linux64.tar.gz -C /usr/bin \
    && rm geckodriver-v${GECKODRIVER_VERSION}-linux64.tar.gz \
    && geckodriver --version \

    # Add latest webdriver-util script for firefox automation
    && wget -P /usr/local/bin https://raw.githubusercontent.com/bbusse/webdriver-util/main/webdriver_util.py \
    && chmod +x /usr/local/bin/webdriver_util.py \
    && wget -O /tmp/requirements_webdriver.txt https://raw.githubusercontent.com/bbusse/webdriver-util/main/requirements.txt \

    # Add stream-controller for stream handling
    && wget -P /usr/local/bin https://raw.githubusercontent.com/bbusse/stream-controller/main/controller.py \
    && chmod +x /usr/local/bin/controller.py \
    && wget -O /tmp/requirements_controller.txt https://raw.githubusercontent.com/bbusse/stream-controller/main/requirements.txt \

    # Run controller.py
    && echo "exec controller.py --debug=$DEBUG" >> /etc/sway/config.d/firefox

USER $USER

RUN pip3 install --user -r requirements_controller.txt
RUN pip3 install --user -r requirements_webdriver.txt

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
