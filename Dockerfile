ARG BUILD_FROM=bitxeno/atvloadly:latest
FROM $BUILD_FROM

COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]