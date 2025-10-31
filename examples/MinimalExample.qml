import QtQuick 2.15
import qs_timew 2.0

/**
 * MinimalExample - The simplest possible usage of qs-timew
 *
 * This shows the absolute minimum code needed to use the timewarrior widget.
 */
Rectangle {
    width: 180
    height: 32
    color: "#f5f5f5"
    radius: 4

    // Just the widget, nothing else
    TimewarriorWidget {
        anchors.fill: parent
        anchors.margins: 2
    }
}