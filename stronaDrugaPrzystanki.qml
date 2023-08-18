import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: item1
    anchors.fill: parent

    property string przystanek_wprowadzony_przez_uzytkownika1
    property string przystanek_wprowadzony_przez_uzytkownika2
    property string czy_uzytkownik_wprowadza_dwa_przystanki
    property string przechowanie_pierwszego_wyszukania_nazwa
    property string przechowanie_pierwszego_wyszukania_skrot
    property string czy_juz_tu_bylem
    property string pelna_nazwa_polaczenia_pierwszego

    width: 400
    height: 480

    Component.onCompleted: {
        if (przystanek_wprowadzony_przez_uzytkownika2 == "") {
            wyszukiwaniePrzystankowPoAPI(
                        przystanek_wprowadzony_przez_uzytkownika1)
        } else {
            if (czy_juz_tu_bylem == "") {
                wyszukiwaniePrzystankowPoAPI(
                            przystanek_wprowadzony_przez_uzytkownika1)
                czy_juz_tu_bylem = "true"
            } else {

                wyszukiwaniePrzystankowPoAPI(
                            przystanek_wprowadzony_przez_uzytkownika2)
            }
        }
    }

    Text {
        id: text1
        width: 186
        height: 26
        text: qsTr("Znalezione przystanki")
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 18
        anchors.verticalCenterOffset: -219
        anchors.horizontalCenterOffset: 0
        font.bold: true
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Button {
        id: button
        text: qsTr("Cofnij")
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -219
        anchors.horizontalCenterOffset: -152
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: {
            stackview.pop()
        }
    }

    ListView {
        id: listView
        width: 384
        height: 400
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 32
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        ScrollBar.vertical: ScrollBar {
            active: true
        }
        model: ListModel {
            id: lista_znalezionych_przystankow_z_API
        }
        delegate: Item {
            x: 5
            width: 80
            height: 40
            Row {
                id: row1

                Text {
                    text: nazwa_przystanku_zczytanego
                    anchors.verticalCenter: parent.verticalCenter
                    font.bold: true
                    MouseArea {
                        id: mousearea
                        anchors.fill: parent

                        onClicked: {
                            if (przechowanie_pierwszego_wyszukania_nazwa == "") {
                                stackview.push("stronaTrzeciaKierunek.qml", {
                                                   "przystanek_wybrany_z_listy_API1": nazwa_przystanku_zczytanego,
                                                   "czy_uzytkownik_wprowadza_dwa_przystanki": czy_uzytkownik_wprowadza_dwa_przystanki,
                                                   "przystanek_wprowadzony_przez_uzytkownika2": przystanek_wprowadzony_przez_uzytkownika2,
                                                   "czy_juz_tu_bylem": czy_juz_tu_bylem
                                               })
                            } else {
                                stackview.push("stronaTrzeciaKierunek.qml", {
                                                   "przystanek_wybrany_z_listy_API1": nazwa_przystanku_zczytanego,
                                                   "przechowanie_pierwszego_wyszukania_nazwa": przechowanie_pierwszego_wyszukania_nazwa,
                                                   "przechowanie_pierwszego_wyszukania_skrot": przechowanie_pierwszego_wyszukania_skrot,
                                                   "czy_uzytkownik_wprowadza_dwa_przystanki": czy_uzytkownik_wprowadza_dwa_przystanki,
                                                   "pelna_nazwa_polaczenia_pierwszego": pelna_nazwa_polaczenia_pierwszego
                                               })
                            }
                        }
                    }
                }
                spacing: 10
            }
        }
    }
    function wyszukiwaniePrzystankowPoAPI(wprowadzona_wartosc_uzytkownika) {
        var url = "https://www.peka.poznan.pl/vm/method.vm?ts=1649843180931"

        var xhr = new XMLHttpRequest()

        xhr.open("POST", url)

        xhr.setRequestHeader("Accept-Language", "en-US,en;q=0.5")
        xhr.setRequestHeader("Accept-Encoding", "gzip, deflate, br")
        xhr.setRequestHeader("Content-type",
                             "application/x-www-form-urlencoded; charset=UTF-8")
        xhr.setRequestHeader("Referer", "https://www.peka.poznan.pl/vm/")
        xhr.setRequestHeader("Sec-Fetch-Dest", "empty")
        xhr.setRequestHeader("Sec-Fetch-Mode", "cors")
        xhr.setRequestHeader("Sec-Fetch-Site", "same-origin")

        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {

                var json_string = xhr.responseText
                var json_object = JSON.parse(json_string)
                var shareInfoLen = Object.keys(json_object.success).length

                for (var i = 0; i < shareInfoLen; i++) {
                    lista_znalezionych_przystankow_z_API.append({
                                                                    "nazwa_przystanku_zczytanego": json_object.success[i].name
                                                                })
                }
            }
        }

        var data = "method=getStopPoints&p0=%7B%22pattern%22%3A%22"
                + wprowadzona_wartosc_uzytkownika + "%22%7D"

        xhr.send(data)
    }
}
