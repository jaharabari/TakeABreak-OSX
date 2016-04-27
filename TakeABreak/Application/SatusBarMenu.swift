//
//  Created by Dariusz Rybicki on 27/04/16.
//  Copyright © 2016 EL Passion. All rights reserved.
//

import Cocoa

class StatusBarMenu: NSObject {
    weak var delegate: StatusBarMenuDelegate?
    private var statusItem: NSStatusItem
    private var activeTimeItem = NSMenuItem()
    private var idleTimeItem = NSMenuItem()
    private(set) var isMenuOpen = false
    
    init(statusBar: NSStatusBar) {
        statusItem = statusBar.statusItemWithLength(NSVariableStatusItemLength)
        statusItem.title = "Take A Break"
        super.init()
        createMenu()
    }
    
    private func createMenu() {
        statusItem.menu = NSMenu()
        statusItem.menu?.delegate = self
        statusItem.menu?.addItem(activeTimeItem)
        statusItem.menu?.addItem(idleTimeItem)
        statusItem.menu?.addItem(NSMenuItem.separatorItem())
        statusItem.menu?.addItem(NSMenuItem().then {
            $0.title = "Quit"
            $0.target = self
            $0.action = #selector(quitAction)
        })
        
        updateActiveTime()
        updateIdleTime()
    }
    
    var title: String? {
        get { return statusItem.title }
        set { statusItem.title = newValue }
    }
    
    var activeTime: String? {
        didSet { updateActiveTime() }
    }
    
    var idleTime: String? {
        didSet { updateIdleTime() }
    }
    
    private func updateActiveTime() {
        if let time = activeTime {
            activeTimeItem.title = "Active Time: \(time)"
        }
        else {
            activeTimeItem.title = "Active Time: N/A"
        }
    }
    
    private func updateIdleTime() {
        if let time = idleTime {
            idleTimeItem.title = "Idle Time: \(time)"
        }
        else {
            idleTimeItem.title = "Idle Time: N/A"
        }
    }
    
    @objc private func quitAction() {
        delegate?.statusBarMenuDidSelectQuit()
    }
}

protocol StatusBarMenuDelegate: class {
    func statusBarMenuDidSelectQuit()
    func statusBarMenuWillOpen()
}

extension StatusBarMenu: NSMenuDelegate {
    func menuWillOpen(menu: NSMenu) {
        isMenuOpen = true
        delegate?.statusBarMenuWillOpen()
    }
    
    func menuDidClose(menu: NSMenu) {
        isMenuOpen = false
    }
}
