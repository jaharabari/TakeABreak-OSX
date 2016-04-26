//
//  Created by Dariusz Rybicki on 27/04/16.
//  Copyright © 2016 EL Passion. All rights reserved.
//

import Cocoa

class StatusBarMenu: NSObject {
    weak var delegate: StatusBarMenuDelegate?
    private var statusItem: NSStatusItem
    
    init(statusBar: NSStatusBar) {
        statusItem = statusBar.statusItemWithLength(NSVariableStatusItemLength)
        statusItem.title = "Take A Break"
        super.init()
        createMenu()
    }
    
    private func createMenu() {
        statusItem.menu = NSMenu()
        statusItem.menu?.addItem(NSMenuItem().then {
            $0.title = "Active Time"
        })
        statusItem.menu?.addItem(NSMenuItem().then {
            $0.title = "Idle Time"
        })
        statusItem.menu?.addItem(NSMenuItem.separatorItem())
        statusItem.menu?.addItem(NSMenuItem().then {
            $0.title = "Quit"
            $0.target = self
            $0.action = #selector(quitAction)
        })
    }
    
    var title: String? {
        get { return statusItem.title }
        set { statusItem.title = newValue }
    }
    
    @objc private func quitAction() {
        delegate?.statusBarMenuDidSelectQuit()
    }
}

protocol StatusBarMenuDelegate: class {
    func statusBarMenuDidSelectQuit()
}
