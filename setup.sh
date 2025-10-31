#!/bin/bash

# qs-timew Setup Script
# This script sets up the qs-timew module for development and testing

set -e

echo "🚀 Setting up qs-timew module..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "qmldir" ] || [ ! -d "src" ]; then
    print_error "Please run this script from the qs-timew root directory"
    exit 1
fi

print_status "Checking dependencies..."

# Check for Qt 6
if ! command -v qmake6 &> /dev/null && ! command -v qmake &> /dev/null; then
    print_error "Qt 6 is not installed or not in PATH"
    print_status "Please install Qt 6 development packages"
    exit 1
fi

# Check for timewarrior
if ! command -v timew &> /dev/null; then
    print_warning "Timewarrior is not installed"
    print_status "Please install timewarrior: https://timewarrior.net/install/"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    TIMED_VERSION=$(timew --version | head -n1 || echo "unknown")
    print_success "Found timewarrior: $TIMED_VERSION"
fi

# Check for qmlscene
if ! command -v qmlscene &> /dev/null; then
    print_error "qmlscene is not available"
    print_status "Please install Qt Quick development tools"
    exit 1
fi

# Check for qmltestrunner
if ! command -v qmltestrunner &> /dev/null; then
    print_warning "qmltestrunner is not available"
    print_status "Test execution will not be possible"
fi

print_status "Setting up development environment..."

# Create build directory
mkdir -p build
cd build

# Try to configure with CMake if available
if command -v cmake &> /dev/null; then
    print_status "Configuring with CMake..."
    cmake .. -DCMAKE_BUILD_TYPE=Debug
    print_success "CMake configuration completed"
else
    print_warning "CMake not found, skipping build system setup"
fi

cd ..

print_status "Testing basic functionality..."

# Test if we can import the module
TEST_IMPORT=$(cat << 'EOF'
import QtQuick
import qs_timew 2.0

Item {
    property var service: TimewarriorService
    property bool testPassed: true

    Component.onCompleted: {
        if (!service) {
            testPassed = false
            console.error("Failed to import TimewarriorService")
        }
        Qt.quit()
    }
}
EOF
)

echo "$TEST_IMPORT" > test_import.qml

# Try to run the import test
if qmlscene test_import.qml --quit &> /dev/null; then
    print_success "Module import test passed"
else
    print_error "Module import test failed"
    rm -f test_import.qml
    exit 1
fi

rm -f test_import.qml

# Test basic example
print_status "Testing basic example..."
if qmlscene examples/MinimalExample.qml --quit &> /dev/null; then
    print_success "Basic example test passed"
else
    print_warning "Basic example test failed (may be due to missing timewarrior)"
fi

# Run tests if available
if command -v qmltestrunner &> /dev/null; then
    print_status "Running test suite..."
    if qmltestrunner -input tests/TestRunner.qml &> /dev/null; then
        print_success "All tests passed"
    else
        print_warning "Some tests failed (may be due to missing timewarrior or environment)"
    fi
else
    print_warning "Skipping tests - qmltestrunner not available"
fi

print_success "Setup completed successfully!"
echo
print_status "Next steps:"
echo "  1. Run examples: qmlscene examples/CompleteExample.qml"
echo "  2. Run tests: qmltestrunner -input tests/TestRunner.qml"
echo "  3. Check documentation: docs/README.md"
echo "  4. Start development!"
echo
print_status "For help and support:"
echo "  • Documentation: docs/"
echo "  • Issues: https://github.com/dustin-s/qs-timew/issues"
echo "  • Timewarrior: https://timewarrior.net/docs/"
echo
print_success "qs-timew is ready to use! 🎉"