import QtQuick
import QtQuick.Window
import QtQuick.Controls

Window {
    width: 400
    height: 480
    visible: true
    title: qsTr("Przystanki MPK")

    StackView {
        id: stackview
        anchors.fill: parent
        initialItem: "menuAplikacji.qml"
    }
}
