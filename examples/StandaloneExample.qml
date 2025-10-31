import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.platform 1.1

// Import the TimewarriorWidget from the module
// Note: This assumes the module is properly registered in qmldir
// import QSTimew.Widgets 1.0

ApplicationWindow {
    id: window
    title: "Standalone Timewarrior Widget Example"
    width: 800
    height: 600
    visible: true

    // Material theme setup
    Material.theme: Material.System
    Material.accent: "#6750A4"
    Material.primary: "#6750A4"

    // Header bar with widget
    Rectangle {
        id: headerBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        color: "#2C2C2C"

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 20

            // App title
            Text {
                text: "Timewarrior Standalone Widget"
                color: "white"
                font.pixelSize: 18
                font.weight: Font.Bold
                Layout.fillWidth: true
            }

            // Include the standalone TimewarriorWidget
            // Note: Replace with actual import path when module is registered
            // TimewarriorWidget {
            //     enableGlobalShortcuts: true
            //     enableIpcHandler: false
            // }

            // For now, we'll use a placeholder since the module isn't registered
            Rectangle {
                width: 180
                height: 32
                color: "#6750A4"
                radius: 6
                Text {
                    anchors.centerIn: parent
                    text: "Timewarrior Widget"
                    color: "white"
                }
            }
        }
    }

    // Main content area
    ColumnLayout {
        anchors.top: headerBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20
        spacing: 20

        // Instructions
        GroupBox {
            title: "Widget Features"
            Layout.fillWidth: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 10

                Text {
                    text: "This standalone TimewarriorWidget provides the following functionality:"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Text {
                    text: "• Three states: Idle (Start button), Active (timer display), Error (timew not found)"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    leftPadding: 20
                }

                Text {
                    text: "• Tag input popup with validation"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    leftPadding: 20
                }

                Text {
                    text: "• Tag editing popup for active timer"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    leftPadding: 20
                }

                Text {
                    text: "• Real-time elapsed time updates"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    leftPadding: 20
                }

                Text {
                    text: "• Keyboard navigation (Enter/Escape)"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    leftPadding: 20
                }

                Text {
                    text: "• Optional global shortcuts (Ctrl+Shift+T/I/E)"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    leftPadding: 20
                }
            }
        }

        // Configuration options
        GroupBox {
            title: "Configuration"
            Layout.fillWidth: true

            GridLayout {
                anchors.fill: parent
                columns: 2
                columnSpacing: 10
                rowSpacing: 10

                CheckBox {
                    id: globalShortcutsCheck
                    text: "Enable Global Shortcuts"
                    checked: false
                }

                CheckBox {
                    id: ipcHandlerCheck
                    text: "Enable IPC Handler"
                    checked: false
                }

                Text {
                    text: "Global Shortcuts:"
                    Layout.alignment: Qt.AlignRight
                }

                Text {
                    text: "Ctrl+Shift+T: Start/Stop\nCtrl+Shift+I: Open Input\nCtrl+Shift+E: Edit Tags"
                    Layout.fillWidth: true
                }
            }
        }

        // Manual controls for testing
        GroupBox {
            title: "Manual Controls (for testing)"
            Layout.fillWidth: true

            RowLayout {
                anchors.fill: parent
                spacing: 10

                Button {
                    text: "Open Input Popup"
                    onClicked: {
                        // This would call: timewarriorWidget.inputPopup.open()
                        console.log("Open input popup clicked")
                    }
                }

                Button {
                    text: "Edit Tags"
                    onClicked: {
                        // This would call: timewarriorWidget.tagEditPopup.open()
                        console.log("Edit tags clicked")
                    }
                }

                Button {
                    text: "Start Timer"
                    onClicked: {
                        // This would call: TimewarriorService.startTimer(["test", "tags"])
                        console.log("Start timer clicked")
                    }
                }

                Button {
                    text: "Stop Timer"
                    onClicked: {
                        // This would call: TimewarriorService.stopTimer()
                        console.log("Stop timer clicked")
                    }
                }
            }
        }

        // Status display
        GroupBox {
            title: "Service Status"
            Layout.fillWidth: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 5

                Text {
                    id: statusText
                    text: "Status: Ready"
                    Layout.fillWidth: true
                }

                Text {
                    id: timerStatusText
                    text: "Timer: Inactive"
                    Layout.fillWidth: true
                }

                Text {
                    id: tagsText
                    text: "Tags: None"
                    Layout.fillWidth: true
                }
            }
        }
    }

    // Timer to simulate status updates (for demonstration)
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            // In a real implementation, this would connect to TimewarriorService signals
            const date = new Date()
            statusText.text = `Status: Updated at ${date.toLocaleTimeString()}`
        }
    }
}