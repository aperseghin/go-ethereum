import QtQuick 2.0
import QtQuick.Controls 1.0;
import QtQuick.Layouts 1.0;
import QtQuick.Dialogs 1.0;
import QtQuick.Window 2.1;
import QtQuick.Controls.Styles 1.1
import Ethereum 1.0


ApplicationWindow {
	id: root

	width: 900
	height: 600
	minimumHeight: 300

	title: "Ethereal"

	MenuBar {
		Menu {
			title: "File"
			MenuItem {
				text: "Import App"
				shortcut: "Ctrl+o"
				onTriggered: openAppDialog.open()
			}
		}

		Menu {
			title: "Tools"
			MenuItem {
				text: "Muted"
				shortcut: "Ctrl+e"
				onTriggered: ui.muted("")
			}

			MenuItem {
				text: "Debugger"
				shortcut: "Ctrl+d"
				onTriggered: ui.startDebugger()
			}
		}

		Menu {
			title: "Network"
			MenuItem {
				text: "Add Peer"
				shortcut: "Ctrl+p"
				onTriggered: {
					addPeerWin.visible = true
				}
			}

			MenuItem {
				text: "Start"
				onTriggered: ui.connect()
			}
		}

		Menu {
			title: "Help"
			MenuItem {
				text: "About"
				onTriggered: {
					aboutWin.visible = true
				}
			}
		}

	}


	property var blockModel: ListModel {
		id: blockModel
	}

	function setView(view) {
		networkView.visible = false
		historyView.visible = false
		newTxView.visible = false
		infoView.visible = false
		view.visible = true
		//root.title = "Ethereal - " = view.title
	}

	SplitView {
		anchors.fill: parent
		resizing: false

		Rectangle {
			id: menu
			Layout.minimumWidth: 80
			Layout.maximumWidth: 80
			anchors.bottom: parent.bottom
			anchors.top: parent.top
			//color: "#D9DDE7"
			color: "#252525"

			ColumnLayout {
				y: 50
				anchors.left: parent.left
				anchors.right: parent.right
				height: 200
				Image {
					source: ui.assetPath("tx.png")
					anchors.horizontalCenter: parent.horizontalCenter
					MouseArea {
						anchors.fill: parent
						onClicked: {
							setView(historyView)
						}
					}
				}
				Image {
					source: ui.assetPath("new.png")
					anchors.horizontalCenter: parent.horizontalCenter
					MouseArea {
						anchors.fill: parent
						onClicked: {
							setView(newTxView)
						}
					}
				}
				Image {
					source: ui.assetPath("net.png")
					anchors.horizontalCenter: parent.horizontalCenter
					MouseArea {
						anchors.fill: parent
						onClicked: {
							setView(networkView)
						}
					}
				}

				Image {
					source: ui.assetPath("heart.png")
					anchors.horizontalCenter: parent.horizontalCenter
					MouseArea {
						anchors.fill: parent
						onClicked: {
							setView(infoView)
						}
					}
				}
			}
		}

		Rectangle {
			id: mainView
			color: "#00000000"
			anchors.right: parent.right
			anchors.left: menu.right
			anchors.bottom: parent.bottom
			anchors.top: parent.top

			property var txModel: ListModel {
				id: txModel
			}

			Rectangle {
				id: historyView
				anchors.fill: parent

				property var title: "Transactions"
				TableView {
					id: txTableView
					anchors.fill: parent
					TableViewColumn{ role: "inout" ; title: "" ; width: 40 }
					TableViewColumn{ role: "value" ; title: "Value" ; width: 100 }
					TableViewColumn{ role: "address" ; title: "Address" ; width: 430 }
					TableViewColumn{ role: "contract" ; title: "Contract" ; width: 100 }

					model: txModel
				}
			}

			Rectangle {
				id: newTxView
				property var title: "New transaction"
				visible: false
				anchors.fill: parent
				color: "#00000000"
				TabView{
					anchors.fill: parent
					anchors.rightMargin: 5
					anchors.leftMargin: 5
					anchors.topMargin: 5
					anchors.bottomMargin: 5
					id: newTransactionTab
					Component.onCompleted:{
						var component = Qt.createComponent("newTransaction/_simple_send.qml")
						var newTransaction = component.createObject("newTransaction")

						component = Qt.createComponent("newTransaction/_new_contract.qml")
						var newContract = component.createObject("newContract")

						addTab("Simple send", newTransaction)
						addTab("Contracts", newContract)
					}
				}
			}

			Rectangle {
				id: networkView
				property var title: "Network"
				visible: false
				anchors.fill: parent

				TableView {
					id: blockTable
					width: parent.width
					anchors.top: parent.top
					anchors.bottom: logView.top
					TableViewColumn{ role: "number" ; title: "#" ; width: 100 }
					TableViewColumn{ role: "hash" ; title: "Hash" ; width: 560 }
					TableViewColumn{ role: "txAmount" ; title: "Tx amount" ; width: 100 }

					model: blockModel

					onDoubleClicked: {
						popup.visible = true
						popup.setDetails(blockModel.get(row))
					}
				}

				property var logModel: ListModel {
					id: logModel
				}

				TableView {
					id: logView
					width: parent.width
					height: 150
					anchors.bottom: parent.bottom
					TableViewColumn{ role: "description" ; title: "log" }

					model: logModel
				}
			}

			Rectangle {
				id: infoView
				property var title: "Information"
				visible: false
				color: "#00000000"
				anchors.fill: parent

				Label {
					id: addressLabel
					text: "Address"
					anchors {
						margins: 5
						top: parent.top
						left: parent.left
					}
				}
				TextField {
					anchors {
						margins: 5
						left: addressLabel.right
						top: parent.top
					}
					text: pub.getKey().address
					width: 500
				}
			}

			/*
			 signal addPlugin(string name)
			 Component {
				 id: pluginWindow
				 Rectangle {
					 anchors.fill: parent
					 Label {
						 id: pluginTitle
						 anchors.centerIn: parent
						 text: "Hello world"
					 }
					 Component.onCompleted: setView(this)
				 }
			 }

			 onAddPlugin: {
				 var pluginWin = pluginWindow.createObject(mainView)
				 console.log(pluginWin)
				 pluginWin.pluginTitle.text = "Test"
			 }
			 */
		}
	}

	FileDialog {
		id: openAppDialog
		title: "Open QML Application"
		onAccepted: {
			//ui.open(openAppDialog.fileUrl.toString())
			//ui.openHtml(Qt.resolvedUrl(ui.assetPath("test.html")))
			ui.openHtml(openAppDialog.fileUrl.toString())
		}
	}

	statusBar: StatusBar {
		RowLayout {
			anchors.fill: parent

			Button {
				property var enabled: true
				id: debuggerWindow
				onClicked: {
					ui.startDebugger()
				}
				text: "Debugger"
			}

			Button {
				id: importAppButton
				anchors.left: debuggerWindow.right
				anchors.leftMargin: 5
				onClicked: openAppDialog.open()
				text: "Import App"
			}

			Label {
				anchors.left: importAppButton.right
				anchors.leftMargin: 5
				id: walletValueLabel
			}

			Label {
				anchors.right: peerImage.left
				anchors.rightMargin: 5
				id: peerLabel
				font.pixelSize: 8
				text: "0 / 0"
			}
			Image {
				id: peerImage
				anchors.right: parent.right
				width: 10; height: 10
				source: ui.assetPath("network.png")
			}
		}
	}

	Window {
		id: popup
		visible: false
		property var block
		width: 800
		height: 280
		x: root.x
		y: root.y + root.height
		Component{
			id: blockDetailsDelegate
			Rectangle {
				color: "#252525"
				width: popup.width
				height: 200
				Column {
					anchors.leftMargin: 10
					anchors.topMargin: 5
					anchors.top: parent.top
					anchors.left: parent.left
					Text { text: '<h3>Block details</h3>'; color: "#F2F2F2"}
					Text { text: '<b>Block number:</b> ' + number; color: "#F2F2F2"}
					Text { text: '<b>Hash:</b> ' + hash; color: "#F2F2F2"}
					Text { text: '<b>Block found at:</b> ' + prettyTime; color: "#F2F2F2"}
				}
			}
		}
		ListView {
			model: singleBlock
			delegate: blockDetailsDelegate
			anchors.top: parent.top
			height: 70
			anchors.leftMargin: 20
			id: listViewThing
			Layout.maximumHeight: 40
		}
		TableView {
			id: txView
			anchors.top: listViewThing.bottom
			anchors.topMargin: 50
			width: parent.width

			TableViewColumn{width: 90; role: "value" ; title: "Value" }
			TableViewColumn{width: 200; role: "hash" ; title: "Hash" }
			TableViewColumn{width: 200; role: "sender" ; title: "Sender" }
			TableViewColumn{width: 200;role: "address" ; title: "Receiver" }
			TableViewColumn{width: 60; role: "gas" ; title: "Gas" }
			TableViewColumn{width: 60; role: "gasPrice" ; title: "Gas Price" }
			TableViewColumn{width: 60; role: "isContract" ; title: "Contract" }

			model: transactionModel
			onClicked: {
				var tx = transactionModel.get(row)
				if(tx.data) {
					popup.showContractData(tx.data)
				}else{
					popup.height = 230
				}
			}
		}
		function showContractData(data) {
			contractData.text = data
			popup.height = 400
		}
		Rectangle {
			width: popup.width
			height: 300
			anchors.left: listViewThing.left
			anchors.top: txView.bottom
			Label {
				text: "<h4>Contract data</h4>"
				anchors.top: parent.top
				anchors.left: parent.left
				id: contractLabel
				anchors.leftMargin: 10
			}
			TextArea {
				id: contractData
				text: "Contract"
				anchors.top: contractLabel.bottom
				anchors.left: parent.left
				wrapMode: Text.Wrap
				width: parent.width - 30
				height: 80
				anchors.leftMargin: 10
			}
		}
		property var transactionModel: ListModel {
			id: transactionModel
		}
		property var singleBlock: ListModel {
			id: singleBlock
		}
		function setDetails(block){
			singleBlock.set(0,block)
			popup.height = 230
			transactionModel.clear()
			if(block.txs != undefined){
				for(var i = 0; i < block.txs.count; ++i) {
					transactionModel.insert(0, block.txs.get(i))
				}
				if(block.txs.get(0).data){
					popup.showContractData(block.txs.get(0).data)
				}
			}
			txView.forceActiveFocus()
		}
	}

	Window {
		id: addPeerWin
		visible: false
		minimumWidth: 230
		maximumWidth: 230
		maximumHeight: 50
		minimumHeight: 50

		TextField {
			id: addrField
			anchors.verticalCenter: parent.verticalCenter
			anchors.left: parent.left
			anchors.leftMargin: 10
			placeholderText: "address:port"
			onAccepted: {
				ui.connectToPeer(addrField.text)
				addPeerWin.visible = false
			}
		}
		Button {
			anchors.left: addrField.right
			anchors.verticalCenter: parent.verticalCenter
			anchors.leftMargin: 5
			text: "Add"
			onClicked: {
				ui.connectToPeer(addrField.text)
				addPeerWin.visible = false
			}
		}
		Component.onCompleted: {
			addrField.focus = true
		}
	}

	Window {
		id: aboutWin
		visible: false
		title: "About"
		minimumWidth: 350
		maximumWidth: 350
		maximumHeight: 200
		minimumHeight: 200

		Image {
			id: aboutIcon
			height: 150
			width: 150
			fillMode: Image.PreserveAspectFit
			smooth: true
			source: ui.assetPath("facet.png")
			x: 10
			y: 10
		}

		Text {
			anchors.left: aboutIcon.right
			anchors.leftMargin: 10
			font.pointSize: 12
			text: "<h2>Ethereal</h2><br><h3>Development</h3>Jeffrey Wilcke<br>Maran Hidskes<br>"
		}

	}

	ApplicationWindow {
		id: debugWindow
		visible: false
		title: "Debugger"
		minimumWidth: 600
		minimumHeight: 600
		width: 800
		height: 600


		Item {
			id: keyHandler
			focus: true
			Keys.onPressed: {
				if (event.key == Qt.Key_Space) {
					ui.next()
				}
			}
		}
		SplitView {
			anchors.fill: parent
			property var asmModel: ListModel {
				id: asmModel
			}
			TableView {
				id: asmTableView
				width: 200
				TableViewColumn{ role: "value" ; title: "" ; width: 100 }
				model: asmModel
			}

			Rectangle {
				anchors.left: asmTableView.right
				anchors.right: parent.right
				SplitView {
					orientation: Qt.Vertical
					anchors.fill: parent

					TableView {
						property var memModel: ListModel {
							id: memModel
						}
						height: parent.height/2
						width: parent.width
						TableViewColumn{ id:mnumColmn ; role: "num" ; title: "#" ; width: 50}
						TableViewColumn{ role: "value" ; title: "Memory" ; width: 750}
						model: memModel
					}

					SplitView {
						orientation: Qt.Horizontal
						id: debugSplitView
						TableView {
							property var debuggerLog: ListModel {
								id: debuggerLog
							}
							TableViewColumn{ role: "value"; title: "Debug messages" }
							model: debuggerLog
						}
						TableView {
							property var stackModel: ListModel {
								id: stackModel
							}
							height: parent.height/2
							width: parent.width
							TableViewColumn{ role: "value" ; title: "Stack" ; width: debugSplitView.width }
							model: stackModel
						}
					}
				}
			}
		}
		statusBar: StatusBar {
			RowLayout {
				anchors.fill: parent
				Button {
					property var enabled: true
					id: debugNextButton
					onClicked: {
						ui.next()
					}
					text: "Next"
				}
			}
		}
	}

	function setAsm(asm) {
		asmModel.append({asm: asm})
	}

	function setInstruction(num) {
		asmTableView.selection.clear()
		asmTableView.selection.select(num-1)
	}

	function clearAsm() {
		asmModel.clear()
	}

	function setMem(mem) {
		memModel.append({num: mem.num, value: mem.value})
	}
	function clearMem(){
		memModel.clear()
	}

	function setStack(stack) {
		stackModel.append({value: stack})
	}
	function addDebugMessage(message){
		console.log("WOOP:")
		debuggerLog.append({value: message})
	}

	function clearStack() {
		stackModel.clear()
	}

	function loadPlugin(name) {
		console.log("Loading plugin" + name)
		mainView.addPlugin(name)
	}

	function setWalletValue(value) {
		walletValueLabel.text = value
	}

	function addTx(tx, inout) {
		var isContract
		if (tx.contract == true){
			isContract = "Yes"
		}else{
			isContract = "No"
		}
		txModel.insert(0, {inout: inout, hash: tx.hash, address: tx.address, value: tx.value, contract: isContract})
	}

	function addBlock(block, initial) {
		var txs = JSON.parse(block.transactions);
		var amount = 0
		if(initial == undefined){
			initial = false
		}

		if(txs != null){
			amount = txs.length
		}

		if(initial){
			blockModel.append({number: block.number, hash: block.hash, txs: txs, txAmount: amount, time: block.time, prettyTime: convertToPretty(block.time)})
		}else{
			blockModel.insert(0, {number: block.number, hash: block.hash, txs: txs, txAmount: amount, time: block.time, prettyTime: convertToPretty(block.time)})
		}
	}

	function addLog(str) {
		if(str.len != 0) {
			logModel.append({description: str})
		}
	}

	function setPeers(text) {
		peerLabel.text = text
	}
	function convertToPretty(unixTs){
		var a = new Date(unixTs*1000);
		var months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
		var year = a.getFullYear();
		var month = months[a.getMonth()];
		var date = a.getDate();
		var hour = a.getHours();
		var min = a.getMinutes();
		var sec = a.getSeconds();
		var time = date+' '+month+' '+year+' '+hour+':'+min+':'+sec ;
		return time;
	}
}