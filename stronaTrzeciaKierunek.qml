import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: item1
    anchors.fill: parent

    property string przystanek_wybrany_z_listy_API1
    property string przystanek_wybrany_z_listy_API2
    property string czy_uzytkownik_wprowadza_dwa_przystanki
    property string przechowanie_pierwszego_wyszukania_nazwa
    property string przechowanie_pierwszego_wyszukania_skrot
    property string czy_juz_tu_bylem
    property string pelna_nazwa_polaczenia_pierwszego
    property string przystanek_wprowadzony_przez_uzytkownika2

    width: 400
    height: 480

    Component.onCompleted: {
        if (przystanek_wybrany_z_listy_API2 == "") {
            wyszukiwanieKierunkowPoAPI(przystanek_wybrany_z_listy_API1)
        } else {
            if (czy_juz_tu_bylem == "") {
                wyszukiwanieKierunkowPoAPI(przystanek_wybrany_z_listy_API1)
                czy_juz_tu_bylem = "true"
            } else {
                wyszukiwanieKierunkowPoAPI(przystanek_wybrany_z_listy_API2)
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
            id: lista_znalezionych_kierunkow_z_API
        }
        delegate: Item {
            x: 5
            width: 80
            height: 40
            Row {
                id: row1

                Text {
                    text: nazwa_kierunku_zczytanego
                    anchors.verticalCenter: parent.verticalCenter
                    font.bold: true
                    MouseArea {
                        id: mousearea
                        anchors.fill: parent

                        onClicked: {

                            if (czy_uzytkownik_wprowadza_dwa_przystanki == "false") {
                                stackview.push(
                                            "ostatniaStronaCzasyPrzyjazdow.qml",
                                            {
                                                "skrot_kierunku_do_API": skrot_kierunku_do_API,
                                                "nazwa_kierunku_zczytanego": nazwa_kierunku_zczytanego,
                                                "czy_uzytkownik_wprowadza_dwa_przystanki": czy_uzytkownik_wprowadza_dwa_przystanki,
                                                "pelna_nazwa_polaczenia": przystanek_wybrany_z_listy_API1 + " " + nazwa_kierunku_zczytanego
                                            })
                            } else {
                                if (przechowanie_pierwszego_wyszukania_nazwa == "") {
                                    przechowanie_pierwszego_wyszukania_nazwa
                                            = nazwa_kierunku_zczytanego
                                    przechowanie_pierwszego_wyszukania_skrot = skrot_kierunku_do_API
                                    stackview.push("stronaDrugaPrzystanki.qml",
                                                   {
                                                       "przechowanie_pierwszego_wyszukania_skrot": skrot_kierunku_do_API,
                                                       "przechowanie_pierwszego_wyszukania_nazwa": nazwa_kierunku_zczytanego,
                                                       "czy_uzytkownik_wprowadza_dwa_przystanki": czy_uzytkownik_wprowadza_dwa_przystanki,
                                                       "pelna_nazwa_polaczenia_pierwszego": przystanek_wybrany_z_listy_API1 + " " + nazwa_kierunku_zczytanego,
                                                       "przystanek_wprowadzony_przez_uzytkownika2": przystanek_wprowadzony_przez_uzytkownika2,
                                                       "czy_juz_tu_bylem": czy_juz_tu_bylem
                                                   })
                                } else {
                                    stackview.push(
                                                "ostatniaStronaCzasyPrzyjazdow.qml",
                                                {
                                                    "skrot_kierunku_do_API": przechowanie_pierwszego_wyszukania_skrot,
                                                    "nazwa_kierunku_zczytanego": przechowanie_pierwszego_wyszukania_nazwa,
                                                    "skrot_kierunku_do_API2": skrot_kierunku_do_API,
                                                    "nazwa_kierunku_zczytanego2": nazwa_kierunku_zczytanego,
                                                    "czy_uzytkownik_wprowadza_dwa_przystanki": czy_uzytkownik_wprowadza_dwa_przystanki,
                                                    "pelna_nazwa_polaczenia": przystanek_wybrany_z_listy_API1 + " " + nazwa_kierunku_zczytanego,
                                                    "pelna_nazwa_polaczenia_pierwszego": pelna_nazwa_polaczenia_pierwszego
                                                })
                                }
                            }
                        }
                    }
                }
                spacing: 10
            }
        }
    }
    function wyszukiwanieKierunkowPoAPI(przystanek_z_listy_API) {

        //usuwanie czesci metody, ktora uniemozliwiala wyszukiwanie za pomoca API
        var kierunek_odczytany
        kierunek_odczytany = przystanek_z_listy_API
        kierunek_odczytany = kierunek_odczytany.replace(' n/ż', '%20n%2F%C5%BC')
        kierunek_odczytany = kierunek_odczytany.replace('/', '%2F')
        kierunek_odczytany = kierunek_odczytany.replace(' ', '%20')

        var url = "https://www.peka.poznan.pl/vm/method.vm?ts=1650399602423"

        var xhr = new XMLHttpRequest()

        xhr.open("POST", url)

        xhr.setRequestHeader("Accept-Language", "pl,en-US;q=0.7,en;q=0.3")
        xhr.setRequestHeader("Accept-Encoding", "gzip, deflate, br")
        xhr.setRequestHeader("Content-type",
                             "application/x-www-form-urlencoded; charset=UTF-8")

        xhr.setRequestHeader(
                    "Cookie",
                    "JSESSIONID=EFs7sTOqyZFexvlfUxFEapQw.undefined; rodopeka=1; cb-enabled=enabled")
        xhr.setRequestHeader("Sec-Fetch-Dest", "empty")
        xhr.setRequestHeader("Sec-Fetch-Mode", "cors")
        xhr.setRequestHeader("Sec-Fetch-Site", "same-origin")

        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {

                var json_string = xhr.responseText
                var json_object = JSON.parse(json_string)

                var shareInfoLen = Object.keys(
                            json_object.success.bollards).length

                for (var i = 0; i < shareInfoLen; i++) {

                    var shareInfoLen2 = Object.keys(
                                json_object.success.bollards[i].directions).length

                    for (var j = 0; j < shareInfoLen2; j++) {
                        lista_znalezionych_kierunkow_z_API.append({
                                                                      "skrot_kierunku_do_API": json_object.success.bollards[i].bollard.tag,
                                                                      "nazwa_kierunku_zczytanego": json_object.success.bollards[i].directions[j].direction + " linia: " + json_object.success.bollards[i].directions[j].lineName
                                                                  })
                    }
                }
            }
        }

        var data = "method=getBollardsByStopPoint&p0=%7B%22name%22%3A%22"
                + kierunek_odczytany + "%22%7D"
        xhr.send(data)
    }
}
