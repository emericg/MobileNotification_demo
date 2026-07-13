import QtQuick
import QtQuick.Controls
import QtQuick.Window

import MobileUI
import MobileNotification

Window {
    id: appWindow

    minimumWidth: 480
    minimumHeight: 960

    flags: Qt.Window | Qt.MaximizeUsingFullscreenGeometryHint
    visible: true
    color: "#eee"

    // MOBILE UI ///////////////////////////////////////////////////////////////

    // 1 = Qt.PortraitOrientation, 2 = Qt.LandscapeOrientation
    // 4 = Qt.InvertedPortraitOrientation, 8 = Qt.InvertedLandscapeOrientation
    property int screenOrientation: Screen.primaryOrientation
    property int screenOrientationFull: Screen.orientation

    property int screenPaddingStatusbar: MobileUI.statusbarHeight
    property int screenPaddingNavbar: MobileUI.navbarHeight

    property int screenPaddingTop: MobileUI.safeAreaTop
    property int screenPaddingLeft: MobileUI.safeAreaLeft
    property int screenPaddingRight: MobileUI.safeAreaRight
    property int screenPaddingBottom: MobileUI.safeAreaBottom

    MobileUI_dispatcher {
        statusbarColor: "transparent"
        statusbarContentColor: "#4361ee"

        navbarColor: "transparent"
        navbarContentColor: "#eee"
    }

    // MOBILE NOTIFICATION /////////////////////////////////////////////////////

    // Channel IDs we register for the demo app
    readonly property int channelDefault: 1
    readonly property int channelHigh: 2

    // Monotonic counter handing out a fresh requestId for each new notification,
    // so posted notifications coexist instead of replacing each other.
    property int notifCounter: 0

    // ID of the last notification we posted (used by "update" and "cancel last")
    property int lastRequestId: 0

    // State for the progress-bar demo
    property int progressRequestId: 0
    property int progressValue: 0

    MobileNotification_dispatcher {

        // React to MobileNotification singleton signals through a dispatcher
        onNotificationClicked: (requestId, payload) => {
            console.log("MobileNotification: notification tapped, requestId =", requestId, "payload =", payload)
        }
        onBadgeNumberChanged: {
            console.log("MobileNotification: badge number =", MobileNotification.badgeNumber)
        }

        Component.onCompleted: {
            // Register our notification channels once, at startup
            MobileNotification.registerChannel(appWindow.channelDefault, "Default",
                                               MobileNotification.ImportanceDefault, 0xFF2196F3)
            MobileNotification.registerChannel(appWindow.channelHigh, "High priority",
                                               MobileNotification.ImportanceHigh, 0xFFF44336,
                                               "", "", true)
        }
    }

    // Events handling /////////////////////////////////////////////////////////

    Connections {
        target: Qt.application
        function onStateChanged() {
            switch (Qt.application.state) {
                case Qt.ApplicationSuspended:
                    //console.log("Qt.ApplicationSuspended")
                    break
                case Qt.ApplicationHidden:
                    //console.log("Qt.ApplicationHidden")
                    break
                case Qt.ApplicationInactive:
                    //console.log("Qt.ApplicationInactive")
                    break
                case Qt.ApplicationActive:
                    //console.log("Qt.ApplicationActive")
                    MobileNotification.areNotificationsEnabled() // refresh
                    break
            }
        }
    }

    Component.onCompleted: {
        // Request notifications permission on Android
        PermissionManager.requestNotificationsPermission()

        // Check if the notifications have been disabled for this application
        MobileNotification.areNotificationsEnabled()
    }

    onClosing: (close) => {
        if (Qt.platform.os === "android") {
            close.accepted = false
            MobileUI.backToHomeScreen()
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Item {
        id: systemBars
        anchors.fill: parent

        visible: true

        // System bars // Underlay backups
        Rectangle {
            id: statusbarUnderlay
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            visible: true
            height: MobileUI.statusbarHeight
            color: MobileUI.statusbarContentColor
        }
        Rectangle {
            id: navbarUnderlay
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            visible: true
            height: MobileUI.navbarHeight
            color: MobileUI.navbarContentColor
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Item {
        id: appContent

        anchors.top: parent.top
        anchors.topMargin: Math.max(MobileUI.safeAreaTop, MobileUI.statusbarHeight)
        anchors.left: parent.left
        anchors.leftMargin: MobileUI.safeAreaLeft
        anchors.right: parent.right
        anchors.rightMargin: MobileUI.safeAreaRight
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Math.max(MobileUI.safeAreaBottom, MobileUI.navbarHeight)

        Keys.onBackPressed: {
            MobileUI.backToHomeScreen()
        }

        ////////////////

        Column {
            anchors.centerIn: parent
            spacing: 16

            visible: !(Qt.platform.os === "android" || Qt.platform.os === "ios")

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                width: appContent.width * 0.75

                text: "MobileNotification doesn't do much when used on a desktop OS." + "<br>" +
                      "Every function and variables are available and can be used without " +
                      "conditional checks, but without any functionality behind them."

                wrapMode: Text.WordWrap

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -16
                    z: -1
                    color: "white"
                }
            }
        }

        ////////////////

        Grid {
            anchors.centerIn: parent

            visible: (Qt.platform.os === "android" || Qt.platform.os === "ios")
            spacing: (appWindow.screenOrientation == Qt.PortraitOrientation) ? 32 : 0

            columns: (appWindow.screenOrientation == Qt.PortraitOrientation) ? 1 : 2
            rows: 2

            ////////

            Column { // first column
                width: (appWindow.screenOrientation == Qt.PortraitOrientation)
                        ? appWindow.width : appWindow.width / 2

                spacing: 8

                ////

                Row { // OS notification status
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8

                    Button {
                        visible: !PermissionManager.notificationsPermission

                        text: "permission: " + (PermissionManager.notificationsPermission ? "ok" : "missing!")
                        onClicked: {
                            // Request notifications permission on Android
                            PermissionManager.requestNotificationsPermission()
                        }
                    }
                    Button {
                        text: "enabled: " + (MobileNotification.notificationsEnabled ? "yes" : "no")
                        onClicked: {
                            // Check if the notifications have been disabled for this application
                            MobileNotification.areNotificationsEnabled()
                        }
                    }
                    Button {
                        text: "open settings"
                        onClicked: {
                            // Open OS panel for this application notification settings
                            MobileNotification.openNotificationSettings()
                        }
                    }
                }

                ////

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Notifications:"
                    font.bold: true
                }

                ////

                Row { // post notifications
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8

                    Button {
                        text: "notify"
                        onClicked: {
                            appWindow.lastRequestId = ++appWindow.notifCounter
                            MobileNotification.notify("Hello", "Notification #" + appWindow.lastRequestId,
                                                         appWindow.channelDefault, appWindow.lastRequestId,
                                                         "default/" + appWindow.lastRequestId,
                                                         { color: 0xFF2196F3,
                                                           bigText: "This is a longer, expandable body demonstrating BigTextStyle. " +
                                                                 "Pull the notification down to see the full text of notification #" +
                                                                 appWindow.lastRequestId + "." })
                        }
                    }
                    Button {
                        text: "notify (high)"
                        onClicked: {
                            appWindow.lastRequestId = ++appWindow.notifCounter
                            MobileNotification.notify("Heads up!", "High-priority #" + appWindow.lastRequestId, appWindow.channelHigh,
                                                         appWindow.lastRequestId, "high/" + appWindow.lastRequestId,
                                                         { color: 0xFFF44336 })
                        }
                    }
                }

                Row { // update / cancel the last notification
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8

                    Button {
                        text: "update last"
                        enabled: appWindow.lastRequestId > 0
                        onClicked: {
                            MobileNotification.notify("Updated", "Notification #" + appWindow.lastRequestId + " (updated)",
                                                      appWindow.channelDefault, appWindow.lastRequestId)
                        }
                    }
                    Button {
                        text: "cancel last"
                        enabled: appWindow.lastRequestId > 0
                        onClicked: MobileNotification.cancel(appWindow.lastRequestId)
                    }
                    Button {
                        text: "cancel all"
                        onClicked: MobileNotification.cancelAll()
                    }
                }

                ////
            }

            ////////

            Column { // second column
                width: (appWindow.screenOrientation == Qt.PortraitOrientation)
                        ? appWindow.width : appWindow.width / 2

                spacing: 8

                ////

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "App icon badge:"
                    font.bold: true
                }

                ////

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8

                    Button {
                        text: "−"
                        onClicked: MobileNotification.setBadgeNumber(Math.max(0, MobileNotification.badgeNumber - 1))
                    }
                    Button {
                        text: "badge (%1)".arg(MobileNotification.badgeNumber)
                    }
                    Button {
                        text: "+"
                        onClicked: MobileNotification.setBadgeNumber(MobileNotification.badgeNumber + 1)
                    }
                    Button {
                        text: "clear"
                        onClicked: MobileNotification.clearBadge()
                    }
                }

                ////
            }

            ////////
        }

        ////////////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
