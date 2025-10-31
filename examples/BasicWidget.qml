import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import qs_timew 2.0

/**
 * BasicWidget - Simple example of using qs-timew in a standalone application
 *
 * This example shows the minimal setup needed to use the TimewarriorWidget
 * in a standard Qt Quick application.
 */
ApplicationWindow {
    id: window

    visible: true
    width: 400
    height: 300
    title: "qs-timew Basic Example"

    // Main layout
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Title
        Text {
            text: "qs-timew Basic Example"
            font.pixelSize: 20
            font.weight: Font.Bold
            Layout.alignment: Qt.AlignHCenter
        }

        // Description
        Text {
            text: "This is a basic example showing how to integrate the qs-timew module into any Qt Quick application."
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }

        // The timewarrior widget
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 200
            Layout.preferredHeight: 40
            color: "#f0f0f0"
            radius: 8

            // This is the core widget from the qs-timew module
            TimewarriorWidget {
                id: timewWidget
                anchors.fill: parent
                anchors.margins: 4

                // Enable global shortcuts for this example
                enableGlobalShortcuts: true
            }
        }

        // Status information
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "Status Information:"
                font.weight: Font.Bold
            }

            Text {
                text: "Timer Active: " + (TimewarriorService.timerActive ? "Yes" : "No")
            }

            Text {
                text: "Current Tags: " + (TimewarriorService.currentTags.length > 0 ? TimewarriorService.currentTags.join(", ") : "None")
            }

            Text {
                text: "Elapsed Time: " + (TimewarriorService.timerActive ? TimewarriorService.formatElapsedTime(TimewarriorService.elapsedSeconds) : "N/A")
            }

            Text {
                text: "Timewarrior Available: " + (TimewarriorService.timewAvailable ? "Yes" : "No")
                color: TimewarriorService.timewAvailable ? "green" : "red"
            }

            Text {
                text: "Error: " + (TimewarriorService.errorMessage || "None")
                visible: TimewarriorService.errorMessage.length > 0
                color: "red"
            }
        }

        // Instructions
        Text {
            text: "Instructions:
• Click 'Start' to begin a timer with tags
• Click the timer display to stop it
• Hover over the timer and click the edit icon to modify tags
• Use Ctrl+Shift+T to toggle timer, Ctrl+Shift+I for input, Ctrl+Shift+E to edit"
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }
    }

    // Keyboard shortcuts for this example
    Shortcut {
        sequence: "Ctrl+Q"
        onActivated: Qt.quit()
    }
}