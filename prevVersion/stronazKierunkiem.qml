import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

Item {
    width: 360
    property string wybranyPrzystanek
    property string pierwszySzukanyPrzystanek
    property string pierwszaNazwaPrzystanku
    Component.onCompleted: {
        sprawdzKierunek()
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
        text: qsTr("Kierunki dla wybranego przystanku:")
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
        anchors.verticalCenterOffset: 28
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        ScrollBar.vertical: ScrollBar {
            active: true
        }
        model: ListModel {
            id: idKierunkow
        }
        delegate: Item {
            x: 5
            width: 80
            height: 40
            Row {
                id: row1

                Text {
                    text: nazwa
                    anchors.verticalCenter: parent.verticalCenter
                    font.bold: false
                    MouseArea {
                        id: mousearea
                        anchors.fill: parent

                        onClicked: {
                            var wartosc = skrotKierunku
                            if (pierwszySzukanyPrzystanek !== "") {
                                console.log("WESZLO", pierwszySzukanyPrzystanek)
                                stackview.push("stronazOdjazdami.qml", {
                                                   "skrotwybranegoKierunku": wartosc,
                                                   "nazwaPrzystankuiKierunku": wybranyPrzystanek + ": " + nazwa,
                                                   "pierwszySzukanyPrzystanek": pierwszySzukanyPrzystanek,
                                                   "pierwszaNazwaPrzystanku": pierwszaNazwaPrzystanku
                                               })
                            } else {

                                //console.log(tekst)
                                stackview.push("stronazOdjazdami.qml", {
                                                   "skrotwybranegoKierunku": wartosc,
                                                   "nazwaPrzystankuiKierunku": wybranyPrzystanek + ": " + nazwa
                                               })
                            }
                        }
                    }
                }
                spacing: 10
            }
        }
    }
    function sprawdzKierunek() {
        var kierunekOdczytany
        kierunekOdczytany = wybranyPrzystanek
        kierunekOdczytany = kierunekOdczytany.replace(' n/ż', '%20n%2F%C5%BC')
        kierunekOdczytany = kierunekOdczytany.replace('/', '%2F')
        kierunekOdczytany = kierunekOdczytany.replace(' ', '%20')
        console.log(kierunekOdczytany)

        var url = "https://www.peka.poznan.pl/vm/method.vm?ts=1650399602423"

        var xhr = new XMLHttpRequest()

        xhr.open("POST", url)

        xhr.setRequestHeader(
                    "User-Agent",
                    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:99.0) Gecko/20100101 Firefox/99.0")
        xhr.setRequestHeader(
                    "Accept",
                    "text/javascript, text/html, application/xml, text/xml, */*")
        xhr.setRequestHeader("Accept-Language", "pl,en-US;q=0.7,en;q=0.3")
        xhr.setRequestHeader("Accept-Encoding", "gzip, deflate, br")
        xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest")
        xhr.setRequestHeader("X-Prototype-Version", "1.7")
        xhr.setRequestHeader("Content-type",
                             "application/x-www-form-urlencoded; charset=UTF-8")
        xhr.setRequestHeader("Origin", "https://www.peka.poznan.pl")
        xhr.setRequestHeader("Connection", "keep-alive")
        xhr.setRequestHeader("Referer", "https://www.peka.poznan.pl/vm/")
        xhr.setRequestHeader(
                    "Cookie",
                    "JSESSIONID=EFs7sTOqyZFexvlfUxFEapQw.undefined; rodopeka=1; cb-enabled=enabled")
        xhr.setRequestHeader("Sec-Fetch-Dest", "empty")
        xhr.setRequestHeader("Sec-Fetch-Mode", "cors")
        xhr.setRequestHeader("Sec-Fetch-Site", "same-origin")

        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {
                console.log(xhr.status)
                console.log(xhr.responseText)

                var jsonString = xhr.responseText
                console.log(jsonString)
                var jsonObject = JSON.parse(jsonString)
                console.log("TEST", jsonObject.success.bollards[0].bollard.tag)

                var shareInfoLen = Object.keys(
                            jsonObject.success.bollards).length
                console.log("LICZBA PRZYSTANKOW: ", shareInfoLen)

                for (var i = 0; i < shareInfoLen; i++) {

                    var shareInfoLen2 = Object.keys(
                                jsonObject.success.bollards[i].directions).length
                    console.log("DLUGOSC", shareInfoLen2)
                    for (var j = 0; j < shareInfoLen2; j++) {
                        idKierunkow.append({
                                               "skrotKierunku": jsonObject.success.bollards[i].bollard.tag,
                                               "nazwa": jsonObject.success.bollards[i].directions[j].direction + " linia: " + jsonObject.success.bollards[i].directions[j].lineName
                                           })
                        console.log("Kierunek", idKierunkow.get(j).nazwa)

                        // kierunekLista.get(
                        //          i).dokad = jsonObject.success.bollards[i].bollard.tag
                        //console.log(kierunekLista.get(i).dokad)
                        //kolumna.get(i).symbolSkrotu = jsonObject.success[i].symbol
                    }
                }
            }
            //console.log(kierunekOdczytany)
        }
        //var data = "method=getBollardsByStopPoint&p0=%7B%22name%22%3A%22Most%20Dworcowy%22%7D"
        var data = "method=getBollardsByStopPoint&p0=%7B%22name%22%3A%22"
                + kierunekOdczytany + "%22%7D"
        xhr.send(data)
    }
}
