# Installation Guide

## Quick Installation

### Option 1: Simple Import Path (Recommended)

1. Clone the repository:
   ```bash
   git clone https://github.com/dustin-s/qs-timew.git
   cd qs-timew
   ```

2. Add to QML import path:
   ```bash
   export QML2_IMPORT_PATH=$QML2_IMPORT_PATH:/path/to/qs-timew
   ```

3. Use in your QML application:
   ```qml
   import qs_timew 2.0
   ```

### Option 2: System Installation

1. Create installation directory:
   ```bash
   sudo mkdir -p /usr/lib/qml/qs_timew
   ```

2. Copy module files:
   ```bash
   sudo cp src/*.qml /usr/lib/qml/qs_timew/
   sudo cp qmldir /usr/lib/qml/qs_timew/
   ```

### Option 3: User Installation

1. Create user QML directory:
   ```bash
   mkdir -p ~/.local/lib/qml/qs_timew
   ```

2. Copy module files:
   ```bash
   cp src/*.qml ~/.local/lib/qml/qs_timew/
   cp qmldir ~/.local/lib/qml/qs_timew/
   ```

## Dependencies

- Qt 6.0+ with QML support
- timewarrior command-line tool

### Install timewarrior

**Ubuntu/Debian:**
```bash
sudo apt install timewarrior
```

**Arch Linux:**
```bash
sudo pacman -S timewarrior
```

**From source:**
```bash
git clone https://github.com/GothenburgBitFactory/timewarrior.git
cd timewarrior
sudo make install
```

## Verification

1. Test module import:
   ```bash
   qmlscene -I . examples/MinimalExample.qml
   ```

2. Test with QuickShell:
   ```bash
   cp -r examples/QuickshellIntegration.qml ~/.config/quickshell/
   ```

## Usage Examples

### Basic Widget
```qml
import QtQuick 2.15
import qs_timew 2.0

ApplicationWindow {
    visible: true
    width: 200
    height: 40

    TimewarriorWidget {
        anchors.fill: parent
    }
}
```

### Integration Component
```qml
import QtQuick 2.15
import qs_timew 2.0

ApplicationWindow {
    visible: true

    IntegrationComponent {
        id: integration

        onStartTimer: console.log("Timer started with tags:", tags)
        onStopTimer: console.log("Timer stopped")
        onTagsUpdated: console.log("Tags changed:", oldTags, "->", newTags)
    }
}
```

## Troubleshooting

### Module not found
```bash
export QML2_IMPORT_PATH=/path/to/qs-timew:$QML2_IMPORT_PATH
```

### Timewarrior not working
```bash
timew --version
timew export
```

### QuickShell integration
Add to your QuickShell config:
```qml
import qs_timew 2.0

// In your bar or panel
TimewarriorWidget {
    enableGlobalShortcuts: true
    enableIpcHandler: true
}
```

## IPC Commands

Once integrated, you can use these commands:

```bash
# Toggle timer
qs ipc call timewarrior startOrStop

# Start timer with tags
qs ipc call timewarrior startTimer "work project"

# Edit current timer tags
qs ipc call timewarrior editTags "new tags"
```

## Performance Notes

- Timer polling: 2-second intervals
- Tag history: Limited to 100 entries
- Memory usage: ~2MB base + data

## Support

- **Documentation**: See `docs/` directory
- **Issues**: https://github.com/dustin-s/qs-timew/issues
- **Examples**: `examples/` directory
- **Timewarrior**: https://timewarrior.net/docs/