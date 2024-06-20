# Use official Swift image
FROM swift:5.3.3

# Install Csound
RUN apt-get update && apt-get install -y     software-properties-common     wget     nano     csound     git

# Install LilyPond
RUN wget http://lilypond.org/download/binaries/linux/lilypond-2.24.2-1.linux-64.sh     && chmod +x lilypond-2.24.2-1.linux-64.sh     && ./lilypond-2.24.2-1.linux-64.sh --batch --prefix=/usr/local

# Install Vapor and orchestration tools
RUN apt-get install -y libssl-dev libsqlite3-dev
RUN swift build && swift package resolve

# Set working directory and copy API files
WORKDIR /workspace
COPY . /workspace

# Start the Vapor server
CMD ["swift", "run"]
