# Migration Guide

Guide for migrating timewarrior functionality from QuickShell to the standalone qs-timew module.

## Table of Contents

- [Migration Overview](#migration-overview)
- [Pre-Migration Checklist](#pre-migration-checklist)
- [Migration Scenarios](#migration-scenarios)
- [Step-by-Step Migration](#step-by-step-migration)
- [Code Changes](#code-changes)
- [Configuration Migration](#configuration-migration)
- [Testing Migration](#testing-migration)
- [Common Migration Issues](#common-migration-issues)
- [Rollback Procedure](#rollback-procedure)

## Migration Overview

### What Changes

When migrating from QuickShell's built-in timewarrior integration to qs-timew:

1. **Import statements** change from QuickShell services to qs-timew module
2. **Component structure** is slightly different but compatible
3. **Dependencies** are reduced (no QuickShell dependency)
4. **Deployment** becomes more flexible
5. **API** remains largely the same with minor improvements

### What Stays the Same

- Core timewarrior functionality
- Widget appearance and behavior
- Timer management features
- Tag editing capabilities
- Signal/slot interface
- Configuration options

### Benefits of Migration

- **Standalone deployment** - Use with any Qt Quick application
- **Reduced dependencies** - No QuickShell requirement
- **Better testing** - Isolated test suite
- **Easier updates** - Independent module updates
- **Broader compatibility** - Works with different Qt versions

## Pre-Migration Checklist

### Environment Preparation

```bash
# 1. Backup current QuickShell configuration
cp -r ~/.config/quickshell ~/.config/quickshell.backup.$(date +%Y%m%d)

# 2. Verify timewarrior installation
timew --version

# 3. Check current QuickShell timewarrior usage
grep -r "TimewarriorService\|TimewarriorWidget" ~/.config/quickshell/
```

### Dependencies Check

```bash
# Verify Qt 6 availability
qmlscene --version

# Check for required Qt modules
qmlscene -I . -test -import QtQuick
qmlscene -I . -test -import QtQuick.Controls
qmlscene -I . -test -import QtQuick.Controls.Material
```

### Current Usage Analysis

Identify all timewarrior usage in your QuickShell config:

```bash
# Find all timewarrior-related files
find ~/.config/quickshell -name "*timew*" -o -name "*Timewarrior*"

# Search for timewarrior imports
grep -r "TimewarriorService\|TimewarriorWidget" ~/.config/quickshell/

# Check for custom timewarrior configurations
grep -r "timewarrior" ~/.config/quickshell/ --include="*.qml"
```

## Migration Scenarios

### Scenario 1: Simple Widget Usage

**QuickShell Code:**
```qml
import Quickshell
import Quickshell.Io
import qs.services

Rectangle {
    TimewarriorWidget {
        anchors.fill: parent
    }
}
```

**qs-timew Code:**
```qml
import QtQuick
import qs_timew 2.0

Rectangle {
    TimewarriorWidget {
        anchors.fill: parent
    }
}
```

### Scenario 2: Service Integration

**QuickShell Code:**
```qml
import Quickshell
import Quickshell.Io
import qs.services

Item {
    property var service: TimewarriorService

    Button {
        text: "Start Timer"
        onClicked: service.startTimer(["work"])
    }
}
```

**qs-timew Code:**
```qml
import QtQuick
import qs_timew 2.0

Item {
    property var service: TimewarriorService

    Button {
        text: "Start Timer"
        onClicked: service.startTimer(["work"])
    }
}
```

### Scenario 3: Advanced Integration

**QuickShell Code:**
```qml
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.services

PanelWindow {
    TimewarriorWidget {
        anchors.fill: parent
        enableGlobalShortcuts: true
        enableIpcHandler: true
    }
}
```

**qs-timew Code:**
```qml
import QtQuick
import QtQuick.Window
import qs_timew 2.0

ApplicationWindow {
    TimewarriorWidget {
        anchors.fill: parent
        enableGlobalShortcuts: true
        enableIpcHandler: true
    }
}
```

## Step-by-Step Migration

### Step 1: Install qs-timew

```bash
# Clone qs-timew
git clone https://github.com/dustin-s/qs-timew.git
cd qs-timew

# Verify installation
qmlscene -I . examples/MinimalExample.qml
```

### Step 2: Update Import Statements

Replace QuickShell service imports with qs-timew module imports:

**Before:**
```qml
import Quickshell
import Quickshell.Io
import qs.services
```

**After:**
```qml
import QtQuick
import qs_timew 2.0
```

### Step 3: Update Component References

Component names remain the same, but access patterns may change:

**Before:**
```qml
// Direct service access
property var timerService: TimewarriorService
```

**After:**
```qml
// Direct service access (same)
property var timerService: TimewarriorService

// Or use high-level API
IntegrationComponent {
    id: timew
    property var timerService: timew.service
}
```

### Step 4: Update Window/Panel Types

Replace QuickShell-specific window types with Qt Quick equivalents:

**Before:**
```qml
PanelWindow {
    // QuickShell panel configuration
    WlrLayershell.namespace: "quickshell:timewarrior"
}
```

**After:**
```qml
ApplicationWindow {
    // Standard Qt Quick window
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
}
```

### Step 5: Update Platform-Specific Code

Remove or replace QuickShell-specific integrations:

**Before:**
```qml
// QuickShell Hyprland integration
HyprlandFocusGrab {
    windows: [inputPopup]
    active: inputPopup.visible
}

// QuickShell Wayland integration
WlrLayershell.namespace: "quickshell:timewarrior"
```

**After:**
```qml
// Standard Qt Quick focus handling
Popup {
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
}

// Or use platform-specific plugins if needed
```

### Step 6: Update Global Shortcuts

Replace QuickShell global shortcuts with Qt shortcuts:

**Before:**
```qml
GlobalShortcut {
    name: "timewarriorStart"
    onPressed: TimewarriorService.startTimer(["work"])
}
```

**After:**
```qml
// Option 1: Use Qt shortcuts (application-wide)
Shortcut {
    sequence: "Ctrl+Shift+T"
    onActivated: timew.startTimer(["work"])
}

// Option 2: Use system shortcuts (if available)
// This may require additional platform-specific code
```

### Step 7: Update IPC Handling

Replace QuickShell IPC with Qt or custom IPC:

**Before:**
```qml
IpcHandler {
    target: "timewarrior"
    function startTimer() {
        TimewarriorService.startTimer(["work"])
    }
}
```

**After:**
```qml
// Option 1: Use widget's built-in IPC
TimewarriorWidget {
    enableIpcHandler: true
}

// Option 2: Implement custom IPC
// (platform-specific implementation required)
```

### Step 8: Test Integration

Verify the migration works correctly:

```bash
# Test basic functionality
qmlscene -I ../qs-timew migrated_config.qml

# Test with different scenarios
qmlscene -I ../qs-timew -test your_app.qml
```

## Code Changes

### Import Changes

| QuickShell Import | qs-timew Import |
|-------------------|-----------------|
| `import Quickshell` | `import QtQuick` |
| `import Quickshell.Io` | `import qs_timew 2.0` |
| `import Quickshell.Hyprland` | Remove or replace |
| `import Quickshell.Wayland` | Remove or replace |
| `import qs.services` | `import qs_timew 2.0` |

### Component Changes

Most component properties and methods remain the same:

```qml
// These remain unchanged:
TimewarriorService.timerActive
TimewarriorService.currentTags
TimewarriorService.startTimer(tags)
TimewarriorService.stopTimer()
TimewarriorService.modifyTimerTags(id, tags)

// New high-level API:
IntegrationComponent {
    id: timew
    // Simpler API with built-in error handling
    timew.startTimer(tags)
    timew.stopTimer()
    timew.updateTags(tags)
}
```

### Signal Connections

Signal handling remains the same:

```qml
// Before and after - same syntax
Connections {
    target: TimewarriorService
    function onTagsUpdated(oldTags, newTags) {
        console.log("Tags updated:", oldTags, "→", newTags)
    }
}
```

## Configuration Migration

### QuickShell Configuration

If you have custom timewarrior configuration in QuickShell:

```bash
# Extract custom configuration
grep -A 10 -B 10 "Timewarrior" ~/.config/quickshell/ii/config.qml

# Save custom settings
cat > custom_timew_config.json << EOF
{
    "shortcuts": {
        "startStop": "timewarriorStartOrStop",
        "openInput": "timewarriorOpenInput"
    },
    "theme": "dark",
    "position": {
        "x": "center",
        "y": "top"
    }
}
EOF
```

### qs-timew Configuration

Apply custom configuration to qs-timew:

```qml
IntegrationComponent {
    id: timew

    // Apply custom settings
    Timer {
        interval: 1000
        repeat: true
        running: timew.timerActive
        onTriggered: {
            // Custom behavior
        }
    }
}
```

## Testing Migration

### Functionality Tests

Test all timewarrior functionality:

```qml
// Test file: migration_test.qml
import QtQuick
import QtQuick.Controls
import qs_timew 2.0

ApplicationWindow {
    visible: true
    width: 400
    height: 300
    title: "Migration Test"

    IntegrationComponent {
        id: timew

        onTimerStarted: console.log("✓ Timer started:", tags)
        onTimerStopped: console.log("✓ Timer stopped")
        onError: console.log("✗ Error:", message)
    }

    Column {
        anchors.centerIn: parent
        spacing: 10

        Button {
            text: "Test Start Timer"
            onClicked: timew.startTimer(["test", "migration"])
        }

        Button {
            text: "Test Stop Timer"
            onClicked: timew.stopTimer()
        }

        Text {
            text: "Status: " + (timew.timerActive ? "Active" : "Inactive")
        }

        Text {
            text: "Tags: " + timew.currentTags.join(", ")
        }
    }
}
```

### Performance Tests

Verify performance is maintained:

```qml
// Performance monitoring
Timer {
    interval: 100
    repeat: true
    running: true

    property var startTime: new Date()

    onTriggered: {
        var elapsed = new Date() - startTime
        if (elapsed > 50) { // Alert if update takes > 50ms
            console.warn("Performance issue:", elapsed, "ms")
        }
        startTime = new Date()
    }
}
```

### Integration Tests

Test integration with existing UI:

```qml
// Test existing UI components
Rectangle {
    // Test widget placement
    TimewarriorWidget {
        anchors.centerIn: parent
        width: 180
        height: 32
    }

    // Test theme compatibility
    Material.theme: Material.Dark
    Material.accent: Material.Blue
}
```

## Common Migration Issues

### Issue 1: Module Import Errors

**Problem:**
```
module "qs_timew" is not installed
```

**Solution:**
```bash
# Set QML import path
export QML2_IMPORT_PATH=$QML2_IMPORT_PATH:/path/to/qs-timew

# Or use command line option
qmlscene -I /path/to/qs-timew your_app.qml
```

### Issue 2: Global Shortcuts Not Working

**Problem:**
Global shortcuts from QuickShell don't work in standalone application.

**Solution:**
```qml
// Use Qt shortcuts for application-wide shortcuts
Shortcut {
    sequence: "Ctrl+Shift+T"
    onActivated: timew.startTimer(["work"])
}

// For system-wide shortcuts, use platform-specific solutions
// Linux: Consider using dbus or system tray integration
```

### Issue 3: Window Type Incompatibility

**Problem:**
QuickShell PanelWindow doesn't exist in standard Qt Quick.

**Solution:**
```qml
// Replace PanelWindow with ApplicationWindow
ApplicationWindow {
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    // Custom panel behavior
    onWidthChanged: updatePosition()
    onHeightChanged: updatePosition()

    function updatePosition() {
        // Implement panel positioning logic
    }
}
```

### Issue 4: Hyprland/Wayland Integration Missing

**Problem:**
HyprlandFocusGrab and Wayland-specific features not available.

**Solution:**
```qml
// Use Qt's built-in focus management
Popup {
    focus: true
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    // Custom focus management if needed
    onOpened: forceActiveFocus()
}
```

### Issue 5: IPC Handler Not Available

**Problem:**
QuickShell's IpcHandler not available in standalone mode.

**Solution:**
```qml
// Option 1: Use widget's built-in IPC
TimewarriorWidget {
    enableIpcHandler: true
}

// Option 2: Implement custom IPC
// Example: DBus integration for Linux
```

### Issue 6: Theme Differences

**Problem:**
QuickShell theming system different from Qt Quick theming.

**Solution:**
```qml
// Apply Material Design theme
Material.theme: Material.System
Material.accent: Material.Blue

// Or customize colors manually
Rectangle {
    color: "#2b2b2b"  // Dark theme background
}
```

## Rollback Procedure

If migration fails, rollback to QuickShell:

### Quick Rollback

```bash
# Restore QuickShell configuration
cp -r ~/.config/quickshell.backup.$(date +%Y%m%d)/* ~/.config/quickshell/

# Restart QuickShell
pkill quickshell
quickshell
```

### Complete Rollback

```bash
# 1. Remove qs-timew integration files
rm -rf /path/to/qs-timew

# 2. Restore original files
git checkout HEAD -- ~/.config/quickshell/

# 3. Revert import statements
# (manual process - see reverse of code changes)

# 4. Test QuickShell integration
quickshell -test
```

### Partial Rollback

If specific features don't work:

```qml
// Use QuickShell for core functionality
import Quickshell
import qs.services

// But use qs-timew for specific features
// (hybrid approach - not recommended long-term)
```

## Migration Checklist

### Pre-Migration

- [ ] Backup current QuickShell configuration
- [ ] Document current timewarrior usage
- [ ] Verify timewarrior installation
- [ ] Test qs-timew standalone functionality
- [ ] Plan migration window (downtime acceptable)

### During Migration

- [ ] Update import statements
- [ ] Replace QuickShell-specific components
- [ ] Test basic functionality
- [ ] Test advanced features
- [ ] Verify performance
- [ ] Update documentation

### Post-Migration

- [ ] Run comprehensive tests
- [ ] Verify all shortcuts work
- [ ] Check theme compatibility
- [ ] Update user documentation
- [ ] Monitor for issues
- [ ] Remove backup (after successful testing)

### Validation

- [ ] Timer start/stop works
- [ ] Tag editing functions
- [ ] UI displays correctly
- [ ] Shortcuts work as expected
- [ ] Performance is acceptable
- [ ] No error messages in logs

This migration guide provides a comprehensive approach to moving from QuickShell's timewarrior integration to the standalone qs-timew module. Take your time with the migration and test thoroughly at each step to ensure a smooth transition.