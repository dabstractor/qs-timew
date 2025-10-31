# Troubleshooting Guide

Comprehensive guide to diagnosing and resolving common issues with the qs-timew module.

## Table of Contents

- [Troubleshooting Overview](#troubleshooting-overview)
- [Common Issues](#common-issues)
- [Diagnostic Tools](#diagnostic-tools)
- [Error Messages](#error-messages)
- [Performance Issues](#performance-issues)
- [Integration Problems](#integration-problems)
- [Platform-Specific Issues](#platform-specific-issues)
- [Debugging Techniques](#debugging-techniques)
- [Getting Help](#getting-help)

## Troubleshooting Overview

### Systematic Approach

Follow this systematic approach to troubleshooting:

1. **Identify the Problem**: Clearly define what's not working
2. **Gather Information**: Collect logs, error messages, and system state
3. **Isolate the Issue**: Determine if it's qs-timew, Qt, or system-related
4. **Check Dependencies**: Verify all prerequisites are installed and working
5. **Test Components**: Test individual components separately
6. **Apply Solutions**: Try targeted fixes based on diagnosis
7. **Verify Resolution**: Confirm the issue is fully resolved

### Information to Collect

When reporting issues, collect this information:

- **System Information**: OS, Qt version, architecture
- **qs-timew Version**: Module version and commit hash
- **Installation Method**: How qs-timew was installed
- **Error Messages**: Complete error text and stack traces
- **Reproduction Steps**: Exact steps to reproduce the issue
- **Expected Behavior**: What should happen
- **Actual Behavior**: What actually happens
- **Configuration**: Any custom settings or modifications

## Common Issues

### Issue 1: Module Import Error

**Symptoms:**
```
module "qs_timew" is not installed
file:///path/to/app.qml:5:1: module "qs_timew" is not installed
```

**Diagnosis:**
- QML import path doesn't include qs-timew directory
- Module files are missing or corrupted
- Incorrect import statement

**Solutions:**

1. **Check Import Path:**
```bash
echo $QML2_IMPORT_PATH
# Should include path to qs-timew
```

2. **Set Import Path:**
```bash
# Temporary
export QML2_IMPORT_PATH=$QML2_IMPORT_PATH:/path/to/qs-timew

# Permanent (add to ~/.bashrc)
echo 'export QML2_IMPORT_PATH=$QML2_IMPORT_PATH:/path/to/qs-timew' >> ~/.bashrc
```

3. **Use Command Line Option:**
```bash
qmlscene -I /path/to/qs-timew app.qml
```

4. **Verify Module Files:**
```bash
ls -la /path/to/qs-timew/src/
# Should contain qmldir and QML files
```

5. **Check Import Statement:**
```qml
// Correct
import qs_timew 2.0

// Incorrect
import qs_timew
import qs-timew 2.0
import QsTimew 2.0
```

### Issue 2: Timewarrior Not Found

**Symptoms:**
```
Timewarrior not found
Error: Timewarrior binary not found
```

**Diagnosis:**
- timewarrior is not installed
- timewarrior is not in PATH
- timewarrior binary is not executable

**Solutions:**

1. **Install timewarrior:**
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install timewarrior

# Fedora/CentOS
sudo dnf install timewarrior

# Arch Linux
sudo pacman -S timew

# From source
git clone https://github.com/GothenburgBitFactory/timewarrior.git
cd timewarrior
cmake .
make
sudo make install
```

2. **Check Installation:**
```bash
which timew
timew --version
```

3. **Verify PATH:**
```bash
echo $PATH | tr ':' '\n' | grep timew
```

4. **Manual Installation:**
```bash
# If timew is installed but not found
sudo ln -s /usr/local/bin/timew /usr/bin/timew
```

### Issue 3: Timer Not Starting

**Symptoms:**
- Clicking start button doesn't start timer
- No error message displayed
- Timer remains in inactive state

**Diagnosis:**
- Invalid tag input
- timewarrior command failing
- Permission issues
- Network/filesystem problems

**Solutions:**

1. **Check Tag Input:**
```qml
// Test with simple tags
timew.startTimer(["test"])

// Check validation
const validation = timew.validateTagInput("your tags here")
console.log("Validation result:", validation)
```

2. **Test timewarrior Manually:**
```bash
# Test timewarrior directly
timew start test
timew export
timew stop
```

3. **Check Permissions:**
```bash
# Check timewarrior data directory permissions
ls -la ~/.timewarrior/
# Should be readable and writable by your user
```

4. **Enable Debug Logging:**
```qml
// Enable verbose logging
IntegrationComponent {
    id: timew

    onError: function(message) {
        console.error("Integration error:", message)
        console.trace() // Show stack trace
    }
}
```

### Issue 4: Widget Not Displaying

**Symptoms:**
- Widget appears blank or invisible
- Only shows background color
- No text or controls visible

**Diagnosis:**
- Qt Quick Controls not available
- Theme issues
- Component loading failure
- Size/layout problems

**Solutions:**

1. **Check Qt Quick Controls:**
```bash
# Ubuntu/Debian
sudo apt install qml6-module-qtquick-controls

# Verify installation
qmlscene -test -import QtQuick.Controls
```

2. **Check Theme Support:**
```qml
ApplicationWindow {
    Material.theme: Material.System
    Material.accent: Material.Blue

    // Your widget here
}
```

3. **Verify Component Loading:**
```qml
Loader {
    sourceComponent: TimewarriorWidget {}
    onStatusChanged: {
        if (status === Loader.Error) {
            console.log("Load error:", sourceComponent.errorString())
        }
    }
}
```

4. **Check Size:**
```qml
TimewarriorWidget {
    anchors.fill: parent
    anchors.margins: 10

    // Explicit size for testing
    width: 200
    height: 40
}
```

### Issue 5: Performance Issues

**Symptoms:**
- UI lag or stuttering
- High CPU usage
- Memory leaks
- Slow response times

**Diagnosis:**
- Inefficient tag parsing
- Excessive state polling
- Memory leaks
- Blocking operations

**Solutions:**

1. **Monitor Performance:**
```qml
// Add performance monitoring
Timer {
    interval: 5000
    repeat: true
    onTriggered: {
        console.log("Memory usage:", getMemoryUsage(), "MB")
        console.log("Timer active:", timew.timerActive)
        console.log("Tag count:", timew.currentTags.length)
    }
}
```

2. **Optimize Tag Input:**
```qml
// Use debounced input for large tag lists
Timer {
    id: inputDebounce
    interval: 300
    onTriggered: processTags()
}

TextField {
    onTextChanged: inputDebounce.restart()
}
```

3. **Reduce Polling Frequency:**
```qml
// Reduce state polling if not needed
property bool highPerformanceMode: false

Timer {
    interval: highPerformanceMode ? 5000 : 2000
    running: true
    repeat: true
    onTriggered: refreshState()
}
```

### Issue 6: Tag Editing Not Working

**Symptoms:**
- Can't modify tags on active timer
- Tag changes don't persist
- Validation errors

**Diagnosis:**
- No active timer
- Invalid timer ID
- Tag validation failures
- Permission issues

**Solutions:**

1. **Check Active Timer:**
```qml
// Verify timer is active before editing tags
if (!timew.timerActive) {
    console.error("No active timer to edit")
    return
}
```

2. **Check Timer ID:**
```qml
const timerId = timew.getCurrentTimerId()
console.log("Current timer ID:", timerId)

if (!timerId) {
    console.error("No valid timer ID")
    return
}
```

3. **Validate Tags:**
```qml
const validation = timew.validateTagInput(newTags)
if (!validation.isValid) {
    console.error("Invalid tags:", validation.errors)
    return
}

timew.updateTags(validation.tags)
```

## Diagnostic Tools

### System Information Script

```bash
#!/bin/bash
# scripts/diagnose.sh

echo "=== qs-timew Diagnostic Information ==="
echo

echo "System Information:"
echo "OS: $(uname -s -r)"
echo "Architecture: $(uname -m)"
echo "Qt Version: $(qmlscene --version 2>/dev/null | head -1 || echo 'Not found')"
echo

echo "qs-timew Information:"
if [ -d "./src" ]; then
    echo "qs-timew directory: $(pwd)"
    echo "Module files:"
    ls -la src/
else
    echo "qs-timew not found in current directory"
fi
echo

echo "Timewarrior Information:"
if command -v timew &> /dev/null; then
    echo "Timewarrior installed: $(which timew)"
    echo "Version: $(timew --version)"
    echo "Data directory: $(timew show | grep "Database" | cut -d' ' -f3)"
else
    echo "Timewarrior not found"
fi
echo

echo "Environment Variables:"
echo "QML2_IMPORT_PATH: $QML2_IMPORT_PATH"
echo "PATH: $PATH"
echo

echo "Memory Usage:"
free -h
echo

echo "Disk Usage:"
df -h | grep -E "/$|/home"
echo

echo "Running Processes:"
ps aux | grep -E "qml|timew" | grep -v grep
```

### QML Diagnostic Component

```qml
// DiagnosticTool.qml
import QtQuick
import QtQuick.Controls
import qs_timew 2.0

ApplicationWindow {
    visible: true
    width: 600
    height: 700
    title: "qs-timew Diagnostics"

    IntegrationComponent {
        id: timew

        onError: function(message) {
            diagnosticLog.append("ERROR: " + message)
        }
    }

    ScrollView {
        anchors.fill: parent
        anchors.margins: 10

        Column {
            width: parent.width
            spacing: 10

            GroupBox {
                title: "System Information"
                width: parent.width

                Column {
                    spacing: 5

                    Text { text: "Qt Version: " + Qt.version }
                    Text { text: "QML Engine: Available" }
                    Text { text: "Platform: " + Qt.platform.os }
                }
            }

            GroupBox {
                title: "qs-timew Status"
                width: parent.width

                Column {
                    spacing: 5

                    Text { text: "Timewarrior Available: " + (timew.timewAvailable ? "Yes" : "No") }
                    Text { text: "Timer Active: " + (timew.timerActive ? "Yes" : "No") }
                    Text { text: "Current Tags: " + timew.currentTags.join(", ") }
                    Text { text: "Elapsed Time: " + timew.elapsedTime }
                    Text { text: "Error Message: " + (timew.errorMessage || "None") }
                    Text { text: "Tag History Size: " + timew.tagHistory.length }
                    Text { text: "Week Tags: " + timew.weekTags.length }
                }
            }

            GroupBox {
                title: "Test Functions"
                width: parent.width

                Column {
                    spacing: 5

                    Button {
                        text: "Test Tag Validation"
                        onClicked: {
                            const test = timew.validateTagInput("test work project")
                            diagnosticLog.append("Tag validation test: " + JSON.stringify(test))
                        }
                    }

                    Button {
                        text: "Test Timer Start"
                        onClicked: {
                            const result = timew.startTimer(["diagnostic", "test"])
                            diagnosticLog.append("Timer start result: " + result)
                        }
                    }

                    Button {
                        text: "Test Timer Stop"
                        onClicked: {
                            const result = timew.stopTimer()
                            diagnosticLog.append("Timer stop result: " + result)
                        }
                    }

                    Button {
                        text: "Test Tag Update"
                        enabled: timew.timerActive
                        onClicked: {
                            const result = timew.updateTags(["updated", "diagnostic"])
                            diagnosticLog.append("Tag update result: " + result)
                        }
                    }

                    Button {
                        text: "Clear Log"
                        onClicked: diagnosticLog.clear()
                    }
                }
            }

            GroupBox {
                title: "Diagnostic Log"
                width: parent.width
                height: 200

                ScrollView {
                    anchors.fill: parent

                    TextArea {
                        id: diagnosticLog
                        text: "Diagnostic log will appear here..."
                        readOnly: true
                        font.family: "monospace"
                        font.pixelSize: 10
                    }
                }
            }
        }
    }
}
```

## Error Messages

### Timewarrior Service Errors

| Error Message | Cause | Solution |
|---------------|-------|----------|
| "Timewarrior not found" | timewarrior binary not in PATH | Install timewarrior or update PATH |
| "No active timer to modify" | Trying to edit tags without active timer | Start a timer first |
| "Invalid timer ID" | Timer ID is empty or invalid | Check timer state before editing |
| "No valid tags found" | Tag input is empty or invalid | Provide valid tag input |
| "Contains potentially dangerous characters" | Tags contain shell injection characters | Remove special characters like `;&|$(){}[]` |

### Component Loading Errors

| Error Message | Cause | Solution |
|---------------|-------|----------|
| "module qs_timew is not installed" | QML import path issue | Set QML2_IMPORT_PATH or use -I option |
| "Cannot load component" | Component file missing or corrupted | Verify installation and file integrity |
| "Component is not created" | Component creation failed | Check import statements and dependencies |

### Runtime Errors

| Error Message | Cause | Solution |
|---------------|-------|----------|
| "Timer operation failed" | timewarrior command failed | Check timewarrior logs and permissions |
| "Tag validation failed" | Invalid tag format | Use valid tag format (no spaces, special chars) |
| "State update failed" | State polling error | Check timewarrior accessibility and network |

## Performance Issues

### High Memory Usage

**Symptoms:**
- Memory usage continuously grows
- Application becomes slow over time
- System warnings about low memory

**Diagnosis:**
```qml
// Monitor memory usage
Timer {
    interval: 10000
    repeat: true
    onTriggered: {
        const usage = getMemoryUsage()
        console.log("Memory usage:", usage, "MB")

        if (usage > 50) { // 50MB threshold
            console.warn("High memory usage detected!")
        }
    }
}
```

**Solutions:**
1. Clear tag history periodically
2. Restart application periodically
3. Check for memory leaks in custom code
4. Optimize tag parsing algorithms

### Slow UI Response

**Symptoms:**
- UI lag or stuttering
- Delayed button responses
- Slow animations

**Diagnosis:**
```qml
// Monitor frame rate
Timer {
    interval: 1000
    repeat: true
    property var frameCount: 0
    property var lastTime: new Date()

    onTriggered: {
        const now = new Date()
        const fps = frameCount * 1000 / (now - lastTime)
        console.log("FPS:", fps.toFixed(1))

        frameCount = 0
        lastTime = now
    }
}

// Count frames (add to main loop)
onFrameSwapped: frameCount++
```

**Solutions:**
1. Reduce state polling frequency
2. Optimize tag parsing performance
3. Use lazy loading for components
4. Enable hardware acceleration

### High CPU Usage

**Symptoms:**
- CPU usage > 10% during normal operation
- System fan running constantly
- Battery drain on laptops

**Diagnosis:**
```qml
// Profile CPU usage
Timer {
    interval: 2000
    repeat: true
    onTriggered: {
        const cpu = getCpuUsage()
        console.log("CPU usage:", cpu.toFixed(1), "%")

        if (cpu > 10) {
            console.warn("High CPU usage detected!")
            // Log current state
            console.log("Timer active:", timew.timerActive)
            console.log("Tag count:", timew.currentTags.length)
        }
    }
}
```

**Solutions:**
1. Reduce polling frequency
2. Optimize tag parsing algorithms
3. Use background processing
4. Implement operation debouncing

## Integration Problems

### Import Path Issues

**Problem:** qs-timew module not found despite installation

**Solutions:**
```bash
# Method 1: Set environment variable
export QML2_IMPORT_PATH=$QML2_IMPORT_PATH:/path/to/qs-timew

# Method 2: Use command line option
qmlscene -I /path/to/qs-timew app.qml

# Method 3: System-wide installation
sudo ln -s /path/to/qs-timew/src /usr/lib/qt6/qml/qs_timew
```

### Version Compatibility

**Problem:** qs-timew incompatible with Qt version

**Diagnosis:**
```bash
# Check Qt version
qmlscene --version

# Check required version
cat package.json | grep "qt"
```

**Solutions:**
1. Upgrade Qt to version 6.0+
2. Use compatible qs-timew version
3. Rebuild module for target Qt version

### Theme Integration

**Problem:** Widget doesn't match application theme

**Solutions:**
```qml
ApplicationWindow {
    Material.theme: Material.System
    Material.accent: Material.Blue

    // Custom theme properties
    property color primaryColor: "#1976D2"
    property color backgroundColor: "#FAFAFA"

    TimewarriorWidget {
        // Apply custom colors
        backgroundColor: parent.backgroundColor
        textColor: parent.Material.foreground
        accentColor: parent.accentColor
    }
}
```

## Platform-Specific Issues

### Linux Issues

#### Wayland Compatibility

**Problem:** Widgets don't display properly on Wayland

**Solutions:**
```qml
ApplicationWindow {
    // Wayland-specific settings
    visibility: Window.FullScreen
    flags: Qt.FramelessWindowHint

    // Use standard Qt components instead of Wayland-specific ones
}
```

#### Permission Issues

**Problem:** Can't execute timewarrior commands

**Solutions:**
```bash
# Check permissions
ls -la $(which timew)

# Fix permissions if needed
sudo chmod +x $(which timew)

# Check data directory permissions
ls -la ~/.timewarrior/
chmod -R u+rw ~/.timewarrior/
```

### Windows Issues

#### Path Separator Issues

**Problem:** File paths use wrong separators

**Solutions:**
```qml
// Use Qt.path for cross-platform compatibility
function getModulePath() {
    return Qt.path("file:///C:/path/to/qs-timew")
}
```

#### Service Installation

**Problem:** Services don't work on Windows

**Solutions:**
```qml
// Windows-specific service handling
property bool isWindows: Qt.platform.os === "windows"

Timer {
    interval: isWindows ? 5000 : 2000
    running: true
    repeat: true
}
```

### macOS Issues

#### Security Restrictions

**Problem:** macOS security blocks timewarrior execution

**Solutions:**
```bash
# Grant permissions to timewarrior
xattr -d com.apple.quarantine $(which timew)

# Or add to security preferences
# System Preferences → Security & Privacy → Privacy
```

#### Bundle Integration

**Problem:** Module not found in app bundles

**Solutions:**
```qml
// Use resource paths for bundles
property string modulePath: Qt.resolvedUrl("qrc:/qs-timew")
```

## Debugging Techniques

### Enable Debug Logging

```qml
// Enable comprehensive logging
import QtQuick

ApplicationWindow {
    Component.onCompleted: {
        console.log("=== qs-timew Debug Session ===")
        console.log("Qt Version:", Qt.version)
        console.log("Platform:", Qt.platform.os)
        console.log("QML Import Path:", QmlEngine.importPathList.join(":"))
    }

    IntegrationComponent {
        id: timew

        onTimerStarted: function(tags) {
            console.log("[TIMER] Started:", tags.join(", "))
        }

        onTimerStopped: {
            console.log("[TIMER] Stopped")
        }

        onTagsUpdated: function(oldTags, newTags) {
            console.log("[TAGS] Updated:", oldTags.join(", "), "→", newTags.join(", "))
        }

        onError: function(message) {
            console.error("[ERROR]", message)
            console.trace() // Show stack trace
        }
    }
}
```

### Test Individual Components

```qml
// Component test harness
ApplicationWindow {
    visible: true
    width: 400
    height: 300

    // Test service directly
    property var service: TimewarriorService

    Column {
        anchors.centerIn: parent
        spacing: 10

        Text {
            text: "Service Available: " + service.timewAvailable
        }

        Text {
            text: "Timer Active: " + service.timerActive
        }

        Button {
            text: "Test Service"
            onClicked: {
                console.log("Testing service...")
                console.log("Current tags:", service.currentTags)
                console.log("Elapsed time:", service.elapsedSeconds)
            }
        }
    }
}
```

### Network Debugging

```bash
# Monitor timewarrior network activity
strace -e trace=network timew export 2>&1 | grep -E "(connect|send|recv)"

# Check timewarrior logs
timew export
timew log
```

### Performance Profiling

```qml
// Performance profiler
Item {
    id: profiler

    property var operations: []

    function startOperation(name) {
        operations.push({
            name: name,
            startTime: performance.now()
        })
    }

    function endOperation(name) {
        const index = operations.findIndex(op => op.name === name)
        if (index >= 0) {
            const operation = operations[index]
            operation.endTime = performance.now()
            operation.duration = operation.endTime - operation.startTime

            console.log(`[PERF] ${name}: ${operation.duration.toFixed(2)}ms`)

            operations.splice(index, 1)
        }
    }

    function measureFunction(name, func) {
        startOperation(name)
        try {
            const result = func()
            endOperation(name)
            return result
        } catch (error) {
            endOperation(name)
            console.error(`[PERF] ${name} failed:`, error)
            throw error
        }
    }
}
```

## Getting Help

### Creating Effective Bug Reports

When reporting issues, include:

1. **Environment Information:**
   ```bash
   uname -a
   qmlscene --version
   timew --version
   ```

2. **qs-timew Information:**
   ```bash
   git log -1 --oneline
   git status
   ```

3. **Minimal Reproducible Example:**
   ```qml
   import QtQuick
   import qs_timew 2.0

   ApplicationWindow {
       TimewarriorWidget {
           anchors.fill: parent
       }
   }
   ```

4. **Complete Error Output:**
   ```
   Copy and paste full error messages
   ```

5. **Steps to Reproduce:**
   ```
   1. Start application
   2. Click "Start Timer"
   3. Enter tags: "test bug"
   4. Click "Start"
   5. Observe error
   ```

### Community Resources

- **GitHub Issues:** [Report bugs and request features](https://github.com/dustin-s/qs-timew/issues)
- **GitHub Discussions:** [Ask questions and share experiences](https://github.com/dustin-s/qs-timew/discussions)
- **Documentation:** [Complete documentation](https://github.com/dustin-s/qs-timew/blob/main/docs/README.md)
- **Timewarrior Docs:** [Official timewarrior documentation](https://timewarrior.net/docs/)

### Professional Support

For commercial support or custom development:

- **Consulting:** Integration assistance and customization
- **Training:** Team training on qs-timew usage and development
- **Support Packages:** Priority support and maintenance contracts

This troubleshooting guide provides comprehensive information for diagnosing and resolving common issues with the qs-timew module. For additional help or questions not covered here, please use the community resources or create a bug report with the required information.