//
//  CreateArcadeMachineViewController.swift
//  Arcade Radar
//
//  Created by Matthew Krager on 5/21/16.
//  Copyright © 2016 Matthew Krager. All rights reserved.
//

import UIKit

class CreateArcadeMachineViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var nameOfMachine:String = ""
    let currencies = ["Dollar(s)", "Token(s)", "Euro(s)", "Credit(s)", "Other"]
    
    let plays = ["Play(s)", "Song(s)", "Life/Lives", "Try/Tries", "Other"]
    
    var backendless = Backendless()
    @IBOutlet weak var priceTextField: UITextField!
    
    @IBOutlet weak var currencyTextField: UITextField!
    @IBOutlet weak var numOfPlaysTextField: UITextField!
    @IBOutlet weak var playsTextField: UITextField!
    @IBOutlet weak var arcadeTextField:UITextField!
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    var arcadeName:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameLabel.text = self.nameOfMachine
        
        //priceTextField.keyboardType = .NumbersAndPunctuation
        //playsTextField.keyboardType = .NumbersAndPunctuation
        
        let currencyPickerView = UIPickerView()
        
        currencyPickerView.delegate = self
        
        currencyPickerView.tag = 1
        
        currencyTextField.inputView = currencyPickerView
        
        let playsPickerView = UIPickerView()
        
        playsPickerView.delegate = self
        
        playsPickerView.tag = 2
        
        playsTextField.inputView = playsPickerView
        
        if let x = self.arcadeName as String! {
            self.arcadeTextField.text = x
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView.tag == 1 {
            return currencies.count
        }else if pickerView.tag == 2 {
            return plays.count
        }
        
        return 0
        
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView.tag == 1 {
            return currencies[row]
        }
        
        if pickerView.tag == 2 {
            return plays[row]
        }
        
        return nil
        
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.tag == 1 {
            if currencies[row] == "Other" {
                pickerView.endEditing(true)
                currencyTextField.inputView = nil
                currencyTextField.reloadInputViews()
            }else {
                currencyTextField.text = currencies[row]
            }
        }
        
        if pickerView.tag == 2 {
            if plays[row] == "Other" {
                pickerView.endEditing(true)
                playsTextField.inputView = nil
                playsTextField.reloadInputViews()
            }else {
                playsTextField.text = plays[row]
            }
        }
    }
    
    @IBAction func createNewMachine() {
        let newMachine = ArcadeMachine()
        newMachine.arcadeName = self.arcadeTextField.text!
        newMachine.price = Double(self.priceTextField.text!)!
        
        newMachine.whatPriceIsFor = self.playsTextField.text!
        newMachine.numOfPlays =  Int(self.numOfPlaysTextField.text!)!
        newMachine.currency = self.currencyTextField.text!
        // get the location-
       
        self.backendless.persistenceService.save(newMachine, response: { (x: AnyObject!) -> Void in
            self.navigationController?.popViewControllerAnimated(true)
        }) { (x: Fault!) -> Void in
                
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
