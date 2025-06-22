#!/bin/bash

# Test runner script for the newsfeed project
# Run from the tests directory

set -e

echo "🧪 Running newsfeed tests..."

# Run Go tests
echo "📝 Running Go tests..."
go test -v

echo "✅ All tests passed!" 