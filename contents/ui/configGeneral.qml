import QtQuick 6.5
import QtQuick.Controls 6.2 as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami


Kirigami.FormLayout {


    Controls.SpinBox {
        Kirigami.FormData.label: qsTr("Refresh interval (seconds)")
        from: 5; to: 3600; stepSize: 1
        value: plasmoid.configuration.refreshInterval / 1000
        onValueChanged: plasmoid.configuration.refreshInterval = value * 1000
    }

    // Uuden URLin lisääminen
    Kirigami.ActionTextField {
        Kirigami.FormData.label: qsTr("Add new URL")
        placeholderText: qsTr("https://...")
        onAccepted: {
            var list = plasmoid.configuration.imageUrls || []
            list.push(text.trim())
            plasmoid.configuration.imageUrls = list
            text = ""
        }
    }

    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            event.accepted = true
        }
    }

    Repeater {
        model: plasmoid.configuration.imageUrls || []
        delegate: RowLayout {
            spacing: 6
            Controls.TextField {
                text: modelData
                Layout.fillWidth: true

                // Päivitä listaan, mutta estä Enterin propagointi dialogille
                onTextChanged: {
                    var list = plasmoid.configuration.imageUrls
                    list[index] = text
                    plasmoid.configuration.imageUrls = list
                }
            }

            Controls.Button {
                text: qsTr("✕")
                onClicked: {
                    var list = plasmoid.configuration.imageUrls
                    list.splice(index, 1)
                    plasmoid.configuration.imageUrls = list
                }
            }
        }
    }

}

