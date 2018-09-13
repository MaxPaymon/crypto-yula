//
//  ViewController.swift
//  crypto-yula
//
//  Created by Maxim Skorynin on 11.09.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, NSComboBoxDelegate {

    @IBOutlet weak var segmentControl: NSSegmentedControl!
    @IBOutlet weak var topLine: NSView!
    @IBOutlet weak var bottomView: NSView!
    
    @IBOutlet weak var cmpPrice: NSTextField!
    @IBOutlet weak var bitfinexPrice: NSTextField!
    @IBOutlet weak var binancePrice: NSTextField!
    @IBOutlet weak var hitBtcPrice: NSTextField!
    @IBOutlet weak var huobiPrice: NSTextField!
    
    @IBOutlet weak var bitfinex1h: NSTextField!
    @IBOutlet weak var binance1h: NSTextField!
    @IBOutlet weak var hitBtc1h: NSTextField!
    @IBOutlet weak var huobi1h: NSTextField!
    @IBOutlet weak var cmp1h: NSTextField!
    
    @IBOutlet weak var bitfinex24h: NSTextField!
    @IBOutlet weak var binance24h: NSTextField!
    @IBOutlet weak var hitBtc24h: NSTextField!
    @IBOutlet weak var huobi24h: NSTextField!
    @IBOutlet weak var cmp24h: NSTextField!
    
    @IBOutlet weak var bitfinex7d: NSTextField!
    @IBOutlet weak var binance7d: NSTextField!
    @IBOutlet weak var hitBtc7d: NSTextField!
    @IBOutlet weak var huobi7d: NSTextField!
    @IBOutlet weak var cmp7d: NSTextField!
    
    private var cmp : NSObjectProtocol!
    private var binance : NSObjectProtocol!
    private var bitfinex : NSObjectProtocol!
    private var hitbtc : NSObjectProtocol!
    private var huobi : NSObjectProtocol!
    
    @IBOutlet weak var comboBox: NSComboBox!
    var timer : Timer!
    
    func addObservers() {
        cmp = NotificationCenter.default.addObserver(forName: .cmp, object: nil, queue: OperationQueue.main ){ notification in
            
            if let data = notification.object as? ParseData {
                
                DispatchQueue.main.async {
                    self.setValue(data: data, price: self.cmpPrice, h1: self.cmp1h, h24: self.cmp24h, d7: self.cmp7d)
                }
            }
        }
        
        binance = NotificationCenter.default.addObserver(forName: .binance, object: nil, queue: OperationQueue.main ){ notification in
            
            if let data = notification.object as? ParseData {
                
                DispatchQueue.main.async {
                    
                    self.setValue(data: data, price: self.binancePrice, h1: self.binance1h, h24: self.binance24h, d7: self.binance7d)
                }
            }
        }
        
        bitfinex = NotificationCenter.default.addObserver(forName: .bitfinex, object: nil, queue: OperationQueue.main ){ notification in
            
            if let data = notification.object as? ParseData {
                
                DispatchQueue.main.async {
                    
                    self.setValue(data: data, price: self.bitfinexPrice, h1: self.bitfinex1h, h24: self.bitfinex24h, d7: self.bitfinex7d)
                }
            }
        }
        
        hitbtc = NotificationCenter.default.addObserver(forName: .hitbtc, object: nil, queue: OperationQueue.main ){ notification in
            
            if let data = notification.object as? ParseData {
                
                DispatchQueue.main.async {
                    
                    self.setValue(data: data, price: self.hitBtcPrice, h1: self.hitBtc1h, h24: self.hitBtc24h, d7: self.hitBtc7d)
                }
            }
        }
        
        huobi = NotificationCenter.default.addObserver(forName: .huobi, object: nil, queue: OperationQueue.main ){ notification in
            
            if let data = notification.object as? ParseData {
                
                DispatchQueue.main.async {
                    
                    self.setValue(data: data, price: self.huobiPrice, h1: self.huobi1h, h24: self.huobi24h, d7: self.huobi7d)
                }
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addObservers()
        
        setOptionsLayout()
        Parse.getBtc()

        setTimer(interval: 5)
    }
    
    @IBAction func segmentClick(_ sender: Any) {
        switch segmentControl.selectedSegment {
        case 0:
            Parse.getBtc()
            break
        case 1:
            Parse.getEth()
            break

        default:
            print("default")
        }
    }
    
    @objc func timerAction() {
        print(timer.timeInterval)
        switch segmentControl.selectedSegment {
        case 0:
            Parse.getBtc()
            
            break
        case 1:
            Parse.getEth()
            break
            
        default:
            print("default")
        }
    }
    
    func setTimer(interval : Int) {
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(interval), target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
    }
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        timer.invalidate()
        switch comboBox.indexOfSelectedItem {
        case 0:
            setTimer(interval: 5)
        case 1:
            setTimer(interval: 10)
        case 2:
            setTimer(interval: 30)
        case 3:
            setTimer(interval: 60)
        case 4:
            setTimer(interval: 300)
        case 5:
            setTimer(interval: 1800)
        default:
            print("default")
        }
    }
    
    func setOptionsLayout() {
        topLine.wantsLayer = true
        topLine.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.1).cgColor
        
        bottomView.wantsLayer = true
        bottomView.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.1).cgColor
        
        segmentControl.setSelected(true, forSegment: 0)
        comboBox.delegate = self
    }
    
    func setValue(data : ParseData, price: NSTextField, h1: NSTextField, h24: NSTextField, d7: NSTextField) {
        price.stringValue = String(format: "$ %.2f", data.price)
        h1.stringValue = data.dinamyc1h != 0.0 ? String("\(data.dinamyc1h)%") : "-"
        h24.stringValue = data.dinamyc24h != 0.0 ? String("\(data.dinamyc24h)%") : "-"
        d7.stringValue = data.dinamyc7d != 0.0 ? String("\(data.dinamyc7d)%") : "-"
        
        h1.textColor = data.dinamyc1h > 0.0 ? NSColor.blue.withAlphaComponent(0.7) : NSColor.red.withAlphaComponent(0.7)
        h24.textColor = data.dinamyc24h > 0.0 ? NSColor.blue.withAlphaComponent(0.7) : NSColor.red.withAlphaComponent(0.7)
        d7.textColor = data.dinamyc7d > 0.0 ? NSColor.blue.withAlphaComponent(0.7) : NSColor.red.withAlphaComponent(0.7)
        
    }
    
    override func viewWillDisappear() {
        NotificationCenter.default.removeObserver(cmp)
        NotificationCenter.default.removeObserver(binance)
        NotificationCenter.default.removeObserver(bitfinex)
        NotificationCenter.default.removeObserver(hitbtc)
        NotificationCenter.default.removeObserver(huobi)

    }
}

