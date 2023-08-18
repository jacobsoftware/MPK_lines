import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.LocalStorage 2.0 as SQLs
import QtQml

Item {
    id: item1
    width: 360
    property string skrotwybranegoKierunku
    property string nazwaPrzystankuiKierunku
    property string wczytanezhistorii
    property var wielkoscListy
    property string pierwszySzukanyPrzystanek
    // property var tablicaDoSortowania
    property int wartoscTablicy
    property string pierwszaNazwaPrzystanku
    Component.onCompleted: {
        if (pierwszySzukanyPrzystanek !== "") {
            text1.text = nazwaPrzystankuiKierunku + "\n" + pierwszaNazwaPrzystanku
            text1.font.pixelSize = 12
            czyWidac()
            //tworzenieTablicy()
            sprawdzOdjazdyMultiple(skrotwybranegoKierunku)
            sprawdzOdjazdyMultiple(pierwszySzukanyPrzystanek)
            //posortujWyniki()
            //wprowadzanieDanychDwochPrzystankow()
        } else {
            pierwszaNazwaPrzystanku = nazwaPrzystankuiKierunku
            sprawdzOdjazdy(skrotwybranegoKierunku)
            if (wczytanezhistorii != "yes") {
                zapiszDoBazy()
            }
        }
    }
    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: {

            if (pierwszySzukanyPrzystanek !== "") {
                usunListe()
                sprawdzOdjazdyMultiple(skrotwybranegoKierunku)
                sprawdzOdjazdyMultiple(pierwszySzukanyPrzystanek)
                //posortujWyniki()
                //wprowadzanieDanychDwochPrzystankow()
            } else {
                usunListe()
                sprawdzOdjazdy(skrotwybranegoKierunku)
            }
        }
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
            Button {
                id: homeButton
                width: parent.width / 3
                text: qsTr("Home")
                onClicked: {
                    stackview.pop(null)

                    //stackview.push("stronaGlowna.qml")
                }
            }
            Button {
                id: addButton
                //width: parent.width / 3
                text: qsTr("Dodaj tablice")
                onClicked: stackview.push("stronaGlowna.qml", {
                                              "pierwszySzukanyPrzystanek": skrotwybranegoKierunku,
                                              "pierwszaNazwaPrzystanku": nazwaPrzystankuiKierunku
                                          })
            }
        }
    }
    Text {
        id: text1
        text: nazwaPrzystankuiKierunku
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
        anchors.verticalCenterOffset: 69
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter

        ScrollBar.vertical: ScrollBar {
            active: true
        }
        model: ListModel {
            id: idOdjazdow
        }
        delegate: Item {
            x: 5
            width: 80
            height: 40
            Row {
                id: row1

                Text {
                    text: wyswietl
                    anchors.verticalCenter: parent.verticalCenter
                    font.bold: false
                }
                spacing: 5
            }
        }
    }

    Text {
        id: text2
        text: qsTr("Numer linii")
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 14
        anchors.verticalCenterOffset: -137
        anchors.horizontalCenterOffset: -126
        anchors.horizontalCenter: parent.horizontalCenter
    }
    Text {
        id: text3
        text: qsTr("Czas przyjazdu")
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 14
        anchors.verticalCenterOffset: -137
        anchors.horizontalCenterOffset: 115
        anchors.horizontalCenter: parent.horizontalCenter
    }
    ListModel {
        id: tablicaDoSortowania
    }

    function sprawdzOdjazdy(skrotwybranegoKierunkuV1) {
        var url = "https://www.peka.poznan.pl/vm/method.vm?ts=1650049155184"

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
                    "JSESSIONID=PP8F80ToBWpYtUesvR3v0bfW.undefined; rodopeka=1; cb-enabled=enabled")
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
                console.log(jsonObject.success.times[1].line)
                console.log(jsonObject.success.times[1].minutes)
                var shareInfoLen = Object.keys(jsonObject.success.times).length
                console.log("\nUWAGA", shareInfoLen)

                wielkoscListy = shareInfoLen
                for (var i = 0; i < shareInfoLen; i++) {


                    /*
                    czas.get(i + 1).zaile = jsonObject.success.times[i].minutes
                    console.log(czas.get(i + 1).zaile)

                    autobus.get(i + 1).numer = jsonObject.success.times[i].line
                    console.log(autobus.get(i + 1).numer)
*/
                    console.log("JSON obiekt: ",
                                jsonObject.success.times[i].line)


                    /* idOdjazdow.append({
                                          "zaile": jsonObject.success.times[i].minutes,
                                          "numer": jsonObject.success.times[i].line,
                                          "wyswietl": jsonObject.success.times[i].line
                                          + "                                                                        "
                                          + jsonObject.success.times[i].minutes + " min."
                                      })*/
                    var numerLinii = jsonObject.success.times[i].line
                    console.log("Wartosc tablicy: ", i, " numer linii:",
                                jsonObject.success.times[i].line)
                    var dlugoscNumeru = numerLinii.length
                    console.log("Numer lnii ", numerLinii, " dlugosc wyrazu: ",
                                dlugoscNumeru)
                    switch (dlugoscNumeru) {
                    case 1:
                        idOdjazdow.append({
                                              "zaile": jsonObject.success.times[i].minutes,
                                              "numer": jsonObject.success.times[i].line,
                                              "wyswietl": jsonObject.success.times[i].line
                                              + "                                                                        "
                                              + jsonObject.success.times[i].minutes + " min."
                                          })
                        break
                    case 2:
                        idOdjazdow.append({
                                              "zaile": jsonObject.success.times[i].minutes,
                                              "numer": jsonObject.success.times[i].line,
                                              "wyswietl": jsonObject.success.times[i].line
                                              + "                                                                       "
                                              + jsonObject.success.times[i].minutes + " min."
                                          })
                        break
                    case 3:
                        idOdjazdow.append({
                                              "zaile": jsonObject.success.times[i].minutes,
                                              "numer": jsonObject.success.times[i].line,
                                              "wyswietl": jsonObject.success.times[i].line
                                              + "                                                                      "
                                              + jsonObject.success.times[i].minutes + " min."
                                          })
                        break
                    }
                }
            }
        }

        var data = "method=getTimes&p0=%7B%22symbol%22%3A%22" + skrotwybranegoKierunkuV1 + "%22%7D"

        xhr.send(data)
    }
    function zapiszDoBazy() {
        var db = SQLs.LocalStorage.openDatabaseSync(
                    "database02", "1.0",
                    "Baza danych do historii wyszukiwania", 1000000)

        db.transaction(function (tx) {
            // Create the database if it doesn't already exist
            tx.executeSql(
                        'CREATE TABLE IF NOT EXISTS Zapisy(Personid int IDENTITY(1,1) PRIMARY KEY, nazwaPrzystanku TEXT, skrotKierunku TEXT)')

            // Add (another) greeting row
            tx.executeSql(
                        'INSERT INTO Zapisy (nazwaPrzystanku, skrotKierunku) VALUES("'
                        + nazwaPrzystankuiKierunku + '","' + skrotwybranegoKierunku + '")')

            // Show all added greetings


            /*var rs = tx.executeSql('SELECT * FROM Zapisy')

            var r = ""
            for (var i = 0; i < rs.rows.length; i++) {
                r += rs.rows.item(i).name + ", " + rs.rows.item(i).type + "\n"
            }
            text = r*/
        })
    }
    function usunListe() {
        if (pierwszySzukanyPrzystanek !== "") {
            for (var m = wielkoscListy - 1; m >= 0; m--) {
                idOdjazdow.remove(m)
                tablicaDoSortowania.remove(m)
            }
            wartoscTablicy = 0
        } else {

            for (var z = wielkoscListy - 1; z >= 0; z--) {
                idOdjazdow.remove(z)
            }
        }
    }


    /* function tworzenieTablicy() {
        tablicaDoSortowania = Array.from(Array(2), () => new Array(4))
    }*/
    function sprawdzOdjazdyMultiple(skrotWprowadzonegoOdjazdu) {
        var url = "https://www.peka.poznan.pl/vm/method.vm?ts=1650049155184"

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
                    "JSESSIONID=PP8F80ToBWpYtUesvR3v0bfW.undefined; rodopeka=1; cb-enabled=enabled")
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
                //console.log(jsonObject.success.times[1].line)
                //console.log(jsonObject.success.times[1].minutes)
                var shareInfoLen = Object.keys(jsonObject.success.times).length

                //console.log("\nUWAGA", shareInfoLen)
                wielkoscListy = shareInfoLen
                console.log("LICZBA REKORDOW DLA PIERWSZEGO PRZYSTANKU: ",
                            shareInfoLen)
                console.log("WSZYSTKO DZIALA POPRAWNIE I WESZLA PETLA")
                if (wartoscTablicy != 0) {
                    for (var j = 0; j < shareInfoLen; j++) {
                        //tablicaDoSortowania[j][0] = jsonObject.success.times[j].line
                        //tablicaDoSortowania[j][1] = jsonObject.success.times[j].minutes
                        tablicaDoSortowania.append({
                                                       "linia": jsonObject.success.times[j].line,
                                                       "czas": jsonObject.success.times[j].minutes
                                                   })
                    }
                    wartoscTablicy += shareInfoLen
                    console.log("WIELKOSC TABLICY PO ZLACZENIU WYNOSI: ",
                                wartoscTablicy)
                    posortujWyniki()
                    wprowadzanieDanychDwochPrzystankow()
                } else {
                    for (var i = 0; i < shareInfoLen; i++) {
                        //tablicaDoSortowania[i][0] = jsonObject.success.times[i].line
                        //tablicaDoSortowania[i][1] = jsonObject.success.times[i].minutes
                        tablicaDoSortowania.append({
                                                       "linia": jsonObject.success.times[i].line,
                                                       "czas": jsonObject.success.times[i].minutes
                                                   })
                    }
                    console.log("PIERWSZA SZUKANA WARTOSC TO:",
                                pierwszySzukanyPrzystanek)
                    console.log("DRUGA SZUKANA WARTOSC TO:",
                                skrotwybranegoKierunku)
                    wartoscTablicy = shareInfoLen
                    console.log("WIELKOSC TABLICY PRZED ZLACZENIEM WYNOSI: ",
                                wartoscTablicy)
                }
            }
        }

        var data = "method=getTimes&p0=%7B%22symbol%22%3A%22" + skrotWprowadzonegoOdjazdu + "%22%7D"

        xhr.send(data)
    }

    function posortujWyniki() {
        console.log("SORTOWANIE ZOSTALO WLACZONE")
        for (var i = 0; i < wartoscTablicy; i++) {
            for (var j = 1; j < wartoscTablicy - i; j++) {
                if (tablicaDoSortowania.get(
                            j - 1).czas > tablicaDoSortowania.get(j).czas) {
                    var tymczasowaCzas = tablicaDoSortowania.get(j).czas
                    var tymczasowaLinia = tablicaDoSortowania.get(j).linia
                    tablicaDoSortowania.get(j).czas = tablicaDoSortowania.get(
                                j - 1).czas
                    tablicaDoSortowania.get(j - 1).czas = tymczasowaCzas
                    tablicaDoSortowania.get(j).linia = tablicaDoSortowania.get(
                                j - 1).linia
                    tablicaDoSortowania.get(j - 1).linia = tymczasowaLinia
                }
            }
        }
        for (var k = 0; k < wartoscTablicy; k++) {
            console.log("To jest WARTOSC dla dwoch tablic, numer linii: ",
                        tablicaDoSortowania.get(k).linia, " oraz za ile: ",
                        tablicaDoSortowania.get(k).czas)
        }
    }
    function wprowadzanieDanychDwochPrzystankow() {
        console.log("PRZYDZIELANIE ZOSTALO WLACZONE")
        wielkoscListy = wartoscTablicy
        for (var i = 0; i < wartoscTablicy; i++) {

            var numerLinii = tablicaDoSortowania.get(i).linia
            var dlugoscNumeru = numerLinii.length
            console.log("DLUGOSC CIAGU WYRAZU: ", dlugoscNumeru,
                        " DLA NUMERU: ", numerLinii)
            switch (dlugoscNumeru) {
            case 1:
                idOdjazdow.append({
                                      "zaile": tablicaDoSortowania.get(i).czas,
                                      "numer": tablicaDoSortowania.get(i).linia,
                                      "wyswietl": tablicaDoSortowania.get(
                                                      i).linia + "                                                                        " + tablicaDoSortowania.get(
                                                      i).czas + " min."
                                  })
                break
            case 2:
                idOdjazdow.append({
                                      "zaile": tablicaDoSortowania.get(i).czas,
                                      "numer": tablicaDoSortowania.get(i).linia,
                                      "wyswietl": tablicaDoSortowania.get(
                                                      i).linia + "                                                                       " + tablicaDoSortowania.get(
                                                      i).czas + " min."
                                  })
                break
            case 3:
                idOdjazdow.append({
                                      "zaile": tablicaDoSortowania.get(i).czas,
                                      "numer": tablicaDoSortowania.get(i).linia,
                                      "wyswietl": tablicaDoSortowania.get(
                                                      i).linia + "                                                                      " + tablicaDoSortowania.get(
                                                      i).czas + " min."
                                  })
                break
            }
        }
    }

    function czyWidac() {
        if (pierwszySzukanyPrzystanek !== "") {
            addButton.visible = false
        }
        wartoscTablicy = 0
    }
}
