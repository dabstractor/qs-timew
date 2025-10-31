import QtQuick
import qs.modules.common

// Manages all popup instances and interactions
QtObject {
    id: root

    property var inputPopup: null
    property var editPopup: null
    property var activePopup: null

    // Create input popup
    function showInput(callback) {
        if (!inputPopup) {
            inputPopup = Qt.createQmlObject(
                'import QtQuick; import "qrc:/components"; TagInputPopup { anchors.centerIn: parent }',
                root,
                "inputPopup"
            )
        }

        activePopup = inputPopup
        inputPopup.text = ""
        inputPopup.onSubmit = function() {
            if (inputPopup.text.trim().length > 0) {
                callback(inputPopup.text.trim().split(/\s+/))
                inputPopup.close()
            }
        }
        inputPopup.open()
    }

    // Create edit popup
    function showEdit(currentTags, callback) {
        if (!editPopup) {
            editPopup = Qt.createQmlObject(
                'import QtQuick; import "qrc:/components"; TagEditPopup { anchors.centerIn: parent }',
                root,
                "editPopup"
            )
        }

        activePopup = editPopup
        editPopup.currentTags = currentTags.join(" ")
        editPopup.onSubmit = function() {
            if (editPopup.currentTags.trim().length > 0) {
                callback(editPopup.currentTags.trim().split(/\s+/))
                editPopup.close()
            }
        }
        editPopup.open()
    }

    // Close active popup
    function close() {
        if (activePopup) {
            activePopup.close()
            activePopup = null
        }
    }

    // Check if popup is active
    function isActive() {
        return activePopup !== null
    }
}