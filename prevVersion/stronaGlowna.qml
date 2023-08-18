import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.LocalStorage 2.0 as SQLs

Item {
    width: 360
    id: item1
    property var liczbaElementowBazy
    property string pierwszySzukanyPrzystanek
    property string pierwszaNazwaPrzystanku
    Component.onCompleted: {
        odczytajzBazy()
    }

    Text {
        id: text1
        text: qsTr("Odjazdy przystankow MPK")
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 20
        anchors.verticalCenterOffset: -187
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        font.bold: true
    }

    TextField {
        id: textField
        width: 160
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -75
        anchors.horizontalCenterOffset: -1
        font.pointSize: 16
        anchors.horizontalCenter: parent.horizontalCenter
        placeholderText: qsTr("wprowadz")
        onAccepted: czyPrawidlowa()
        onTextChanged: textField.color = "black"
    }

    Button {
        id: button

        text: qsTr("Dalej")
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 25
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: czyPrawidlowa()
        Component.onCompleted: {
            czyPrawidlowa()
        }
    }

    ListView {
        id: listView
        width: 320
        height: 114
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 134
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        ScrollBar.vertical: ScrollBar {
            active: true
        }
        delegate: Item {
            x: 5
            width: 80
            height: 40
            Row {
                id: row1

                Text {
                    text: nazwaWyszukanegoPrzystanku
                    font.pixelSize: 12
                    anchors.verticalCenter: parent.verticalCenter
                    font.bold: false
                    MouseArea {
                        id: mousearea
                        anchors.fill: parent

                        onClicked: {

                            var wartosc = skroconyKierunek
                            var potwierdzenie = "yes"
                            //console.log(tekst)
                            stackview.push("stronazOdjazdami.qml", {
                                               "skrotwybranegoKierunku": wartosc,
                                               "wczytanezhistorii": potwierdzenie
                                           })
                        }
                    }
                }

                Button {
                    id: buttonListy
                    text: qsTr("Usun")
                    width: 50
                    onClicked: {
                        var db = SQLs.LocalStorage.openDatabaseSync(
                                    "database02", "1.0",
                                    "Baza danych do historii wyszukiwania",
                                    1000000)

                        db.transaction(function (tx) {
                            tx.executeSql(
                                        'DELETE FROM Zapisy WHERE nazwaPrzystanku ="'
                                        + nazwaWyszukanegoPrzystanku
                                        + '" AND skrotKierunku="' + skroconyKierunek + '"')
                        })
                        for (var i = liczbaElementowBazy - 1; i >= 0; i--) {
                            idListaWyszukany.remove(i)
                        }

                        odczytajzBazy()
                    }
                }
                spacing: 10
            }
        }
        model: ListModel {
            id: idListaWyszukany
        }
    }
    function czyPrawidlowa() {
        var tekst
        tekst = textField.text
        if (tekst.length >= 4) {
            console.log("Wartosc przekazanego przystanku TO:",
                        pierwszySzukanyPrzystanek)
            if (pierwszySzukanyPrzystanek !== "") {
                console.log("WESZLO", pierwszySzukanyPrzystanek)
                stackview.push("stronazPrzystankiem.qml", {
                                   "wprowadzonyPrzystanek": tekst,
                                   "pierwszySzukanyPrzystanek": pierwszySzukanyPrzystanek,
                                   "pierwszaNazwaPrzystanku": pierwszaNazwaPrzystanku
                               })
            } else {
                stackview.push("stronazPrzystankiem.qml", {
                                   "wprowadzonyPrzystanek": tekst
                               })
            }
        } else {
            textField.color = "red"
        }
    }
    function odczytajzBazy() {
        var db = SQLs.LocalStorage.openDatabaseSync(
                    "database02", "1.0",
                    "Baza danych do historii wyszukiwania", 1000000)

        db.transaction(function (tx) {

            // Create the database if it doesn't already exist
            //tx.executeSql(
            //          'CREATE TABLE IF NOT EXISTS Zapisy(nazwaPrzystanku TEXT, skrotKierunku TEXT)')

            // Add (another) greeting row
            // tx.executeSql('INSERT INTO Zapisy VALUES(?, ?)',
            //         [nazwaPrzystankuiKierunku, skrotwybranegoKierunku])

            // Show all added greetings
            var rs = tx.executeSql('SELECT * FROM Zapisy')

            var r = ""
            var skrot = ""
            var numerid
            liczbaElementowBazy = rs.rows.length
            console.log("dlugosc tablicy", rs.rows.length)
            for (var i = rs.rows.length - 1; i >= 0; i--) {
                r = rs.rows.item(i).nazwaPrzystanku
                skrot = rs.rows.item(i).skrotKierunku

                idListaWyszukany.append({
                                            "nazwaWyszukanegoPrzystanku": r,
                                            "skroconyKierunek": skrot
                                        })
            }
        })
    }
    function usunzBazy() {
        var db = SQLs.LocalStorage.openDatabaseSync(
                    "database02", "1.0",
                    "Baza danych do historii wyszukiwania", 1000000)

        db.transaction(function (tx) {
            tx.executeSql(
                        'DELETE FROM Zapisy WHERE nazwaPrzystanku ='
                        + idListaWyszukany.get.nazwaWyszukanegoPrzystanku
                        + ' AND skrotKierunku = ' + idListaWyszukany.get.skroconyKierunek)
        })
    }
}
