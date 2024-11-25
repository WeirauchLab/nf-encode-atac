FROM ubuntu:noble

# Install lazygit
ADD starship.toml /root/.config/starship.toml
ENV PATH="/usr/local/lazygit:${PATH}"
ENV JAVA_HOME=/opt/java/openjdk
COPY --from=eclipse-temurin:21 $JAVA_HOME $JAVA_HOME
ENV PATH="${JAVA_HOME}/bin:${PATH}"
SHELL ["/bin/bash", "-c"]

RUN apt-get update \
	&& apt-get install -y wget git curl unzip zip build-essential vim rpm2cpio cpio \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# install lazygit
RUN mkdir -p /usr/local/lazygit \
	&& cd /usr/local/lazygit \
	&& wget https://github.com/jesseduffield/lazygit/releases/download/v0.44.1/lazygit_0.44.1_Linux_x86_64.tar.gz -O lazygit.tar.gz \
	&& tar -xvf lazygit.tar.gz \
	&& rm lazygit.tar.gz \
	&& chmod +x lazygit

# install nextflow
RUN curl -s https://get.nextflow.io | bash \
	&& mv nextflow /usr/local/bin \
	&& chmod +x /usr/local/bin/nextflow \
	&& nextflow -v

# install nf-test
RUN curl -fsSL https://get.nf-test.com | bash \
	&& mv nf-test /usr/local/bin \
	&& chmod +x /usr/local/bin/nf-test \
	&& nf-test version

# install starship
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y \
	&& echo 'eval "$(starship init bash)"' >> ~/.bashrc

# install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# install miniconda
ENV CONDA_DIR=/opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH
RUN curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
	&& bash Miniconda3-latest-Linux-x86_64.sh -b -p $CONDA_DIR \
	&& rm Miniconda3-latest-Linux-x86_64.sh \
	&& $CONDA_DIR/bin/conda init bash

# install apptainer
ENV PATH=/usr/local/apptainer/bin:$PATH
RUN curl -s https://raw.githubusercontent.com/apptainer/apptainer/main/tools/install-unprivileged.sh | \
	bash -s - /usr/local/apptainer