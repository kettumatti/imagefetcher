import QtQuick 6.5
import QtQuick.Layouts
import QtQuick.Controls 6.5 as QQC2
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: root
    implicitWidth: 600
    implicitHeight: childrenRect.height

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignTop

        // Refresh interval
        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            Layout.alignment: Qt.AlignTop

            QQC2.Label {
                text: qsTr("Refresh interval")
                Layout.preferredWidth: 150
                Layout.alignment: Qt.AlignTop
            }

            QQC2.SpinBox {
                id: refreshValue
                from: 1; to: 3600; stepSize: 1
                Layout.preferredWidth: 100
                Layout.alignment: Qt.AlignTop
                value: plasmoid.configuration.refreshInterval /
                       (refreshUnit.currentIndex === 0 ? 1000 : 60000)
                onValueChanged: {
                    plasmoid.configuration.refreshInterval =
                        refreshValue.value * (refreshUnit.currentIndex === 0 ? 1000 : 60000)
                }
            }

            QQC2.ComboBox {
                id: refreshUnit
                Layout.preferredWidth: 100
                Layout.alignment: Qt.AlignTop
                model: [qsTr("seconds"), qsTr("minutes")]
                currentIndex: plasmoid.configuration.refreshUnitIndex || 0

                onCurrentIndexChanged: {
                    plasmoid.configuration.refreshUnitIndex = currentIndex
                    refreshValue.value = plasmoid.configuration.refreshInterval /
                        (currentIndex === 0 ? 1000 : 60000)
                }
            }
        }

        ColumnLayout {
            spacing: 6
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop

            // Add new URL
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                spacing: 6

                QQC2.Label {
                    text: qsTr("Add new URL")
                    Layout.preferredWidth: 150
                    Layout.alignment: Qt.AlignTop
                }

                QQC2.TextField {
                    id: newUrl
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    placeholderText: qsTr("https://... file://... The URL will be added to the list once you hit Enter.")
                    onAccepted: {
                        var list = plasmoid.configuration.imageUrls || []
                        list.push(text.trim())
                        plasmoid.configuration.imageUrls = list
                        text = ""
                    }
                }
            }

            //QQC2.Label {
            //    text: qsTr("The URL will be added to the list once you hit Enter.")
            //    wrapMode: Text.WordWrap
            //    Layout.fillWidth: true
            //}

        
            QQC2.Label {
                text: qsTr("Image URLs:")
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
            }
            
            Repeater {
                model: plasmoid.configuration.imageUrls || []

                delegate: RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    spacing: 6
                    
                    QQC2.TextField {
                        text: modelData
                        Layout.fillWidth: true
                        Layout.minimumWidth: 100
                        Layout.maximumWidth: 1000
                        Layout.alignment: Qt.AlignTop
                        onTextChanged: {
                            var list = plasmoid.configuration.imageUrls
                            list[index] = text
                            plasmoid.configuration.imageUrls = list
                        }
                    }

                    QQC2.Button {
                        icon.name: "user-trash"
                        implicitWidth: 30
                        Layout.alignment: Qt.AlignTop
                        onClicked: {
                            var list = plasmoid.configuration.imageUrls
                            list.splice(index, 1)
                            plasmoid.configuration.imageUrls = list
                        }
                    }
                }
            }
        }

        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                event.accepted = true
            }
        }
    }
}
