FROM ubuntu:18.04

COPY AutoInstallOpenFoam /AutoInstallOpenFoam

WORKDIR /AutoInstallOpenFoam

RUN bash installOpenFOAM.bash 2.2.2


ENTRYPOINT ["bash", "-c"]

CMD ["bash"]

