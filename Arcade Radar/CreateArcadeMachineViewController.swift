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
    let iPhones = ["iPhone 6s", "iPhone 6s Plus", "iPhone SE"]
    
    let colors = ["Gold", "Rose Gold", "Silver", "Space Gray"]
    
    @IBOutlet weak var iPhoneTextField: UITextField!
    
    @IBOutlet weak var colorTextField: UITextField!
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameLabel.text = self.nameOfMachine
        
        iPhoneTextField.keyboardType = .DecimalPad
        
        let iPhonePickerView = UIPickerView()
        
        iPhonePickerView.delegate = self
        
        iPhonePickerView.tag = 1
        
       // iPhoneTextField.inputView = iPhonePickerView
        
        let colorPickerView = UIPickerView()
        
        colorPickerView.delegate = self
        
        colorPickerView.tag = 2
        
        colorTextField.inputView = colorPickerView
        
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
            return iPhones.count
        }else if pickerView.tag == 2 {
            return colors.count
        }
        
        return 0
        
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView.tag == 1 {
            return iPhones[row]
        }
        
        if pickerView.tag == 2 {
            return colors[row]
        }
        
        return nil
        
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.tag == 1 {
            iPhoneTextField.text = iPhones[row]
        }
        
        if pickerView.tag == 2 {
            colorTextField.text = colors[row]
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
