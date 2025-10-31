import QtQuick
import qs

// Optional integration component for IPC and global shortcuts
QtObject {
    id: root

    property bool enableShortcuts: false
    property bool enableIpc: false
    property string shortcutToggle: "Ctrl+Shift+T"
    property string shortcutInput: "Ctrl+Shift+I"

    // IPC Handler (optional)
    property var ipcHandler: enableIpc ? ipcComponent.createObject(root) : null

    property Component ipcComponent: Component {
        IpcHandler {
            target: "timewarrior"

            function startOrStop() {
                TimewarriorService.toggle()
            }

            function openInput() {
                TimewarriorService.showInput()
            }

            function startTimer(tags) {
                if (tags && tags.length > 0) {
                    TimewarriorService.start(tags)
                }
            }

            function editTags(newTags) {
                if (newTags && newTags.length > 0) {
                    TimewarriorService.updateTags(newTags)
                }
            }
        }
    }

    // Global Shortcuts (optional)
    property var toggleShortcut: enableShortcuts ? toggleShortcutComponent.createObject(root) : null
    property var inputShortcut: enableShortcuts ? inputShortcutComponent.createObject(root) : null

    property Component toggleShortcutComponent: Component {
        GlobalShortcut {
            sequence: shortcutToggle
            onActivated: TimewarriorService.toggle()
        }
    }

    property Component inputShortcutComponent: Component {
        GlobalShortcut {
            sequence: shortcutInput
            onActivated: TimewarriorService.showInput()
        }
    }

    // Cleanup when disabled
    onEnableShortcutsChanged: {
        if (!enableShortcuts) {
            toggleShortcut?.destroy()
            inputShortcut?.destroy()
            toggleShortcut = null
            inputShortcut = null
        }
    }

    onEnableIpcChanged: {
        if (!enableIpc) {
            ipcHandler?.destroy()
            ipcHandler = null
        }
    }
}