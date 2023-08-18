import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.LocalStorage 2.0 as SQL

Item {
    id: item1
    anchors.fill: parent

    property string czy_uzytkownik_wprowadza_dwa_przystanki
    property var ilosc_elementow_listy

    width: 400
    height: 480

    Component.onCompleted: {
        checkboxKlik()
        wczytajzBazyDanych()
    }

    TextField {
        id: textField
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -158
        anchors.horizontalCenterOffset: 108
        anchors.horizontalCenter: parent.horizontalCenter
        placeholderText: qsTr("")
    }

    TextField {
        id: textField1
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -78
        anchors.horizontalCenterOffset: 108
        anchors.horizontalCenter: parent.horizontalCenter
        placeholderText: qsTr("")
    }

    Text {
        id: text1
        text: qsTr("Pierwszy przystanek")
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 14
        anchors.verticalCenterOffset: -157
        anchors.horizontalCenterOffset: -122
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Text {
        id: text2
        width: 110
        height: 23
        text: qsTr("Drugi przystanek")
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 14
        anchors.verticalCenterOffset: -77
        anchors.horizontalCenterOffset: -130
        anchors.horizontalCenter: parent.horizontalCenter
    }

    CheckBox {
        id: checkBox
        text: qsTr("Dwa przystanki")
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -117
        anchors.horizontalCenterOffset: -1
        anchors.horizontalCenter: parent.horizontalCenter
        onCheckedChanged: {
            checkboxKlik()
        }
    }

    ListView {
        id: listView
        width: 382
        height: 212
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 134
        anchors.horizontalCenterOffset: 1
        anchors.horizontalCenter: parent.horizontalCenter
        ScrollBar.vertical: ScrollBar {
            active: true
        }
        delegate: Item {
            x: 5
            width: parent.width
            height: 40
            Row {
                id: row1
                spacing: 10
                width: parent.width

                Text {
                    text: nazwa_kierunku_odczytanego
                    anchors.verticalCenter: parent.verticalCenter
                    font.bold: false
                    wrapMode: Text.WordWrap
                    width: parent.width

                    MouseArea {
                        id: mousearea
                        anchors.fill: parent

                        onClicked: {
                            var tak_zczytalem = "yes"
                            stackview.push("ostatniaStronaCzasyPrzyjazdow.qml",
                                           {
                                               "czy_zczytales_z_historii": tak_zczytalem,
                                               "nazwa_kierunku_zczytanego": nazwa_kierunku_odczytanego,
                                               "skrot_kierunku_do_API": skrot_kierunku_odczytanego
                                           })
                        }
                    }
                }
                Button {
                    id: button_usuwania_rekordu
                    text: qsTr("Usun")
                    anchors.right: parent.right
                    width: 50
                    onClicked: {
                        usunzBazyDanych(nazwa_kierunku_odczytanego,
                                        skrot_kierunku_odczytanego)
                        for (var i = ilosc_elementow_listy - 1; i >= 0; i--) {
                            lista_wczytanych_elementow.remove(i)
                        }

                        wczytajzBazyDanych()
                    }
                }
            }
        }
        model: ListModel {
            id: lista_wczytanych_elementow
        }
    }

    Text {
        id: text3
        text: qsTr("Aplikacja polaczen transportu miejskiego")
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 18
        font.bold: true
        anchors.verticalCenterOffset: -202
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Button {
        id: button
        text: qsTr("Wyszukaj")
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -19
        anchors.horizontalCenterOffset: -1
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: {
            if (checkBox.checked == false) {
                stackview.push("stronaDrugaPrzystanki.qml", {
                                   "przystanek_wprowadzony_przez_uzytkownika1": textField.text,
                                   "czy_uzytkownik_wprowadza_dwa_przystanki": czy_uzytkownik_wprowadza_dwa_przystanki
                               })
            } else {
                stackview.push("stronaDrugaPrzystanki.qml", {
                                   "przystanek_wprowadzony_przez_uzytkownika1": textField.text,
                                   "przystanek_wprowadzony_przez_uzytkownika2": textField1.text,
                                   "czy_uzytkownik_wprowadza_dwa_przystanki": czy_uzytkownik_wprowadza_dwa_przystanki
                               })
            }
        }
    }

    function checkboxKlik() {
        if (checkBox.checked == true) {
            textField1.visible = true
            text2.visible = true
            czy_uzytkownik_wprowadza_dwa_przystanki = "true"
        } else {
            textField1.visible = false
            text2.visible = false
            czy_uzytkownik_wprowadza_dwa_przystanki = "false"
        }
    }

    function wczytajzBazyDanych() {
        var db = SQL.LocalStorage.openDatabaseSync(
                    "mojaBaza", "1.0",
                    "Baza danych z pelnymi wyszukaniami uzytkownika", 1000000)

        db.transaction(function (tx) {

            var rs = tx.executeSql('SELECT * FROM ZapisanePolaczenia')

            var nazwa = ""
            var skrot = ""
            ilosc_elementow_listy = rs.rows.length
            for (var i = rs.rows.length - 1; i >= 0; i--) {
                nazwa = rs.rows.item(i).nazwaPrzystanku
                skrot = rs.rows.item(i).skrotKierunku

                lista_wczytanych_elementow.append({
                                                      "nazwa_kierunku_odczytanego": nazwa,
                                                      "skrot_kierunku_odczytanego": skrot
                                                  })
            }
        })
    }
    function usunzBazyDanych(nazwa_kierunku, skrot_kierunku) {
        console.log("skrot kierunku", skrot_kierunku)
        var db = SQL.LocalStorage.openDatabaseSync(
                    "mojaBaza", "1.0",
                    "Baza danych z pelnymi wyszukaniami uzytkownika", 1000000)

        db.transaction(function (tx) {
            tx.executeSql(
                        'DELETE FROM ZapisanePolaczenia WHERE nazwaPrzystanku ='
                        + '"' + nazwa_kierunku + '"' + ' AND skrotKierunku = '
                        + '"' + skrot_kierunku + '"')
        })
    }
}
