#!/bin/bash

# Echoes a message to indicate the start of dependency installation.
install_dependencies() {
    echo "Installing dependencies..."
    sudo apt-get update
    sudo apt-get install -y \
          binutils \
          git \
          gnupg2 \
          libc6-dev \
          libcurl4 \
          libedit2 \
          libgcc-9-dev \
          libpython2.7 \
          libsqlite3-0 \
          libstdc++-9-dev \
          libxml2 \
          libz3-dev \
          pkg-config \
          tzdata \
          uuid-dev \
          zlib1g-dev
}

# Imports PGP keys necessary for verifying the Swift tarball.
import_pgp_keys() {
    echo "Importing PGP keys..."
    gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys \
        '7463 A81A 4B2E EA1B 551F  FBCF D441 C977 412B 37AD' \
        '1BE1 E29A 084C B305 F397  D62A 9F59 7F4D 21A5 6D5F' \
        'A3BA FD35 56A5 9079 C068  94BD 63BC 1CFE 91D3 06C6' \
        '5E4D F843 FB06 5D7F 7E24  FBA2 EF54 30F0 71E1 B235' \
        '8513 444E 2DA3 6B7C 1659  AF4D 7638 F1FB 2B2B 08C4' \
        'A62A E125 BBBF BB96 A6E0  42EC 925C C1CC ED3D 1561' \
        '8A74 9566 2C3C D4AE 18D9  5637 FAF6 989E 1BC1 6FEA' \
        'E813 C892 820A 6FA1 3755  B268 F167 DF1A CF9C E069'
}

# Refreshes the PGP keys.
refresh_pgp_keys() {
    echo "Refreshing PGP keys..."
    gpg --keyserver hkp://keyserver.ubuntu.com --refresh-keys Swift
}

# Downloads and verifies the Swift tarball.
download_and_verify_swift() {
    echo "Downloading Swift 5.10 for Ubuntu 20.04..."
    wget https://download.swift.org/swift-5.10-release/ubuntu2004/swift-5.10-RELEASE/swift-5.10-RELEASE-ubuntu20.04.tar.gz
    wget https://download.swift.org/swift-5.10-release/ubuntu2004/swift-5.10-RELEASE-swift-5.10-RELEASE-ubuntu20.04.tar.gz.sig

    echo "Verifying the downloaded tarball..."
    gpg --verify swift-5.10-RELEASE-ubuntu20.04.tar.gz.sig swift-5.10-RELEASE-ubuntu20.04.tar.gz
    if [ $? -eq 0 ]; then
        echo "Verification successful."
    else
        echo "Verification failed. Do not use the downloaded toolchain."
        exit 1
    fi
}

# Extracts the Swift tarball and adds its directory to the PATH permanently.
extract_and_configure_path() {
    echo "Extracting Swift 5.10..."
    tar -xzf swift-5.10-RELEASE-ubuntu20.04.tar.gz

    echo "Adding Swift to the PATH permanently..."
    echo "export PATH=$(pwd)/swift-5.10-RELEASE-ubuntu20.04/usr/bin:\$PATH" >> ~/.bashrc
    source ~/.bashrc
}

# Verifies the installation of Swift.
verify_installation() {
    echo "Installation completed. Verifying Swift version..."
    swift --version
}

# Orchestrates all functions to perform the installation.
main() {
    install_dependencies
    import_pgp_keys
    refresh_pgp_keys
    download_and_verify_swift
    extract_and_configure_path
    verify_installation
}

main
