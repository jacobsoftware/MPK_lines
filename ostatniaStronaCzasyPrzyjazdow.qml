import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.LocalStorage 2.0 as SQL

Item {
    id: item1
    anchors.fill: parent

    width: 400
    height: 480

    property string nazwa_kierunku_zczytanego
    property string skrot_kierunku_do_API
    property string nazwa_kierunku_zczytanego2
    property string skrot_kierunku_do_API2
    property string czy_zczytales_z_historii
    property string czy_uzytkownik_wprowadza_dwa_przystanki
    property var ilosc_elementow_listy
    property string pelna_nazwa_polaczenia
    property string pelna_nazwa_polaczenia_pierwszego

    Component.onCompleted: {
        ilosc_elementow_listy = 0
        if (czy_zczytales_z_historii != "") {
            text3.text = nazwa_kierunku_zczytanego
            wyszukiwaniePrzyjazdowPoAPI(skrot_kierunku_do_API)
        } else {
            if (nazwa_kierunku_zczytanego2 != "") {
                naglowekStrony()
                zapiszWyszukanieDoBazyDanych(pelna_nazwa_polaczenia_pierwszego,
                                             skrot_kierunku_do_API)
                zapiszWyszukanieDoBazyDanych(pelna_nazwa_polaczenia,
                                             skrot_kierunku_do_API2)
                wyszukiwaniePrzyjazdowPoAPI(skrot_kierunku_do_API)
                wyszukiwaniePrzyjazdowPoAPI(skrot_kierunku_do_API2)
            } else {
                naglowekStrony()
                zapiszWyszukanieDoBazyDanych(pelna_nazwa_polaczenia,
                                             skrot_kierunku_do_API)
                wyszukiwaniePrzyjazdowPoAPI(skrot_kierunku_do_API)
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {

            if (skrot_kierunku_do_API2 != "") {
                wyczyscListy()
                wyszukiwaniePrzyjazdowPoAPI(skrot_kierunku_do_API)
                wyszukiwaniePrzyjazdowPoAPI(skrot_kierunku_do_API2)
            } else {
                wyczyscListy()
                wyszukiwaniePrzyjazdowPoAPI(skrot_kierunku_do_API)
            }
        }
    }

    Button {
        id: button
        text: qsTr("Menu")
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -219
        anchors.horizontalCenterOffset: -152
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: {
            stackview.pop(null)
        }
    }

    ListView {
        id: listView
        width: 132
        height: 304
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 80
        anchors.horizontalCenterOffset: -125
        anchors.horizontalCenter: parent.horizontalCenter
        delegate: Item {
            x: 5
            width: 80
            height: 40
            Row {
                id: row1
                spacing: 10

                Text {
                    text: czas_i_numer_do_wyswietlenia
                    anchors.verticalCenter: parent.verticalCenter
                    font.bold: false
                }
            }
        }
        model: ListModel {
            id: lista_do_wyswietlenia_przyjazdow
        }
        ScrollBar.vertical: ScrollBar {
            active: true
        }
    }
    ListModel {
        id: lista_do_przetwarzania_danych
    }

    Text {
        id: text1
        text: qsTr("Linia")
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 14
        anchors.verticalCenterOffset: -116
        anchors.horizontalCenterOffset: -177
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Text {
        id: text2
        text: qsTr("Za ile")
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 14
        anchors.verticalCenterOffset: -116
        anchors.horizontalCenterOffset: -125
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Text {
        id: text3
        text: qsTr("")
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 18
        anchors.verticalCenterOffset: -190
        anchors.horizontalCenterOffset: 1
        anchors.horizontalCenter: parent.horizontalCenter
        font.bold: true
    }

    function wyczyscListy() {
        if (nazwa_kierunku_zczytanego2 !== "") {

            for (var a = ilosc_elementow_listy - 1; a >= 0; a--) {
                lista_do_wyswietlenia_przyjazdow.remove(a)
                lista_do_przetwarzania_danych.remove(a)
            }
            ilosc_elementow_listy = 0
        } else {

            for (var b = ilosc_elementow_listy - 1; b >= 0; b--) {
                lista_do_wyswietlenia_przyjazdow.remove(b)
            }
            ilosc_elementow_listy = 0
        }
    }
    function zapiszWyszukanieDoBazyDanych(zapisana_nazwa_kierunku, zapisany_skrot_kierunku) {
        var db = SQL.LocalStorage.openDatabaseSync(
                    "mojaBaza", "1.0",
                    "Baza danych z pelnymi wyszukaniami uzytkownika", 1000000)

        db.transaction(function (tx) {

            tx.executeSql(
                        'CREATE TABLE IF NOT EXISTS ZapisanePolaczenia(Personid int IDENTITY(1,1) PRIMARY KEY, nazwaPrzystanku TEXT, skrotKierunku TEXT)')

            tx.executeSql(
                        'INSERT INTO ZapisanePolaczenia (nazwaPrzystanku, skrotKierunku) VALUES("'
                        + zapisana_nazwa_kierunku + '","' + zapisany_skrot_kierunku + '")')
        })
    }
    function wyszukiwaniePrzyjazdowPoAPI(skrot_kierunku_potrzebny_do_API) {

        var url = "https://www.peka.poznan.pl/vm/method.vm?ts=1656012026542"

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
                var shareInfoLen = Object.keys(json_object.success.times).length

                if (nazwa_kierunku_zczytanego2 == "") {

                    ilosc_elementow_listy = ilosc_elementow_listy + shareInfoLen

                    for (var i = 0; i < shareInfoLen; i++) {
                        lista_do_wyswietlenia_przyjazdow.append({
                                                                    "czas_i_numer_do_wyswietlenia": json_object.success.times[i].line + "     " + json_object.success.times[i].minutes + " min"
                                                                })
                    }
                } else {
                    if (ilosc_elementow_listy != 0) {

                        for (var l = 0; l < shareInfoLen; l++) {
                            lista_do_przetwarzania_danych.append({
                                                                     "czas_i_numer_do_wyswietlenia2": json_object.success.times[l].line + "     " + json_object.success.times[l].minutes + " min",
                                                                     "czas": json_object.success.times[l].minutes
                                                                 })
                        }
                        ilosc_elementow_listy = ilosc_elementow_listy + shareInfoLen

                        for (var z = 0; z < ilosc_elementow_listy; z++) {
                            for (var x = 1; x < ilosc_elementow_listy - z; x++) {
                                if (lista_do_przetwarzania_danych.get(
                                            x - 1).czas > lista_do_przetwarzania_danych.get(
                                            x).czas) {

                                    var zmienna_przechowujaca_tymczasowa_czas = lista_do_przetwarzania_danych.get(
                                                x).czas
                                    var zmienna_przechowujaca_wartosc_do_wyswietlenia = lista_do_przetwarzania_danych.get(
                                                x).czas_i_numer_do_wyswietlenia2

                                    lista_do_przetwarzania_danych.get(
                                                x).czas = lista_do_przetwarzania_danych.get(
                                                x - 1).czas
                                    lista_do_przetwarzania_danych.get(
                                                x - 1).czas = zmienna_przechowujaca_tymczasowa_czas

                                    lista_do_przetwarzania_danych.get(
                                                x).czas_i_numer_do_wyswietlenia2
                                            = lista_do_przetwarzania_danych.get(
                                                x - 1).czas_i_numer_do_wyswietlenia2
                                    lista_do_przetwarzania_danych.get(
                                                x - 1).czas_i_numer_do_wyswietlenia2
                                            = zmienna_przechowujaca_wartosc_do_wyswietlenia
                                }
                            }
                        }

                        for (var i = 0; i < ilosc_elementow_listy; i++) {
                            lista_do_wyswietlenia_przyjazdow.append({
                                                                        "czas_i_numer_do_wyswietlenia": lista_do_przetwarzania_danych.get(i).czas_i_numer_do_wyswietlenia2
                                                                    })
                        }
                    } else {

                        ilosc_elementow_listy = ilosc_elementow_listy + shareInfoLen

                        for (var k = 0; k < shareInfoLen; k++) {
                            lista_do_przetwarzania_danych.append({
                                                                     "czas_i_numer_do_wyswietlenia2": json_object.success.times[k].line + "     " + json_object.success.times[k].minutes + " min",
                                                                     "czas": json_object.success.times[k].minutes
                                                                 })
                        }
                    }
                }
            }
        }
        var data = "method=getTimes&p0=%7B%22symbol%22%3A%22"
                + skrot_kierunku_potrzebny_do_API + "%22%7D"
        xhr.send(data)
    }
    function naglowekStrony() {
        if (nazwa_kierunku_zczytanego2 == "") {
            text3.text = pelna_nazwa_polaczenia
        } else {
            text3.font.pixelSize = 12
            text3.text = pelna_nazwa_polaczenia_pierwszego + "\n" + pelna_nazwa_polaczenia
        }
    }
}
