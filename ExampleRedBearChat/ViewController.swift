//
//  ViewController.swift
//  ExampleRedBearChat
//
//  Created by Eric Larson on 9/26/17.
//  Copyright © 2017 Eric Larson. All rights reserved.
//

import UIKit

// MARK: CHANGE 2: No longer should this view be a BLE delegate
class ViewController: UIViewController {
    
    // MARK: VC Properties
    // MARK: CHANGE 3: No longer have BLE instantiate itself. Instead: Add support for lazy instantiation (like we did in the table view controller)
    lazy var bleShield:BLE = (UIApplication.shared.delegate as! AppDelegate).bleShield
    var rssiTimer = Timer()
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    //@IBOutlet weak var buttonConnect: UIButton!
    
    @IBOutlet weak var connectLabel: UILabel!
    
    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var textBox: UITextField!
    @IBOutlet weak var rssiLabel: UILabel!
    @IBOutlet weak var potLabel: UILabel!
    
    
    
    @IBOutlet weak var ledSwitch: UISwitch!
    
    @IBOutlet weak var servoTurner: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: CHANGE 1.a: change this as you no longer need to instantiate the BLE Object like this
        //   you should not let this ViewController be the BLE delegate
        // bleShield.delegate = self
        
        // MARK: CHANGE 4: Nothing to actually change here, just get familiar with
        //  the code below and what the notificaitons mean.
        // These selector functions should be created from the old BLEDelegate functions
        // One example has already been completed for you on the receiving of data function
        
        // BLE Connect Notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.onBLEDidConnectNotification),
                                               name: NSNotification.Name(rawValue: kBleConnectNotification),
                                               object: nil)
        
        // BLE Disconnect Notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.onBLEDidDisconnectNotification),
                                               name: NSNotification.Name(rawValue: kBleDisconnectNotification),
                                               object: nil)
        
        // BLE Recieve Data Notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.onBLEDidRecieveDataNotification),
                                               name: NSNotification.Name(rawValue: kBleReceivedDataNotification),
                                               object: nil)
        
        
    }
    
    func readRSSITimer(timer:Timer){
        bleShield.readRSSI { (number, error) in
            // when RSSI read is complete, display it
            self.rssiLabel.text = String(format: "%.1f",(number?.floatValue)!)
            self.spinner.stopAnimating()
        }
    }

    // MARK: Delegate Methods
    func bleDidUpdateState() {
        
    }
    // MARK: CHANGE 7: use function from "BLEDidConnect" notification
    // in this function, update a label on the UI to have the name of the active peripheral
    // you might be interested in the following method (from objective C):
    // NSString *deviceName =[notification.userInfo objectForKey:@"deviceName"];
    // NEW  CONNECT FUNCTION
    @objc func onBLEDidConnectNotification(notification:Notification){
        print("Notification arrived that BLE Connected")
        self.connectLabel.text = "Connected"
        
        let deviceName = notification.userInfo?["name"] as! String?
        
        print(deviceName)
        
        self.connectLabel.text = deviceName
        
        self.spinner.startAnimating()
        rssiTimer = Timer.scheduledTimer(withTimeInterval: 1.0,
                                         repeats: true,
                                         block: self.readRSSITimer)
        
//        let d = notification.userInfo?["data"] as! Data?
//        let s = String(bytes: d!, encoding: String.Encoding.utf8)
//        self.labelText.text = s
    }
    
    // OLD DELEGATION CONNECT FUNCTION
    func bleDidConnectToPeripheral() {
        self.spinner.stopAnimating()
        //self.buttonConnect.setTitle("Disconnect", for: .normal)
        
        // Schedule to read RSSI every 1 sec.
        rssiTimer = Timer.scheduledTimer(withTimeInterval: 1.0,
                                         repeats: true,
                                         block: self.readRSSITimer)

    }
    
    // OLD DELEGATION DISCONNECT FUNCTION
    func bleDidDisconnectFromPeripheral() {
        // MARK: CHANGE 5.b: remove all accesses of the "connect button"
        //self.buttonConnect.setTitle("Connect", for: .normal)
        rssiTimer.invalidate()
    }
    
    // NEW  DISCONNECT FUNCTION
    @objc func onBLEDidDisconnectNotification(notification:Notification){
        print("Notification arrived that BLE Disconnected a Peripheral")
        self.connectLabel.text = "Disconnected"
    }
    
    
    // NEW FUNCTION EXAMPLE: this was written for you to show how to change to a notification based model
    @objc func onBLEDidRecieveDataNotification(notification:Notification){
        let d = notification.userInfo?["data"] as! Data?
        let s = String(bytes: d!, encoding: String.Encoding.utf8)
        if (s == "B000")
        {
            labelText.text = "🔜";
        }
        
        else if (s == "B001")
        {
            labelText.text = "🔛";
        }
        
        else if (s == "P000")
        {
            potLabel.text = "Pot value under 1000";
        }
            
        else if (s == "P001")
        {
            potLabel.text = "Pot value over 1000";
        }
    }
    
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        
        // prepend S for SERVO
        let s = "S" + String(Int(sender.value))
        let d = s.data(using: String.Encoding.utf8)!
        //print("Slider changing to \(s) ?")
        bleShield.write(d)
    }
    
    
    @IBAction func switchOn(_ sender: UISwitch) {
        
        if ledSwitch.isOn {
            print("led switch turned on")
            let s = "L001"
            let d = s.data(using: String.Encoding.utf8)!
            bleShield.write(d)
            
        } else {
            print("led switch turned off")
            let s = "L000"
            let d = s.data(using: String.Encoding.utf8)!
            bleShield.write(d)
            
        }
        
        
        // prepend S for SERVO
        //let s = "S" + String(Int(sender.value))
        //let d = s.data(using: String.Encoding.utf8)!
        //print("Slider changing to \(s) ?")
        //bleShield.write(d)
        
        
    }
    
    
    // MARK: CHANGE: this function only needs a name change, the BLE writing does not change
    @IBAction func sendDataButton(_ sender: UIButton) {
        
        let s = textBox.text!
        let d = s.data(using: String.Encoding.utf8)!
        bleShield.write(d)
        // if (self.textField.text.length > 16)
    }
    
}








