/*
 * SPDX-License-Identifier: GPL-3.0-only
 * MuseScore-CLA-applies
 *
 * MuseScore
 * Music Composition & Notation
 *
 * Copyright (C) 2021 MuseScore BVBA and others
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import MuseScore.Ui 1.0
import MuseScore.UiComponents 1.0
import MuseScore.InstrumentsScene 1.0

Item {
    id: root

    property var instrumentsModel
    property alias navigation: navPanel

    signal addSelectedInstrumentsToScoreRequested()

    function clearSearch() {
        searchField.clear()
    }

    function focusInstrument(instrumentIndex) {
        instrumentsView.positionViewAtIndex(instrumentIndex, ListView.Beginning)
    }

    QtObject {
        id: prv

        property var currentItemNavigationIndex: []
    }

    NavigationPanel {
        id: navPanel
        name: "InstrumentsView"
        direction: NavigationPanel.Vertical
        enabled: root.enabled && root.visible

        onNavigationEvent: {
            if (event.type === NavigationEvent.AboutActive) {
                event.setData("controlIndex", prv.currentItemNavigationIndex)
                //! NOTE If we changed family, then control with saved index may not be
                event.setData("controlOptional", true)
            }
        }
    }

    StyledTextLabel {
        id: instrumentsLabel

        anchors.top: parent.top
        anchors.left: parent.left

        font: ui.theme.bodyBoldFont
        text: qsTrc("instruments", "Instruments")
    }

    SearchField {
        id: searchField

        anchors.top: instrumentsLabel.bottom
        anchors.topMargin: 16
        anchors.left: parent.left
        anchors.right: parent.right

        navigation.name: "SearchInstruments"
        navigation.panel: navPanel
        navigation.row: 1

        onFocusChanged: {
            if (activeFocus) {
                prv.currentItemNavigationIndex = [navigation.row, navigation.column]
            }
        }

        onSearchTextChanged: {
            root.instrumentsModel.setSearchText(searchText)
        }
    }

    ListView {
        id: instrumentsView

        anchors.top: searchField.bottom
        anchors.topMargin: 8
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        boundsBehavior: ListView.StopAtBounds
        clip: true

        ScrollBar.vertical: StyledScrollBar {}

        model: root.instrumentsModel

        delegate: ListItemBlank {
            id: item

            navigation.name: model.name
            navigation.panel: navPanel
            navigation.row: 2 + model.index
            navigation.accessible.name: itemTitleLabel.text

            onNavigationActived: {
                prv.currentItemNavigationIndex = [navigation.row, navigation.column]
                root.instrumentsModel.selectInstrument(model.index)
            }

            onNavigationTriggered: {
                root.addSelectedInstrumentsToScoreRequested()
            }

            isSelected: model.isSelected

            StyledTextLabel {
                id: itemTitleLabel
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.right: traitsBox.visible ? traitsBox.left : parent.right
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter

                horizontalAlignment: Text.AlignLeft
                text: model.name
                font: ui.theme.bodyBoldFont
            }

            onClicked: {
                root.instrumentsModel.selectInstrument(model.index)
            }

            onDoubleClicked: {
                root.addSelectedInstrumentsToScoreRequested()
            }

            property var itemModel: model

            Dropdown {
                id: traitsBox

                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter

                width: 86
                height: 24

                label.anchors.leftMargin: 8
                dropIcon.anchors.rightMargin: 4

                visible: traitsBox.count > 1

                model: item.itemModel.traits
                currentIndex: item.itemModel.currentTraitIndex

                onActivated: {
                    item.itemModel.currentTraitIndex = currentIndex
                }
            }
        }
    }
}
