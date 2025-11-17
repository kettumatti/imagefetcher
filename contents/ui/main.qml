import QtQuick 6.5
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    width: 300
    //height: 300

    // nyt lista
    property int currentIndex: 0
    property bool zoomed: false
    property real clickRatioX: 0.5
    property real clickRatioY: 0.5

    compactRepresentation: Item {
        anchors.fill: parent
        opacity: 1.0

        Flickable {
            id: flickable
            anchors.fill: parent
            clip: true
            contentWidth: zoomed ? parent.width * 2 : parent.width
            contentHeight: zoomed ? parent.height * 2 : parent.height
            interactive: zoomed

            Image {
                id: oldImg
                anchors.fill: parent
                source: plasmoid.configuration.imageUrls
                        ? plasmoid.configuration.imageUrls[root.currentIndex]
                        : ""
                smooth: true
                fillMode: zoomed ? Image.PreserveAspectCrop : Image.PreserveAspectFit
                opacity: 1.0
                visible: true
            }

            Image {
                id: newImg
                anchors.fill: parent
                smooth: true
                fillMode: zoomed ? Image.PreserveAspectCrop : Image.PreserveAspectFit
                opacity: 0.0
                visible: false

                function updateSource(url) {
                    if (!url || url.length === 0) return
                        var newUrl = url + "?t=" + Date.now()
                        source = newUrl
                        visible = true
                }

                onStatusChanged: if (status === Image.Ready) fadeIn.start()

                SequentialAnimation {
                    id: fadeIn
                    NumberAnimation { target: newImg; property: "opacity"; from: 0; to: 1; duration: 500 }
                    ScriptAction { script: {
                        oldImg.source = newImg.source
                        oldImg.visible = true
                        newImg.visible = false
                        newImg.opacity = 0
                    }}
                }
            }

            function reloadImage() {
                if (!plasmoid.configuration.imageUrls || plasmoid.configuration.imageUrls.length === 0)
                    return
                    newImg.updateSource(plasmoid.configuration.imageUrls[root.currentIndex])
            }


            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                cursorShape: Qt.PointingHandCursor
                onClicked: function(mouse) {
                    clickRatioX = mouse.x / flickable.width
                    clickRatioY = mouse.y / flickable.height

                    if (!root.zoomed) {
                        root.zoomed = true
                        flickable.contentX = clickRatioX * flickable.contentWidth - flickable.width / 2
                        flickable.contentY = clickRatioY * flickable.contentHeight - flickable.height / 2
                        if (flickable.contentX < 0) flickable.contentX = 0
                            if (flickable.contentY < 0) flickable.contentY = 0
                                if (flickable.contentX > flickable.contentWidth - flickable.width)
                                    flickable.contentX = flickable.contentWidth - flickable.width
                                    if (flickable.contentY > flickable.contentHeight - flickable.height)
                                        flickable.contentY = flickable.contentHeight - flickable.height
                    } else {
                        root.zoomed = false
                        flickable.contentX = 0
                        flickable.contentY = 0
                    }
                }
            }
        }

        Timer {
            id: refreshTimer
            interval: plasmoid.configuration.refreshInterval
            running: true
            repeat: true
            onTriggered: {
                if (plasmoid.configuration.imageUrls
                    && plasmoid.configuration.imageUrls.length > 0) {
                    root.currentIndex = (root.currentIndex + 1) % plasmoid.configuration.imageUrls.length
                    flickable.reloadImage()
                    }
            }
        }
    }

    fullRepresentation: compactRepresentation

    Connections {
        target: plasmoid.configuration

        onImageUrlsChanged: {
            root.currentIndex = 0
            if (compactRepresentation.flickable)
                compactRepresentation.flickable.reloadImage()
        }

        onRefreshIntervalChanged: {
            if (compactRepresentation.flickable)
                compactRepresentation.flickable.reloadImage()
        }
    }
}


