#!/bin/bash

# Script to install yt-dlp for YouTube thumbnail support
# This should be run on the remote server

set -e

echo "📥 Installing yt-dlp for YouTube thumbnail support..."

# Detect OS and install yt-dlp
if command -v yum &> /dev/null; then
    echo "📦 Detected Amazon Linux/RHEL/CentOS"
    echo "Installing yt-dlp..."
    sudo yum update -y
    sudo yum install -y python3 python3-pip
    sudo pip3 install yt-dlp
    
elif command -v apt-get &> /dev/null; then
    echo "📦 Detected Ubuntu/Debian"
    echo "Installing yt-dlp..."
    sudo apt-get update
    sudo apt-get install -y python3 python3-pip
    sudo pip3 install yt-dlp
    
elif command -v brew &> /dev/null; then
    echo "📦 Detected macOS with Homebrew"
    echo "Installing yt-dlp..."
    brew install yt-dlp
    
else
    echo "❌ Unsupported OS. Please install yt-dlp manually:"
    echo "   Visit: https://github.com/yt-dlp/yt-dlp#installation"
    echo ""
    echo "   Or use pip: sudo pip3 install yt-dlp"
    exit 1
fi

# Verify installation
if command -v yt-dlp &> /dev/null; then
    echo "✅ yt-dlp installed successfully!"
    echo "📊 Version: $(yt-dlp --version)"
    echo ""
    echo "🎥 YouTube thumbnails will now be fetched automatically!"
    echo "💡 Test with: cd newsfeed && ./add.sh 'https://youtube.com/watch?v=...'"
else
    echo "❌ yt-dlp installation failed"
    exit 1
fi 