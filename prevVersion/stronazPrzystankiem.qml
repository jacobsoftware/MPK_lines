import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: item1
    width: 360
    property string wprowadzonyPrzystanek
    property string pierwszySzukanyPrzystanek
    property string pierwszaNazwaPrzystanku
    Component.onCompleted: {
        znajdzPrzystanki()
    }
    Rectangle {
        id: statusBar
        height: 50
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
        }

        color: Qt.rgba(0, 0, 0, 0)
        anchors.rightMargin: 0
        anchors.leftMargin: 0
        anchors.topMargin: 0

        RowLayout {
            id: buttonRow
            height: statusBar.height
            width: statusBar.width / 2
            spacing: 0
            anchors {
                left: statusBar.left
                top: statusBar.top
            }

            Button {
                id: backButton
                width: parent.width / 3
                text: qsTr("<")
                onClicked: stackview.pop()
            }
        }
    }
    Text {
        id: text1
        text: qsTr("Sugerowane przystanki:")
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 16
        font.bold: true
        anchors.verticalCenterOffset: -180
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
    }

    ListView {
        id: listView
        width: 320
        height: 326
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 14
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        ScrollBar.vertical: ScrollBar {
            active: true
        }
        model: ListModel {
            id: idPrzystankow
        }
        delegate: Item {
            x: 5
            width: 80
            height: 40
            Row {
                id: row1

                Text {
                    text: przystanek
                    anchors.verticalCenter: parent.verticalCenter
                    font.bold: false
                    MouseArea {
                        id: mousearea
                        anchors.fill: parent

                        onClicked: {
                            var wartosc = przystanek
                            if (pierwszySzukanyPrzystanek !== "") {
                                //console.log(tekst)
                                stackview.push("stronazKierunkiem.qml", {
                                                   "wybranyPrzystanek": wartosc,
                                                   "pierwszySzukanyPrzystanek": pierwszySzukanyPrzystanek,
                                                   "pierwszaNazwaPrzystanku": pierwszaNazwaPrzystanku
                                               })
                            } else {
                                //console.log(tekst)
                                stackview.push("stronazKierunkiem.qml", {
                                                   "wybranyPrzystanek": wartosc
                                               })
                            }
                        }
                    }
                }
                spacing: 10
            }
        }
    }
    function znajdzPrzystanki() {
        var url = "https://www.peka.poznan.pl/vm/method.vm?ts=1649843180931"

        var xhr = new XMLHttpRequest()

        xhr.open("POST", url)

        xhr.setRequestHeader(
                    "User-Agent",
                    "Mozilla/5.0 (X11; Linux x86_64; rv:98.0) Gecko/20100101 Firefox/98.0")
        xhr.setRequestHeader(
                    "Accept",
                    "text/javascript, text/html, application/xml, text/xml, */*")
        xhr.setRequestHeader("Accept-Language", "en-US,en;q=0.5")
        xhr.setRequestHeader("Accept-Encoding", "gzip, deflate, br")
        xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest")
        xhr.setRequestHeader("X-Prototype-Version", "1.7")
        xhr.setRequestHeader("Content-type",
                             "application/x-www-form-urlencoded; charset=UTF-8")
        xhr.setRequestHeader("Origin", "https://www.peka.poznan.pl")
        xhr.setRequestHeader("Connection", "keep-alive")
        xhr.setRequestHeader("Referer", "https://www.peka.poznan.pl/vm/")
        xhr.setRequestHeader("Cookie",
                             "JSESSIONID=I-5JtzdtbLmsVpmA9uB8FYT3.undefined")
        xhr.setRequestHeader("Sec-Fetch-Dest", "empty")
        xhr.setRequestHeader("Sec-Fetch-Mode", "cors")
        xhr.setRequestHeader("Sec-Fetch-Site", "same-origin")

        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {
                //console.log(xhr.status)
                //console.log(xhr.responseText)
                var jsonString = xhr.responseText
                //console.log(jsonString)
                var jsonObject = JSON.parse(jsonString)
                //console.log(jsonObject.success[0].name)
                var shareInfoLen = Object.keys(jsonObject.success).length
                for (var i = 0; i < shareInfoLen; i++) {
                    idPrzystankow.append({
                                             "przystanek": jsonObject.success[i].name
                                         })
                    //kolumna.get(i).tekst = jsonObject.success[i].name
                    //console.log(kolumna.get(i).tekst)
                    //kolumna.get(i).symbolSkrotu = jsonObject.success[i].symbol
                }
            }
        }

        var data = "method=getStopPoints&p0=%7B%22pattern%22%3A%22"
                + wprowadzonyPrzystanek + "%22%7D"

        xhr.send(data)
    }
}
