FROM ubuntu:19.04 AS base
FROM base AS build
ARG QEMU_VERSION=4.0.0
RUN apt-get update && apt-get install -y \
		bison \
        build-essential \
		curl \
		flex \
        libbz2-dev \
		libglib2.0-dev \
        libjpeg-dev \
        libpixman-1-dev \
        libpng-dev \
        libusb-1.0-0-dev \
        pkg-config \
        python \
        xz-utils \
	&& rm -rf /var/lib/apt/lists/*
RUN mkdir /build; \
    curl -o /build/qemu.tar.xz https://download.qemu.org/qemu-${QEMU_VERSION}.tar.xz; \
    tar -C /build --strip-components=1 -xf /build/qemu.tar.xz; \
    rm -f /build/qemu.tar.xz
WORKDIR /build
FROM build as build-static
RUN ./configure --static --target-list=aarch64-linux-user --disable-kvm 
RUN make -j2 && make install
FROM build as build-dynamic
RUN ./configure --target-list=aarch64-linux-user,aarch64-softmmu --disable-kvm 
RUN make -j2 && make install
FROM base AS runtime
RUN apt-get update && apt-get install --no-install-recommends -y \
		libglib2.0-bin \
	&& rm -rf /var/lib/apt/lists/*
COPY --from=build /usr/local /usr/local
COPY --from=build-static /usr/local/bin/qemu-aarch64 /usr/local/bin/qemu-aarch64-static

