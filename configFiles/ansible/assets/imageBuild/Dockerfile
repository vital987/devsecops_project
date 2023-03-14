FROM eclipse-temurin:19.0.2_7-jre-jammy

COPY testapp.jar /opt/testapp.jar

RUN apt update && \
    apt install -y net-tools && \
    apt autoclean && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT [ "java", "-jar" , "/opt/testapp.jar" ]

EXPOSE 8080
