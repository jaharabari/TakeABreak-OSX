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
    private var totalTimeItem = NSMenuItem()
    fileprivate(set) var isMenuOpen = false
    var data = ActivityWatcher()
    
    
    init(statusBar: NSStatusBar) {
        statusItem = statusBar.statusItem(withLength: NSVariableStatusItemLength)
        statusItem.title = "Take A Break"
        super.init()
        createMenu()
    }
    
    private func createMenu() {
        statusItem.menu = NSMenu()
        statusItem.menu?.delegate = self
        statusItem.menu?.addItem(activeTimeItem)
        statusItem.menu?.addItem(idleTimeItem)
        statusItem.menu?.addItem(totalTimeItem)
        statusItem.menu?.addItem(NSMenuItem.separator())
        statusItem.menu?.addItem(NSMenuItem().then {
            $0.title = "Save Activity Log On Desktop"
            $0.target = self
            $0.action = #selector(saveLog)
            })
        statusItem.menu?.addItem(NSMenuItem.separator())
        statusItem.menu?.addItem(NSMenuItem().then {
            $0.title = "Relax"
            $0.target = self
            $0.action = #selector(sleepNow)
            })
        statusItem.menu?.addItem(NSMenuItem.separator())
        statusItem.menu?.addItem(NSMenuItem().then {
            $0.title = "Quit"
            $0.target = self
            $0.action = #selector(quitAction)
        })
        
        updateActiveTime()
        updateIdleTime()
        updateTotalTime()
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
    
    
    var totalTime: String? {
        didSet { updateTotalTime() }
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
    
    private func updateTotalTime() {
        if let time = totalTime {
            totalTimeItem.title = "Total Time: \(time)"
        }
        else {
            totalTimeItem.title = "Total Time: N/A"
        }
    }
    
    @objc private func quitAction() {
        delegate?.statusBarMenuDidSelectQuit()
    }
    
    @objc private func saveLog() {
        let stringFromArray = data.activityData.joined(separator: "\n")
        
        func getDocumentsDirectory() -> NSString {
            let paths = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true)
            let documentsDirectory = paths[0]
            return documentsDirectory as NSString
        }
        let path = getDocumentsDirectory().appendingPathComponent("ActivityLog.txt")
        let dataLog = stringFromArray
        do {
            try dataLog.write(toFile: path, atomically: false, encoding: String.Encoding.utf8)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    
    }
    @objc private func sleepNow() {
        let task = Process()
        task.launchPath = "/usr/bin/pmset"
        task.arguments = ["sleepnow"]
        task.launch()
    }
    
}

protocol StatusBarMenuDelegate: class {
    func statusBarMenuDidSelectQuit()
    func statusBarMenuWillOpen()
}

extension StatusBarMenu: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        isMenuOpen = true
        delegate?.statusBarMenuWillOpen()
    }
    
    func menuDidClose(_ menu: NSMenu) {
        isMenuOpen = false
    }
}
