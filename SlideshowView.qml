/*
 * Copyright 2014 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.2
import Ubuntu.Components 1.0
import Ubuntu.Components.ListItems 1.0 as ListItems
import Ubuntu.Components.Popups 1.0
import Ubuntu.OnlineAccounts 0.1
import Ubuntu.OnlineAccounts.Client 0.1
import Ubuntu.Components.Extras 0.1
import CameraApp 0.1

Item {
    id: slideshowView

    property var model
    property int currentIndex: listView.currentIndex
    property string currentFilePath: slideshowView.model.get(slideshowView.currentIndex, "filePath")
    signal toggleHeader
    property list<Action> actions: [
                Action {
                    text: i18n.tr("Share")
                    iconName: "share"
                    onTriggered: PopupUtils.open(accountsPopoverComponent)
                },
                Action {
                    text: i18n.tr("Delete")
                    iconName: "delete"
                    onTriggered: PopupUtils.open(deleteDialogComponent)
                }
            ]

    function showPhotoAtIndex(index) {
        listView.positionViewAtIndex(index, ListView.Contain);
    }

    function showLastPhotoTaken() {
        listView.positionViewAtBeginning();
    }

    function exit() {
        listView.currentItem.zoomOut();
    }

    ListView {
        id: listView
        Component.onCompleted: {
            // FIXME: workaround for qtubuntu not returning values depending on the grid unit definition
            // for Flickable.maximumFlickVelocity and Flickable.flickDeceleration
            var scaleFactor = units.gridUnit / 8;
            maximumFlickVelocity = maximumFlickVelocity * scaleFactor;
            flickDeceleration = flickDeceleration * scaleFactor;
        }

        anchors.fill: parent
        model: slideshowView.model
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem
        boundsBehavior: Flickable.StopAtBounds
        cacheBuffer: width
        highlightRangeMode: ListView.StrictlyEnforceRange
        spacing: units.gu(1)

        delegate: Item {
            function zoomIn(centerX, centerY) {
                flickable.scaleCenterX = centerX / flickable.width;
                flickable.scaleCenterY = centerY / flickable.height;
                flickable.sizeScale = 3.0;
            }

            function zoomOut() {
                flickable.scaleCenterX = flickable.contentX / flickable.width / (flickable.sizeScale - 1);
                flickable.scaleCenterY = flickable.contentY / flickable.height / (flickable.sizeScale - 1);
                flickable.sizeScale = 1.0;
            }

            width: ListView.view.width
            height: ListView.view.height

            ActivityIndicator {
                anchors.centerIn: parent
                visible: running
                running: image.status != Image.Ready
            }

            Flickable {
                id: flickable
                anchors.fill: parent
                contentWidth: media.width
                contentHeight: media.height
                contentX: (sizeScale - 1) * scaleCenterX * width
                contentY: (sizeScale - 1) * scaleCenterY * height

                property real sizeScale: 1.0
                property real scaleCenterX
                property real scaleCenterY
                Behavior on sizeScale { UbuntuNumberAnimation {duration: UbuntuAnimation.FastDuration} }

                Item {
                    id: media

                    width: flickable.width * flickable.sizeScale
                    height: flickable.height * flickable.sizeScale

                    Image {
                        id: image
                        anchors.fill: parent
                        asynchronous: true
                        cache: false
                        // FIXME: should use the thumbnailer instead of loading the full image and downscaling on the fly
                        source: fileURL
                        sourceSize {
                            width: flickable.width
                            height: flickable.height
                        }
                        fillMode: Image.PreserveAspectFit
                        opacity: status == Image.Ready ? 1.0 : 0.0
                        Behavior on opacity { UbuntuNumberAnimation {duration: UbuntuAnimation.FastDuration} }

                    }

                    Image {
                        id: highResolutionImage
                        anchors.fill: parent
                        asynchronous: true
                        cache: false
                        source: flickable.sizeScale > 1.0 ? fileURL : ""
                        sourceSize {
                            width: width
                            height: height
                        }
                        fillMode: Image.PreserveAspectFit
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        slideshowView.toggleHeader();
                        mouse.accepted = false;
                    }
                    onDoubleClicked: {
                        if (flickable.sizeScale == 1.0) {
                            zoomIn(mouse.x, mouse.y);
                        } else {
                            zoomOut();
                        }
                    }
                }
            }
        }
    }


    Component {
        id: sharePopoverComponent

        Popover {
            id: sharePopover

            property string fileToShare: sharePopover.fileToShare
            property string userAccountId: sharePopover.userAccountId

            Share {
                anchors {
                    left: parent.left
                    top: parent.top
                    right: parent.right
                }
                height: units.gu(40)
                fileToShare: sharePopover.fileToShare
                userAccountId: sharePopover.userAccountId
                onUploadCompleted: PopupUtils.close(sharePopover);
                onCanceled: PopupUtils.close(sharePopover);
            }
        }
    }

    Component {
        id: accountsPopoverComponent

        Popover {
            id: accountsPopover

            AccountServiceModel {
                id: accounts
                serviceType: "sharing"
            }

            ProviderModel {
                id: providers
                applicationId: "camera-app"
            }

            Setup {
                id: accountsSetup
                // FIXME: workaround lack of 'applicationId' property in earlier versions of the API
                // code should simply be: applicationId: providers.applicationId
                Component.onCompleted: if (accountsSetup.hasOwnProperty("applicationId")) {
                                           accountsSetup.applicationId = providers.applicationId;
                                       }
            }

            Column {
                id: providersList
                visible: accounts.count == 0
                anchors {
                    left: parent.left
                    top: parent.top
                    right: parent.right
                }

                ListItems.Standard {
                    text: i18n.tr("Select sharing account to setup:")
                }

                Repeater {
                    model: providers
                    delegate: ListItems.Standard {
                        text: model.displayName
                        iconName: model.iconName

                        onClicked: {
                            accountsSetup.providerId = providerId;
                            accountsSetup.exec();
                        }
                    }
                }
            }

            Column {
                id: accountsList
                visible: accounts.count != 0
                anchors {
                    left: parent.left
                    top: parent.top
                    right: parent.right
                }
                Repeater {
                    model: accounts
                    delegate: ListItems.Standard {
                        Account {
                            id: account
                            objectHandle: model.accountHandle
                        }

                        text: account.provider.displayName
                        iconName: account.provider.iconName

                        onClicked: {
                            PopupUtils.close(accountsPopover);
                            PopupUtils.open(sharePopoverComponent, null, {"fileToShare": slideshowView.currentFilePath,
                                                                          "userAccountId": account.accountId});
                        }
                    }
                }
            }
        }
    }

    Component {
        id: deleteDialogComponent

        Dialog {
            id: deleteDialog

            title: i18n.tr("Delete media?")

            FileOperations {
                id: fileOperations
            }

            Button {
                text: i18n.tr("Cancel")
                color: UbuntuColors.warmGrey
                onClicked: PopupUtils.close(deleteDialog)
            }
            Button {
                text: i18n.tr("Delete")
                color: UbuntuColors.orange
                onClicked: {
                    fileOperations.remove(slideshowView.currentFilePath);
                    PopupUtils.close(deleteDialog);
                }
            }
        }
    }

}
