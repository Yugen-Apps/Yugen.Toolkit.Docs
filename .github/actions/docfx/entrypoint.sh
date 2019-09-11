#!/bin/sh -l

echo "Updating..."
apt-get update
apt-get install -y unzip wget gnupg gnupg2 gnupg1

# Install Mono 
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" | tee /etc/apt/sources.list.d/mono-official-stable.list
apt update
apt install mono-complete --yes

# Get DocFX
wget https://github.com/dotnet/docfx/releases/download/v2.45/docfx.zip
unzip docfx.zip -d _docfx
# cd docs

# Build docs
mono _docfx/docfx.exe
