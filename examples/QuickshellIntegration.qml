import qs
import qs.modules.common.widgets
import qs.services
import QtQuick 2.15
import qs_timew 2.0

/**
 * QuickshellIntegration - Example of using qs-timew in QuickShell
 *
 * This example shows how to integrate the standalone qs-timew module
 * back into QuickShell, demonstrating the module's reusability.
 */
Item {
    id: root

    implicitWidth: 200
    implicitHeight: 40

    // Use the standalone widget with QuickShell integration
    Rectangle {
        anchors.fill: parent
        color: Appearance.colors.colLayer1
        radius: Appearance.rounding.small

        // The standalone widget
        TimewarriorWidget {
            id: timewWidget
            anchors.fill: parent
            anchors.margins: 4

            // Disable global shortcuts since QuickShell handles them
            enableGlobalShortcuts: false

            // Enable IPC handler for QuickShell integration
            enableIpcHandler: true
        }

        // QuickShell-specific enhancements
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            // Add QuickShell-specific context menu or actions here
            onClicked: {
                // Could open QuickShell-specific menus or actions
                console.log("QuickShell timewarrior widget clicked")
            }
        }
    }

    // QuickShell global shortcuts (if needed)
    GlobalShortcut {
        name: "timewarriorQuickToggle"
        description: "QuickShell timewarrior toggle"

        onPressed: {
            if (TimewarriorService.timerActive) {
                TimewarriorService.stopTimer();
            } else {
                // Use QuickShell-specific input method
                console.log("Open QuickShell input dialog");
            }
        }
    }
}