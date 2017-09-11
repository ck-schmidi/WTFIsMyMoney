/* Page_new.qml -- New Entry page
 * Page to add new entries into the storage
 *
 * Copyright (C) 2017 Paul Goetzinger <paul70079@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0
 * License-Filename: LICENSE/GPL-3.0.txt
 *
 * This file is part of WTFIsMyMoney.
 *
 * WTFIsMyMoney is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * WTFIsMyMoney is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with WTFIsMyMoney.  If not, see <http://www.gnu.org/licenses/>.
 */


import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.LocalStorage 2.0
import QtQuick.Controls.Material 2.2

import "database.js" as Db

Page {
    title: "Neu"
    id: page
    objectName: "create_new"

    property var categories: []
    property var main_category;
    property var sub_category;
    property bool newEntry: true
    property date datum;
    property real money;
    property int nr;

    function reset() {
        main_category = ""
        sub_category = ""
        categories = []
        var tmp = Db.getCategories();
        for (var i in tmp) {
            categories.push({
                name: tmp[i].name,
                icon: tmp[i].icon,
                sub: Db.getSubcategoriesOrderedPerUse(tmp[i].name)
            });
        }
        money = 0.0
        newEntry = true;
        datum = new Date()
        mainList.model = categories
        moneyLayout.opened = true
        mainLayout.opened = false
        subLayout.opened = false
        dateLayout.opened = false
    }

    function load(item) {
        if (!item) {
            return
        }

        view_new_swipe.setCurrentIndex(0)
        main_category = item.category
        sub_category = item.subcategory
        categories = []
        var tmp = Db.getCategories();
        for (var i in tmp) {
            categories.push({
                name: tmp[i],
                sub: Db.getSubcategories(tmp[i])
            });
        }
        page_main.categories = categories
        main_category = item.category
        sub_category = item.subcategory
        for (var i in categories) {
            if (categories[i].name === main_category) {
                page_sub.model = categories[i].sub
            }
        }
        page_sub.setText(sub_category)
        page_content.datum = item.datestamp;
        page_content.money = item.money
        nr = item.nr
        newEntry = false
    }

    function cancel() {
        if (main_category && mainLayout.opened) {
            mainLayout.opened = false
        } else if(sub_category && subLayout.opened) {
            subLayout.opened = false
        } else if (datePicker.visible) {
            datePicker.close()
        } else {
            dialog.open()
        }
    }

    Icon {
        id: icon
    }

    Rectangle {
        id: bar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 56

        AbstractButton {
            id: buttonBack
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 16
            implicitWidth: height

            Text {
                anchors.fill: parent
                font.family: icon.family
                text: icon.icons.arrow_left
                color: "white"
                font.pointSize: 32
                fontSizeMode: Text.VerticalFit
            }

            onClicked: dialog.open()
        }

        Text {
            text: page.title
            anchors.left: parent.left
            anchors.leftMargin: 72
            anchors.baseline: parent.bottom
            anchors.baselineOffset: -20
            font.pixelSize: 20
            color: "white"
        }

        color: Material.primary
    }


    ColumnLayout {
        anchors.top: bar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 16
        spacing: 20

        ColumnLayout {
            id: moneyLayout
            property bool opened: false



            Label {
                id: moneyLabel
                text: "Geld:"
            }

            Button {
                id: moneyChip
                implicitHeight: 32
                visible: (!moneyLayout.opened) && moneyLayout.enabled

                onClicked: {
                    moneyLayout.opened = true
                    mainLayout.opened = false
                    subLayout.opened = false
                }

                contentItem: RowLayout {
                    spacing: 0
                    anchors.fill: parent


                    Rectangle {
                        height: parent.height
                        width: height
                        radius: height/2
                        anchors.verticalCenter: parent.verticalCenter
                        color: Material.accent

                        Text {
                            anchors.centerIn: parent
                            font.family: icon.family
                            color: "white"
                            font.pointSize: 13
                            text: money ? icon.icons.currency_eur : ""
                        }
                    }

                    Text {
                        padding: 8
                        rightPadding: 12
                        font.pointSize: 13
                        anchors.verticalCenter: parent.verticalCenter

                        text: money ? money.toFixed(2).replace(".",",") + " €" : ""
                    }
                }

                background: Rectangle {
                    anchors.fill: parent
                    radius: height/2
                    color: Material.color(Material.Grey, Material.Shade200)
                }
            }


            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: moneyLayout.opened

                Dial {
                    id: dial
                    from: 0
                    to: 30
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 50
                    value: money
                    snapMode: Dial.SnapAlways
                    stepSize: 0.5

                    onValueChanged: {
                        if (pressed) {
                            money = value
                        }
                    }
                }


                TextField {
                    focus: false
                    anchors.top: parent.top
                    anchors.left: parent.left
                    width: 60
                    text: focus ? money.toFixed(2).replace('.', ',') : money.toFixed(2).replace('.', ',') + " €"
                    validator: DoubleValidator{bottom: 0.0; decimals: 2}
                    onTextEdited: money = parseFloat(text.replace(',', '.'));
                    onEditingFinished: focus = false
                    inputMethodHints: Qt.ImhDigitsOnly
                }

                Button {
                    id: bt_plus
                    anchors.top: parent.top
                    anchors.right: parent.right
                    flat: true
                    text: "+5 €"

                    onClicked: money = money + 5
                }

                Button {
                    id: bt_minus
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    flat: true
                    text: "-5 €"

                    onClicked: money = money >= 5 ? money - 5 : 0
                }
            }
        }

        ColumnLayout {
            id: mainLayout
            Layout.fillWidth: true
            Layout.fillHeight: mainList.visible
            enabled: money > 0.0 ? true : false

            property bool opened: false;

            Label {
                id: mainLabel
                text: "Kategorie:"
            }

            Button {
                id: mainChip
                implicitHeight: 32
                visible: !mainLayout.opened

                onClicked: {
                    subLayout.opened = false
                    moneyLayout.opened = false
                    mainLayout.opened = true
                }

                contentItem: RowLayout {
                    spacing: 0
                    anchors.fill: parent

                    Item {
                        height: parent.height
                        width: height
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            font.family: icon.family
                            color: enabled ? "white" : "black"
                            font.pointSize: 13
                            text: main_category ? icon.icons[main_category.icon] : "?"
                            opacity: enabled ? 1 : 0.26
                            z: 1
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: height/2
                            color: Material.accent
                            opacity: enabled ? 1 : 0
                        }
                    }

                    Text {
                        padding: 8
                        rightPadding: 12
                        font.pointSize: 13
                        anchors.verticalCenter: parent.verticalCenter
                        opacity: enabled ? 1 : 0.26

                        text: main_category ? main_category.name : "Kategorie"
                    }
                }

                background: Rectangle {
                    anchors.fill: parent
                    radius: height/2
                    color: Material.color(Material.Grey, Material.Shade200)
                }
            }

            ListView {
                id: mainList
                visible: mainLayout.opened && mainLayout.enabled
                model: categories
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                delegate: AbstractButton {
                    implicitHeight: 56
                    width: mainList.width
                    onClicked: {
                        if ((!main_category) || (main_category.name !== modelData.name)) {
                            main_category = modelData
                            subLayout.opened = true
                        }
                        mainLayout.opened = false
                    }

                    Text {
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.margins: 8
                        anchors.leftMargin: 16
                        font.pixelSize: 32
                        fontSizeMode: Text.VerticalFit
                        font.family: icon.family
                        color: Material.accent
                        text: icon.icons[modelData.icon]
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        text: modelData.name
                        anchors.fill: parent
                        anchors.leftMargin: 72
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: 16
                    }
                }
            }

        }

        ColumnLayout {
            id: subLayout
            enabled: main_category ? !mainLayout.opened : false
            Layout.fillWidth: true
            Layout.fillHeight: subList.visible

            property bool opened;

            Label {
                id: subLabel
                text: "Unterkategorie:"
            }

            Button {
                id: subChip
                implicitHeight: 32
                visible: !subLayout.opened

                onClicked: {
                    mainLayout.opened = false
                    moneyLayout.opened = false
                    subLayout.opened = true
                }

                contentItem: RowLayout {
                    spacing: 0
                    anchors.fill: parent

                    Item {
                        height: parent.height
                        width: height
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            font.family: icon.family
                            color: enabled ? "white" : "black"
                            font.pointSize: 13
                            text: sub_category ? icon.icons[sub_category.icon] : "?"
                            opacity: enabled ? 1 : 0.26
                            z: 1
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: height/2
                            color: Material.accent
                            opacity: enabled ? 1 : 0
                        }
                    }

                    Text {
                        padding: 8
                        rightPadding: 12
                        font.pointSize: 13
                        anchors.verticalCenter: parent.verticalCenter
                        opacity: enabled ? 1 : 0.26

                        text: sub_category ? sub_category.name : "Unterkategorie"
                    }
                }

                background: Rectangle {
                    anchors.fill: parent
                    radius: height/2
                    color: Material.color(Material.Grey, Material.Shade200)
                }
            }

            ListView {
                id: subList
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: main_category ? main_category.sub : []
                visible: subLayout.opened
                clip: true

                delegate: AbstractButton {
                    implicitHeight: 56
                    width: subList.width
                    onClicked: {
                        if ((!sub_category) || (sub_category.name !== modelData.name)) {
                            sub_category = modelData
                        }
                        subLayout.opened = false
                    }

                    Text {
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.margins: 8
                        anchors.leftMargin: 16
                        font.pixelSize: 32
                        fontSizeMode: Text.VerticalFit
                        font.family: icon.family
                        color: Material.accent
                        text: icon.icons[modelData.icon]
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        text: modelData.name
                        anchors.fill: parent
                        anchors.leftMargin: 72
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: 16
                    }
                }

                footer: AbstractButton {
                    //TODO highlight element somehow
                    implicitHeight: 56
                    width: subList.width
                    onClicked: {
                        newSubIcon.iconName = "android"
                        newSubName.text = ""
                        dialogNewSub.open()
                    }

                    Text {
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.margins: 8
                        anchors.leftMargin: 16
                        font.pixelSize: 32
                        fontSizeMode: Text.VerticalFit
                        font.family: icon.family
                        color: Material.accent
                        text: icon.icons.plus
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        text: "Neu"
                        anchors.fill: parent
                        anchors.leftMargin: 72
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: 16
                    }

                    Dialog {
                        id: dialogNewSub
                        parent: page
                        title: "Neue Unterkategorie"
                        x: (page.width - width) / 2
                        y: (page.height - height) / 2

                        RowLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: 10

                            Button {
                                id: newSubIcon
                                flat: true
                                property string iconName: "android"
                                text: icon.icons[iconName]
                                font.family: icon.family
                                font.pointSize: 13
                                padding: 0
                                implicitWidth: 32
                                implicitHeight: 32
                                Layout.alignment: Qt.AlignVCenter

                                onClicked: {
                                    var model = [];
                                    for (var i in icon.icons) {
                                        model.push({name: i, icon: icon.icons[i]})
                                    }
                                    iconRepeater.model = model
                                    iconPicker.selected = iconName
                                    iconPicker.open()
                                }


                                contentItem: Text {
                                    anchors.fill: parent
                                    text: parent.text
                                    font: parent.font
                                    opacity: enabled || parent.highlighted || parent.checked ? 1 : 0.3
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }

                                background: Rectangle {
                                    anchors.fill: parent
                                    radius: width/2
                                    color: Material.accent
                                }

                                Dialog {
                                    id: iconPicker
                                    parent: page
                                    width: parent.width - 2 * margins
                                    height: parent.height - 2 * margins
                                    margins: 20
                                    x: (page.width - width) / 2
                                    y: (page.height - height) / 2

                                    property string selected: "android"

                                    standardButtons: Dialog.Ok | Dialog.Cancel

                                    ColumnLayout {
                                        anchors.fill: parent

                                        TextField {
                                            id: iconFilter
                                            Layout.fillWidth: true
                                            placeholderText: "Filter Icons"

                                            onTextChanged: {
                                                var model = [];
                                                for (var i in icon.icons) {
                                                    if (i.includes(text) || (text === "")) {
                                                        model.push({name: i, icon: icon.icons[i]})
                                                    }
                                                }
                                                iconRepeater.model = model
                                            }
                                        }

                                        GridView {
                                            id: iconRepeater
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            cellHeight: 32
                                            cellWidth: 32
                                            clip: true

                                            delegate: AbstractButton {
                                                property bool chosen: iconPicker.selected === modelData.name
                                                width: iconRepeater.cellWidth
                                                height: iconRepeater.cellWidth

                                                Label {
                                                    anchors.fill: parent
                                                    text: modelData ? modelData.icon : ""
                                                    font.family: icon.family
                                                    font.pointSize: 13
                                                    color: chosen ? Material.background : Material.accent
                                                    horizontalAlignment: Text.AlignHCenter
                                                    verticalAlignment: Text.AlignVCenter
                                                    elide: Text.ElideRight
                                                }

                                                Rectangle {
                                                    visible: chosen
                                                    anchors.fill: parent
                                                    radius: Math.max(width, height)
                                                    color: Material.accent
                                                    z: -1
                                                }

                                                onClicked: iconPicker.selected = modelData.name

                                            }

                                        }
                                    }

                                    onAccepted: newSubIcon.iconName = selected
                                }
                            }

                            TextField {
                                id: newSubName
                                ToolTip.text: "Name"
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        standardButtons: newSubName.text === "" ? Dialog.Cancel : Dialog.Ok | Dialog.Cancel

                        onAccepted: {
                            for (var i in categories) {
                                if (categories[i].name === main_category.name) {
                                    categories[i].sub.push({icon: newSubIcon.iconName, name: newSubName.text})
                                    main_category = categories[i]
                                }
                                if ((!sub_category) || (sub_category.name !== modelData.name)) {
                                    sub_category = modelData
                                }
                                subLayout.opened = false
                            }

                        }

                    }
                }
            }
        }

        ColumnLayout {
            id: dateLayout

            property bool opened;

            Label {
                id: dateLabel
                text: "Datum:"
            }

            Button {
                id: dateChip
                implicitHeight: 32

                onClicked: {
                    dateLayout.opened = true
                }

                contentItem: RowLayout {
                    spacing: 0
                    anchors.fill: parent


                    Rectangle {
                        height: parent.height
                        width: height
                        radius: height/2
                        anchors.verticalCenter: parent.verticalCenter
                        color: Material.accent

                        Text {
                            anchors.centerIn: parent
                            font.family: icon.family
                            color: "white"
                            font.pointSize: 13
                            text: icon.icons.calendar
                        }
                    }

                    Text {
                        padding: 8
                        rightPadding: 12
                        font.pointSize: 13
                        anchors.verticalCenter: parent.verticalCenter

                        text: Qt.locale().monthName(datum.getMonth(), Locale.ShortFormat) + ", " + datum.getDate() + " " + datum.getFullYear()
                    }
                }

                background: Rectangle {
                    anchors.fill: parent
                    radius: height/2
                    color: Material.color(Material.Grey, Material.Shade200)
                }
            }
            onOpenedChanged: {
                if (opened) {
                    datePicker.open()
                }
            }

            DatePicker{
                id: datePicker
                selectedDate: page.datum
                parent: page
                onClosed: {
                    dateLayout.opened = false
                    page.datum = selectedDate
                }
                x: (page.width - width) / 2
                y: (page.height - height) / 2
            }
        }

        Button {
            id: buttonDone
            text: "Fertig"
            Layout.alignment: Qt.AlignHCenter
            enabled: (money > 0.0) && (main_category ? true : false) && (sub_category ? true : false)
            flat: true

            onClicked: {
                Db.storeEntry(main_category.name, sub_category.name, datum, money, "", sub_category.icon)
                view_stack.pop()
            }
        }
    }

    Dialog {
        id: dialog
        title: "Abbrechen"
        parent: page
        standardButtons: Dialog.Ok | Dialog.Cancel

        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        onAccepted: view_stack.pop()
    }

    Component.onCompleted: {
        Db.init(LocalStorage)
    }
}