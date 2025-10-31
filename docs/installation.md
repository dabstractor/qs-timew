# Installation Guide

Comprehensive installation instructions for the qs-timew module on various platforms and development environments.

## Table of Contents

- [System Requirements](#system-requirements)
- [Prerequisites](#prerequisites)
- [Installation Methods](#installation-methods)
- [Platform-Specific Instructions](#platform-specific-instructions)
- [Development Setup](#development-setup)
- [Integration Setup](#integration-setup)
- [Verification](#verification)
- [Troubleshooting](#installation-troubleshooting)

## System Requirements

### Minimum Requirements

- **Operating System**: Linux (Ubuntu 18.04+, Fedora 30+, Arch Linux, etc.)
- **Qt Version**: Qt 6.0 or higher
- **QML Runtime**: qmlscene or equivalent
- **Memory**: 50MB available RAM
- **Disk Space**: 10MB free disk space

### Recommended Requirements

- **Operating System**: Linux with systemd support
- **Qt Version**: Qt 6.2 or higher
- **QML Runtime**: qmlscene with QtQuick support
- **Memory**: 100MB available RAM
- **Disk Space**: 50MB free disk space
- **Development Tools**: git, cmake (for building from source)

### Supported Architectures

- x86_64 (Intel/AMD 64-bit)
- ARM64 (AArch64)
- ARMv7 (32-bit)

## Prerequisites

### Qt 6 Installation

#### Ubuntu/Debian

```bash
# Install Qt 6 development packages
sudo apt update
sudo apt install qt6-base-dev qt6-declarative-dev qt6-tools-dev

# Install QML runtime
sudo apt install qml6-module-qtquick-controls qml6-module-qtquick-layouts

# Verify installation
qmlscene --version
```

#### Fedora/CentOS/RHEL

```bash
# Install Qt 6 development packages
sudo dnf install qt6-qtbase-devel qt6-qtdeclarative-devel qt6-qttools-devel

# Install QML runtime
sudo dnf install qt6-qtquickcontrols2 qt6-qtquicklayouts

# Verify installation
qmlscene --version
```

#### Arch Linux

```bash
# Install Qt 6 packages
sudo pacman -S qt6-base qt6-declarative qt6-tools

# Install additional modules
sudo pacman -S qt6-quickcontrols2 qt6-quickcharts

# Verify installation
qmlscene --version
```

### timewarrior Installation

#### Ubuntu/Debian

```bash
# Install timewarrior
sudo apt install timewarrior

# Verify installation
timew --version
```

#### Fedora/CentOS/RHEL

```bash
# Enable EPEL repository (if needed)
sudo dnf install epel-release

# Install timewarrior
sudo dnf install timewarrior

# Verify installation
timew --version
```

#### Arch Linux

```bash
# Install timewarrior
sudo pacman -S timew

# Verify installation
timew --version
```

#### From Source (Universal)

```bash
# Clone timewarrior repository
git clone https://github.com/GothenburgBitFactory/timewarrior.git
cd timewarrior

# Build and install
cmake .
make
sudo make install

# Verify installation
timew --version
```

### Development Tools

```bash
# Install git (if not already installed)
sudo apt install git  # Ubuntu/Debian
sudo dnf install git  # Fedora/CentOS
sudo pacman -S git    # Arch Linux

# Install text editor (optional)
sudo apt install vscode  # Ubuntu/Debian
sudo dnf install code     # Fedora/CentOS
sudo pacman -S code       # Arch Linux (AUR)
```

## Installation Methods

### Method 1: Git Clone (Recommended)

This is the recommended method for development and testing.

```bash
# Clone the repository
git clone https://github.com/dustin-s/qs-timew.git
cd qs-timew

# Verify the installation
ls -la
# Should show: src/, examples/, tests/, docs/, package.json, etc.
```

### Method 2: Download Release

For production deployments, download a specific release.

```bash
# Download latest release (replace X.Y.Z with actual version)
wget https://github.com/dustin-s/qs-timew/archive/vX.Y.Z.tar.gz

# Extract the archive
tar -xzf vX.Y.Z.tar.gz
cd qs-timew-X.Y.Z

# Verify the installation
ls -la
```

### Method 3: Package Manager (Future)

When packages are available, you can install using your system package manager.

```bash
# Ubuntu/Debian (future)
sudo apt install qs-timew

# Fedora/CentOS (future)
sudo dnf install qs-timew

# Arch Linux (future)
sudo pacman -S qs-timew
```

## Platform-Specific Instructions

### Ubuntu 22.04 LTS

```bash
# Install dependencies
sudo apt update
sudo apt install qt6-base-dev qt6-declarative-dev qt6-tools-dev
sudo apt install qml6-module-qtquick-controls qml6-module-qtquick-layouts
sudo apt install timewarrior git

# Clone and set up qs-timew
git clone https://github.com/dustin-s/qs-timew.git
cd qs-timew

# Set up QML import path
echo 'export QML2_IMPORT_PATH=$QML2_IMPORT_PATH:'"$(pwd)" >> ~/.bashrc
source ~/.bashrc

# Verify installation
qmlscene -I . examples/MinimalExample.qml
```

### Fedora 38

```bash
# Install dependencies
sudo dnf install qt6-qtbase-devel qt6-qtdeclarative-devel qt6-qttools-devel
sudo dnf install qt6-qtquickcontrols2 qt6-qtquicklayouts
sudo dnf install timewarrior git

# Clone and set up qs-timew
git clone https://github.com/dustin-s/qs-timew.git
cd qs-timew

# Set up QML import path
echo 'export QML2_IMPORT_PATH=$QML2_IMPORT_PATH:'"$(pwd)" >> ~/.bashrc
source ~/.bashrc

# Verify installation
qmlscene -I . examples/MinimalExample.qml
```

### Arch Linux

```bash
# Install dependencies
sudo pacman -S qt6-base qt6-declarative qt6-tools
sudo pacman -S qt6-quickcontrols2 qt6-quickcharts
sudo pacman -S timew git

# Clone and set up qs-timew
git clone https://github.com/dustin-s/qs-timew.git
cd qs-timew

# Set up QML import path
echo 'export QML2_IMPORT_PATH=$QML2_IMPORT_PATH:'"$(pwd)" >> ~/.bashrc
source ~/.bashrc

# Verify installation
qmlscene -I . examples/MinimalExample.qml
```

## Development Setup

### Setting Up Development Environment

```bash
# Clone the repository
git clone https://github.com/dustin-s/qs-timew.git
cd qs-timew

# Create development branch
git checkout -b develop

# Set up pre-commit hooks (if available)
cp scripts/pre-commit .git/hooks/
chmod +x .git/hooks/pre-commit

# Install development dependencies
sudo apt install qt6-tools-dev-tools  # For QML designer tools
```

### IDE Configuration

#### Qt Creator

1. Open Qt Creator
2. File → Open File or Project
3. Select the `qs-timew` directory
4. Configure as "Import Existing Project"
5. Set build directory to `build/`
6. Add QML import path: Project → Build & Run → QML → Import Paths → Add `$(PWD)`

#### Visual Studio Code

Install these extensions:
- QML
- Qt for Python
- GitLens

Create `.vscode/settings.json`:
```json
{
    "qml.formatter.style": "qml",
    "qml.importPaths": ["${workspaceFolder}"],
    "files.exclude": {
        "**/.git": true,
        "**/build": true
    }
}
```

### Running Tests

```bash
# Run all tests
qmltestrunner -input tests/TestRunner.qml

# Run specific test categories
qmltestrunner -input tests/unit/TimewarriorServiceTagEditTests.qml
qmltestrunner -input tests/integration/TagEditWorkflowTests.qml
qmltestrunner -input tests/performance/TagUpdatePerformanceTests.qml

# Run tests with coverage (if configured)
qmltestrunner -input tests/TestRunner.qml -coverage
```

## Integration Setup

### Method 1: QML Import Path

```bash
# Add to system-wide QML import path
sudo ln -s /path/to/qs-timew /usr/lib/qt6/qml/qs_timew

# Or add to user QML import path
export QML2_IMPORT_PATH=$QML2_IMPORT_PATH:/path/to/qs-timew
```

### Method 2: Relative Path

```qml
// In your application QML
import "file:///path/to/qs-timew" as QsTimew

// Use the module
QsTimew.TimewarriorWidget {
    anchors.fill: parent
}
```

### Method 3: Copy to Project

```bash
# Copy module to your project
cp -r /path/to/qs-timew/src ./qs-timew

# Use in your QML
import "./qs-timew"
```

### Method 4: Submodule

```bash
# Add as git submodule
git submodule add https://github.com/dustin-s/qs-timew.git qs-timew

# Initialize submodule
git submodule update --init --recursive

# Use in your QML
import "./qs-timew"
```

## Verification

### Basic Installation Test

```bash
# Test basic QML loading
qmlscene -I . examples/MinimalExample.qml

# Expected: A window with a basic timewarrior widget
```

### Comprehensive Test

```bash
# Run the complete test suite
qmltestrunner -input tests/TestRunner.qml

# Expected: All tests pass with detailed output
```

### Manual Verification

```bash
# Create test file
cat > test.qml << 'EOF'
import QtQuick
import QtQuick.Controls
import qs_timew 2.0

ApplicationWindow {
    visible: true
    width: 400
    height: 300
    title: "qs-timew Test"

    IntegrationComponent {
        id: timew

        onTimerStarted: console.log("Timer started:", tags)
        onTimerStopped: console.log("Timer stopped")
        onError: console.error("Error:", message)
    }

    Column {
        anchors.centerIn: parent
        spacing: 10

        Text {
            text: "Timewarrior Available: " + (timew.timewAvailable ? "Yes" : "No")
        }

        Text {
            text: "Timer Active: " + (timew.timerActive ? "Yes" : "No")
        }

        Text {
            text: "Current Tags: " + timew.currentTags.join(" ")
        }

        Button {
            text: "Test Timer"
            onClicked: {
                if (timew.timerActive) {
                    timew.stopTimer()
                } else {
                    timew.startTimer(["test", "qs-timew"])
                }
            }
        }
    }
}
EOF

# Run test
qmlscene test.qml

# Expected: Interactive window with working timer controls
```

### Integration Test

```bash
# Test with your own application
qmlscene -I . /path/to/your/app.qml

# Verify:
# 1. Module imports successfully
# 2. Widget displays correctly
# 3. Timer functionality works
# 4. No error messages in console
```

## Installation Troubleshooting

### Common Issues

#### Issue: "module qs_timew is not installed"

**Symptoms:**
```
file:///path/to/app.qml:5:1: module "qs_timew" is not installed
```

**Solutions:**

1. **Check QML Import Path**
   ```bash
   echo $QML2_IMPORT_PATH
   # Should include your qs-timew directory
   ```

2. **Set Import Path Manually**
   ```bash
   export QML2_IMPORT_PATH=$QML2_IMPORT_PATH:/path/to/qs-timew
   ```

3. **Use Command Line Import**
   ```bash
   qmlscene -I /path/to/qs-timew app.qml
   ```

#### Issue: "timewarrior not found"

**Symptoms:**
```
Timewarrior not found
Error: Timewarrior binary not found
```

**Solutions:**

1. **Install timewarrior**
   ```bash
   sudo apt install timewarrior  # Ubuntu/Debian
   sudo dnf install timewarrior  # Fedora/CentOS
   sudo pacman -S timew          # Arch Linux
   ```

2. **Check PATH**
   ```bash
   which timew
   # Should return path to timew binary
   ```

3. **Manual Installation**
   ```bash
   # Build from source if package not available
   git clone https://github.com/GothenburgBitFactory/timewarrior.git
   cd timewarrior && cmake . && make && sudo make install
   ```

#### Issue: Qt version mismatch

**Symptoms:**
```
Unable to load library libQt6Qml.so.6
Cannot find Qt6
```

**Solutions:**

1. **Check Qt Version**
   ```bash
   qmake --version
   # Should show Qt 6.x
   ```

2. **Install Correct Qt Version**
   ```bash
   sudo apt install qt6-base-dev qt6-declarative-dev
   ```

3. **Update Environment**
   ```bash
   export QT_SELECT=qt6
   export PATH=/usr/lib/qt6/bin:$PATH
   ```

#### Issue: Permission denied

**Symptoms:**
```
Permission denied
Could not start process
```

**Solutions:**

1. **Check File Permissions**
   ```bash
   ls -la /path/to/qs-timew
   # Should have read permissions for your user
   ```

2. **Fix Permissions**
   ```bash
   chmod -R 755 /path/to/qs-timew
   ```

3. **Check Directory Ownership**
   ```bash
   sudo chown -R $USER:$USER /path/to/qs-timew
   ```

#### Issue: Widget not displaying

**Symptoms:**
```
Widget appears blank or doesn't render
```

**Solutions:**

1. **Check Qt Quick Controls**
   ```bash
   sudo apt install qml6-module-qtquick-controls
   ```

2. **Verify Material Theme**
   ```qml
   import QtQuick.Controls.Material

   ApplicationWindow {
       Material.theme: Material.System
       // Your content here
   }
   ```

3. **Check Console for Errors**
   ```bash
   qmlscene -I . app.qml 2>&1 | grep -i error
   ```

### Debug Mode

Enable debug mode to troubleshoot issues:

```bash
# Enable debug logging
export QT_LOGGING_RULES="qs_timew.debug=true"

# Run with verbose output
qmlscene -I . app.qml -v

# Check module loading
export QML_DEBUG_IMPORTS=1
qmlscene -I . app.qml
```

### Performance Issues

If you experience performance problems:

1. **Check System Resources**
   ```bash
   top -p $(pgrep qmlscene)
   # Monitor CPU and memory usage
   ```

2. **Optimize QML Import Path**
   ```bash
   # Use absolute path for better performance
   export QML2_IMPORT_PATH=/absolute/path/to/qs-timew
   ```

3. **Disable Debug Features**
   ```bash
   unset QT_LOGGING_RULES
   qmlscene -I . app.qml
   ```

### Getting Help

If you continue to experience issues:

1. **Check the Logs**
   ```bash
   # Run with debug output
   qmlscene -I . app.qml 2>&1 > debug.log
   cat debug.log
   ```

2. **Verify Dependencies**
   ```bash
   # Check all required packages
   dpkg -l | grep -E "(qt6|timewarrior)"
   ```

3. **Create Minimal Test Case**
   ```qml
   import QtQuick
   import qs_timew 2.0

   Rectangle {
       width: 100
       height: 50
       TimewarriorWidget {
           anchors.fill: parent
       }
   }
   ```

4. **Report Issues**
   - [GitHub Issues](https://github.com/dustin-s/qs-timew/issues)
   - Include system information, error messages, and test cases

### Next Steps

After successful installation:

1. Read the [Usage Examples](usage-examples.md)
2. Follow the [Integration Guide](integration-guide.md)
3. Run the [Test Suite](testing.md) to verify functionality
4. Check the [API Reference](api-reference.md) for detailed documentation

For additional help or questions, refer to the [Troubleshooting Guide](troubleshooting.md) or open an issue on GitHub.