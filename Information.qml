import QtQuick 2.0
import Ubuntu.Components 1.3
import QtQuick.Window 2.2
import QtSensors 5.4

Item {
    id:_infoPage
    height: infoHeader.height + aboutCloumn.height + infoLinksList.height

    property bool portrait: (Screen.orientation == Screen.primaryOrientation)

    transitions: [
        Transition {
          NumberAnimation { properties: "width,height,x,y"; duration: UbuntuAnimation.FastDuration}

        }
    ]

    states: [
        State {
            name: "landscape"
            when: !infoPage.portrait

            PropertyChanges {
                target: aboutCloumn
                width: parent.width/2
            }

            PropertyChanges {
                target: _infoPage
                height:infoHeader.height + aboutCloumn.height
            }

            AnchorChanges {
                target: aboutCloumn
                anchors {
                    top:infoHeader.bottom
                    left: parent.left
                    right: undefined
                    bottom:parent.bottom
                }
            }

            AnchorChanges {
                target: infoLinksList
                anchors {
                    top:infoHeader.bottom
                    left: aboutCloumn.right
                    right: parent.right
                    bottom:parent.bottom
                }
            }
        }
    ]

    ListModel {
       id: infoModel
     }

    Component.onCompleted: {
        infoModel.append({ name: i18n.tr("Get the source"), url: "https://github.com/ubports/camera-app" })
        infoModel.append({ name: i18n.tr("Report issues"), url: "https://github.com/ubports/camera-app/issues/" })
        infoModel.append({ name: i18n.tr("Help translate"), url: "https://translate.ubports.com/projects/ubports/camera-app/" })
    }

    Label {
        id:infoHeader
        height:units.gu(3)
        width:parent.width
        color: "white"
        text: i18n.tr("App Information")
    }

    Column {
        id: aboutCloumn
        anchors.top: infoHeader.bottom
        anchors.topMargin: units.gu(2)
        spacing:units.dp(2)
        width:parent.width
        height:units.gu(33)

        Icon {
          anchors.horizontalCenter: parent.horizontalCenter

          height: Math.min(parent.width/2, parent.height/2)
          width:height
          name:"camera-app"
          layer.enabled: true
          layer.effect: UbuntuShapeOverlay {
              relativeRadius: 0.75
           }
        }
        Label {
            width: parent.width
            font.pixelSize: units.gu(5)
            font.bold: true
            color: UbuntuColors.silk
            horizontalAlignment: Text.AlignHCenter
            text: "Camera App"
        }
        Label {
            width: parent.width
            color: UbuntuColors.ash
            horizontalAlignment: Text.AlignHCenter
            text: i18n.tr("Version %1").arg("3.0.1.747")
        }

    }

    UbuntuListView {
        id:infoLinksList
        height:units.gu(35)
         anchors {
            top: aboutCloumn.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
         }

         currentIndex: -1
         interactive: false

         model :infoModel
         delegate: ListItem {
             highlightColor:"#800F0F0F"
            ListItemLayout {
             title.text : model.name
             title.color: UbuntuColors.silk
             Icon {
                 width:units.gu(2)
                 name:"go-to"
             }
            }
            onClicked: Qt.openUrlExternally(model.url)


         }

    }

}
