import QtQuick
import qs.modules.common

// Internal theme manager - handles all theming for the module
QtObject {
    id: root

    // Material 3 color system
    readonly property var colors: ({
        primary: Appearance.colors.colAccent,
        onPrimary: Appearance.colors.colOnAccent,
        secondary: Appearance.colors.colLayer2,
        onSecondary: Appearance.colors.colOnLayer1,
        surface: Appearance.colors.colLayer1,
        onSurface: Appearance.colors.colOnLayer1,
        background: Appearance.colors.colLayer0,
        onBackground: Appearance.colors.colOnLayer0,
        error: "#BA1A1A",
        onError: "#FFFFFF",
        border: Appearance.colors.colBorder
    })

    // Typography
    readonly property var fonts: ({
        family: Appearance.font.family.main,
        sizes: ({
            small: Appearance.font.sizes.small,
            medium: Appearance.font.sizes.medium,
            large: Appearance.font.sizes.large
        })
    })

    // Animation configurations
    readonly property var animations: ({
        duration: Appearance.animation.fast,
        easing: Easing.OutQuad
    })

    // Component factory methods
    function themedButton(properties) {
        return themedButtonComponent.createObject(null, properties)
    }

    function themedTextField(properties) {
        return themedTextFieldComponent.createObject(null, properties)
    }

    function themedIcon(properties) {
        return themedIconComponent.createObject(null, properties)
    }

    // Themed component definitions
    property Component themedButtonComponent: Component {
        Rectangle {
            id: btn
            property alias text: btnText.text
            property alias onClicked: mouseArea.onClicked
            property color bgColor: root.colors.primary
            property color textColor: root.colors.onPrimary

            color: mouseArea.pressed ? Qt.darker(bgColor, 1.2) : bgColor
            radius: 4

            Behavior on color {
                ColorAnimation { duration: root.animations.duration; easing: root.animations.easing }
            }

            Text {
                id: btnText
                anchors.centerIn: parent
                color: textColor
                font.family: root.fonts.family
                font.pixelSize: root.fonts.sizes.medium
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                onClicked: btn.clicked()
            }
        }
    }

    property Component themedTextFieldComponent: Component {
        Rectangle {
            id: field
            property alias text: fieldText.text
            property alias placeholder: fieldText.placeholderText
            property alias onAccepted: fieldText.onAccepted

            color: root.colors.surface
            border.color: root.colors.border
            border.width: 1
            radius: 4

            TextInput {
                id: fieldText
                anchors.fill: parent
                anchors.margins: 8
                color: root.colors.onSurface
                font.family: root.fonts.family
                font.pixelSize: root.fonts.sizes.medium
                placeholderTextColor: Qt.lighter(root.colors.onSurface, 0.6)
            }
        }
    }

    property Component themedIconComponent: Component {
        Text {
            id: icon
            property alias iconName: icon.text
            property color iconColor: root.colors.onSurface

            color: iconColor
            font.family: root.fonts.family
            font.pixelSize: root.fonts.sizes.large
        }
    }
}