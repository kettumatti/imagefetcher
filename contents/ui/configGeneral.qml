import QtQuick 6.5
import QtQuick.Controls 6.2 as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami


Item {
    height: childrenRect.height

    Kirigami.FormLayout {
        anchors.fill: parent
        wideMode: true
        Layout.fillWidth: true
        anchors.topMargin: 20

        RowLayout {
            Kirigami.FormData.label: qsTr("Refresh interval")

            Controls.SpinBox {
                id: refreshValue
                from: 1; to: 3600; stepSize: 1
                value: plasmoid.configuration.refreshInterval /
                (refreshUnit.currentIndex === 0 ? 1000 : 60000)

                onValueChanged: {
                    plasmoid.configuration.refreshInterval =
                    refreshValue.value * (refreshUnit.currentIndex === 0 ? 1000 : 60000)
                }
            }

            Controls.ComboBox {
                id: refreshUnit
                model: [qsTr("seconds"), qsTr("minutes")]

                currentIndex: plasmoid.configuration.refreshUnitIndex || 0

                onCurrentIndexChanged: {
                    plasmoid.configuration.refreshUnitIndex = currentIndex

                    if (currentIndex === 0) {
                        refreshValue.value = plasmoid.configuration.refreshInterval / 1000
                    } else {
                        refreshValue.value = plasmoid.configuration.refreshInterval / 60000
                    }
                }
            }
        }

        // Add new URL
        Kirigami.ActionTextField {
            Kirigami.FormData.label: qsTr("Add new URL")
            placeholderText: qsTr("https://... file://...")
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
                Layout.fillWidth: true
                Controls.TextField {
                    text: modelData
                    Layout.fillWidth: true

                    // Update the list but don't close the window after pressing Enter
                    onTextChanged: {
                        var list = plasmoid.configuration.imageUrls
                        list[index] = text
                        plasmoid.configuration.imageUrls = list
                    }
                }

                Controls.Button {
                    icon.name: "user-trash"
                    // text: qsTr("✕")
                    implicitWidth: 24
                    onClicked: {
                        var list = plasmoid.configuration.imageUrls
                        list.splice(index, 1)
                        plasmoid.configuration.imageUrls = list
                    }
                }
            }
        }
        Controls.Label {

            text: qsTr("\nThe URL will be added to the list once you hit Enter.")
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

    }

}
