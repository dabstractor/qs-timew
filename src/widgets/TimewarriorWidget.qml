import QtQuick 2.15
import qs.modules.common
import "qrc:/components"

Item {
    id: root

    // Optional user configuration (5 properties max)
    property bool enableShortcuts: false
    property bool enableIpc: false
    property string shortcutToggle: "Ctrl+Shift+T"
    property string shortcutInput: "Ctrl+Shift+I"
    property bool compactMode: false
    property bool showSeconds: true

    implicitWidth: compactMode ? 120 : 180
    implicitHeight: 32

    // Pure presentation - delegate everything to service
    MouseArea {
        anchors.fill: parent
        onClicked: TimewarriorService.handleClick()
    }

    // Content provided by service - no UI logic here
    Loader {
        anchors.fill: parent
        sourceComponent: TimewarriorService.currentDisplay
    }

    // Optional integrations - completely separate
    IntegrationComponent {
        enableShortcuts: root.enableShortcuts
        enableIpc: root.enableIpc
        shortcutToggle: root.shortcutToggle
        shortcutInput: root.shortcutInput
    }
}