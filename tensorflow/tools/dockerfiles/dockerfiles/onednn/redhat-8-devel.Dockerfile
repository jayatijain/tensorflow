# Copyright 2019 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============================================================================
#
# THIS IS A GENERATED DOCKERFILE.
#
# This file was assembled from multiple pieces, whose use is documented
# throughout. Please refer to the TensorFlow dockerfiles documentation
# for more information.

ARG REDHAT_VERSION=latest

FROM registry.access.redhat.com/ubi8/ubi:${REDHAT_VERSION} AS base

ARG REDHAT_VERSION=latest

# Enable both PowerTools and EPEL otherwise some packages like hdf5-devel fail to install
RUN dnf --disableplugin=subscription-manager install -y 'dnf-command(config-manager)' && \
    dnf --disableplugin=subscription-manager config-manager --set-enabled powertools && \
    dnf --disableplugin=subscription-manager install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-"${REDHAT_VERSION}".noarch.rpm && \
    dnf --disableplugin=subscription-manager clean all

RUN yum update -y && \
    yum install -y \
        curl \
        freetype-devel \
        gcc \
        gcc-c++ \
        git \
        hdf5-devel \
        java-1.8.0-openjdk \
        java-1.8.0-openjdk-devel \
        java-1.8.0-openjdk-headless \
        libcurl-devel \
        make \
        pkg-config \
        rsync \
        sudo \
        unzip \
        zeromq-devel \
        zip \
        zlib-devel && \
        yum clean all

ENV CI_BUILD_PYTHON python

# CACHE_STOP is used to rerun future commands, otherwise cloning tensorflow will be cached and will not pull the most recent version
ARG CACHE_STOP=1
# Check out TensorFlow source code if --build-arg CHECKOUT_TF_SRC=1
ARG CHECKOUT_TF_SRC=0
ARG TF_BRANCH=master
RUN test "${CHECKOUT_TF_SRC}" -eq 1 && git clone https://github.com/tensorflow/tensorflow.git --branch "${TF_BRANCH}" --single-branch /tensorflow_src || true

# See http://bugs.python.org/issue19846
ENV LANG C.UTF-8
ARG PYTHON=python3

RUN yum --disableplugin=subscription-manager update -y && yum --disableplugin=subscription-manager install -y \
    ${PYTHON} \
    ${PYTHON}-pip \
    which && \
    yum --disableplugin=subscription-manager clean all


RUN ${PYTHON} -m pip --no-cache-dir install --upgrade \
    pip \
    setuptools

# Some TF tools expect a "python" binary
RUN ln -sf $(which ${PYTHON}) /usr/local/bin/python && \
    ln -sf $(which ${PYTHON}) /usr/local/bin/python3 && \
    ln -sf $(which ${PYTHON}) /usr/bin/python

# Install bazel
ARG BAZEL_VERSION=3.7.2
RUN mkdir /bazel && \
    curl -fSsL -o /bazel/installer.sh "https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh" && \
    curl -fSsL -o /bazel/LICENSE.txt "https://raw.githubusercontent.com/bazelbuild/bazel/master/LICENSE" && \
    bash /bazel/installer.sh && \
    rm -f /bazel/installer.sh

COPY bashrc /etc/bash.bashrc
RUN chmod a+rwx /etc/bash.bashrc
