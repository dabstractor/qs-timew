import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.modules.common

// Input popup for timer tags
StyledPopup {
    id: root

    property alias placeholder: inputField.placeholderText
    property alias text: inputField.text
    property var onSubmit: null

    title: "Start Timer"
    width: 300
    height: 120

    content: Component {
        ColumnLayout {
            anchors.fill: parent

            TextField {
                id: inputField
                Layout.fillWidth: true
                placeholderText: "Enter tags (space separated)"
                color: Appearance.colors.colOnLayer1
                background: Rectangle {
                    color: Appearance.colors.colLayer2
                    border.color: Appearance.colors.colBorder
                    border.width: 1
                    radius: 4
                }

                onAccepted: root.onSubmit?.call()
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight

                Button {
                    text: "Cancel"
                    onClicked: root.close()

                    background: Rectangle {
                        color: Appearance.colors.colLayer2
                        border.color: Appearance.colors.colBorder
                        radius: 4
                    }

                    contentItem: Text {
                        text: parent.text
                        color: Appearance.colors.colOnLayer1
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    text: "Start"
                    onClicked: root.onSubmit?.call()

                    background: Rectangle {
                        color: Appearance.colors.colAccent
                        radius: 4
                    }

                    contentItem: Text {
                        text: parent.text
                        color: Appearance.colors.colOnAccent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }
}