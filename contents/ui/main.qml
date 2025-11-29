import QtQuick 6.5
import org.kde.plasma.plasmoid
import QtQuick.Controls 6.5


PlasmoidItem {
    id: root
    width: 300

    property int currentIndex: 0
    property bool zoomed: false
    property real clickRatioX: 0.5
    property real clickRatioY: 0.5
    property bool mouseOver: false
    property bool lastLoadOk: false


    Item {
        id: errorOverlay
        anchors.centerIn: parent
        visible: false
        z: 10
        width: parent.width * 0.8

        Rectangle {
            anchors.fill: parent
            color: "#c62828"
            opacity: 0.8
            radius: 6

            Text {
                id: errorText
                anchors.margins: 8
                anchors.fill: parent
                text: qsTr("Failed to load image")
                color: "white"
                font.bold: true
                wrapMode: Text.WrapAnywhere   
            }
        }

        // Rectangle height adjusted according to wrapped text
        height: errorText.paintedHeight + 16
    }

    compactRepresentation: Item {
        anchors.fill: parent
        opacity: 1.0

        HoverHandler {
            id: hoverHandler
            enabled: true

            onHoveredChanged: {
                root.mouseOver = hovered
                if (!hovered && root.zoomed) {
                    zoomResetTimer.restart()
                } else {
                    zoomResetTimer.stop()
                }
            }
        }

        Flickable {
            id: flickable
            anchors.fill: parent
            clip: true

            contentWidth: content.width
            contentHeight: content.height
            interactive: root.zoomed

            Item {
                id: content
                // When zoomed use images original size (implicitWidth/implicitHeight).
                // When not zoomed fit image inside the applet window.
                width: root.zoomed
                ? Math.max(oldImg.implicitWidth, 1)
                : flickable.width
                height: root.zoomed
                ? Math.max(oldImg.implicitHeight, 1)
                : flickable.height
                
                // Visible image
                Image {
                    id: oldImg
                    x: 0; y: 0
                    width: root.zoomed ? Math.max(implicitWidth, 1) : content.width
                    height: root.zoomed ? Math.max(implicitHeight, 1) : content.height

                    source: plasmoid.configuration.imageUrls
                    ? plasmoid.configuration.imageUrls[root.currentIndex]
                    : ""
                    smooth: true
                    fillMode: root.zoomed ? Image.Pad : Image.PreserveAspectFit
                    opacity: 1.0
                    visible: true

                    onStatusChanged: {
                        if (status === Image.Ready && root.zoomed) {
                            // Update content width and height
                            content.width = Math.max(implicitWidth, 1)
                            content.height = Math.max(implicitHeight, 1)
                        }
                    }
                }

                // New image to fade-in
                Image {
                    id: newImg
                    x: 0; y: 0
                    width: root.zoomed ? Math.max(implicitWidth, 1) : content.width
                    height: root.zoomed ? Math.max(implicitHeight, 1) : content.height
                    smooth: true
                    fillMode: root.zoomed ? Image.Pad : Image.PreserveAspectFit
                    opacity: 0.0
                    visible: false

                    function updateSource(url) {
                        if (!url || url.length === 0) return
                            var newUrl = url + "?t=" + Date.now()
                            source = newUrl
                            visible = true
                    }

                    // onStatusChanged: if (status === Image.Ready) fadeIn.start()
                    onStatusChanged: {
                        if (status === Image.Ready) {
                            // errorOverlay.visible = false
                            lastLoadOk = true
                            fadeIn.start()
                            retryTimer.stop()
                            refreshTimer.start()
                        } else if (status === Image.Error) {
                            lastLoadOk = false
                            errorOverlay.visible = true
                            errorText.text = qsTr("Failed to load image: ") + plasmoid.configuration.imageUrls[root.currentIndex]

                            errorMessageDelay.start()
                            // errorLabel.visible = false
                            
                            flickable.tryNextImage()
                        }
                    }

                    SequentialAnimation {
                        id: fadeIn
                        NumberAnimation { target: newImg; property: "opacity"; from: 0; to: 1; duration: 500 }
                        ScriptAction { script: {
                            oldImg.source = newImg.source
                            oldImg.visible = true
                            newImg.visible = false
                            newImg.opacity = 0

                            if (root.zoomed) {
                                content.width = Math.max(oldImg.implicitWidth, 1)
                                content.height = Math.max(oldImg.implicitHeight, 1)
                            }
                        }}
                    }
                }
            }
            
            function tryNextImage() {
                if (!plasmoid.configuration.imageUrls || plasmoid.configuration.imageUrls.length === 0)
                    return;

                root.currentIndex = (root.currentIndex + 1) % plasmoid.configuration.imageUrls.length;
                newImg.updateSource(plasmoid.configuration.imageUrls[root.currentIndex]);
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: function(mouse) {

                    if (mouse.button === Qt.RightButton) {
                        flickable.tryNextImage()
                        return
                    }

                    clickRatioX = mouse.x / flickable.width
                    clickRatioY = mouse.y / flickable.height

                    if (!root.zoomed) {
                        root.zoomed = true

                        // Zoomed: Use original size
                        content.width = Math.max(oldImg.implicitWidth, 1)
                        content.height = Math.max(oldImg.implicitHeight, 1)

                        // Center at the clicked point
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

                        content.width = flickable.width
                        content.height = flickable.height

                        flickable.contentX = 0
                        flickable.contentY = 0
                    }
                }
            }


        }

        // Image update
        Timer { // refreshTimer
            id: refreshTimer
            interval: plasmoid.configuration.refreshInterval
            running: true
            repeat: true
            onTriggered: {
                if (!root.zoomed && !root.mouseOver) {
                    flickable.tryNextImage()
                }
            }
        }

        Timer { // retryTimer
            id: retryTimer
            interval: 10000
            repeat: true
            running: false
            onTriggered: {
                flickable.tryNextImage()
            }
        }

        // Zoom out if mouse not hovered for 3 seconds
        Timer {
            id: zoomResetTimer
            interval: 3000
            repeat: false
            onTriggered: {
                root.zoomed = false
                content.width = flickable.width
                content.height = flickable.height
                flickable.contentX = 0
                flickable.contentY = 0
            }
        }
        Timer {
            id: errorMessageDelay
            interval: 5000 
            repeat: false
            onTriggered: {
                errorOverlay.visible = false
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
