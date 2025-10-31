import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import qs.modules.common

// Standard popup component following QuickShell patterns
StyledPopup {
    id: root

    // Standard properties
    property alias title: titleText.text
    property alias content: contentLoader.sourceComponent
    property var callback: null

    // Title bar
    RowLayout {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10

        Text {
            id: titleText
            color: Appearance.colors.colOnLayer1
            font.family: Appearance.font.family.main
            font.pixelSize: Appearance.font.sizes.large
            font.bold: true
        }
    }

    // Content area
    Loader {
        id: contentLoader
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 10
    }
}