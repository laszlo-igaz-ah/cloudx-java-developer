FROM ubuntu:22.04

RUN apt-get update &&  \
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release &&  \
    apt-get clean &&  \
    rm -rf /var/lib/apt/lists/*
RUN mkdir -p /etc/apt/keyrings
RUN curl -sLS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/keyrings/microsoft.gpg > /dev/null
RUN chmod go+r /etc/apt/keyrings/microsoft.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | tee /etc/apt/sources.list.d/azure-cli.list

RUN apt-get update && \
    apt-get install -y azure-cli &&  \
    apt-get clean &&  \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update &&  \
    apt-get install -y gnupg software-properties-common wget &&  \
    apt-get clean &&  \
    rm -rf /var/lib/apt/lists/*
RUN wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

RUN gpg --no-default-keyring \
    --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    --fingerprint

RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
RUN apt-get update && \
    apt-get install -y terraform &&  \
    apt-get clean &&  \
    rm -rf /var/lib/apt/lists/*

