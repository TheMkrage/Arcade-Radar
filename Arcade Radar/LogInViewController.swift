//
//  ViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 4/6/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

// Login screen viewcontroller
class LogInViewController: UIViewController, UITextFieldDelegate {
    
    // TextFields and Label used to display errors
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the title to BebasNeue (it is now set for good)
         self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "BebasNeue", size: 34)!]
        // Set the delegates
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        // Email keyboard
        self.usernameTextField.keyboardType = UIKeyboardType.EmailAddress
        // Set password field to password characters
        self.passwordTextField.secureTextEntry = true
        // Return -> Done or Next
        self.usernameTextField.returnKeyType = UIReturnKeyType.Next
        self.passwordTextField.returnKeyType = UIReturnKeyType.Done
        // Check For RememberMe
        retrieveRememberMeValues()
    }
    
    func retrieveRememberMeValues() {
        // If there is a valid string value in username (this assumes password is the same) then set those string to the fields
        if (NSUserDefaults.standardUserDefaults().stringForKey("username") != nil) {
            self.usernameTextField.text = NSUserDefaults.standardUserDefaults().stringForKey("username")
            self.passwordTextField.text = NSUserDefaults.standardUserDefaults().stringForKey("password")
        }
    }
    
    // When the user taps whitespace, close all keyboards
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)

    }
    
    @IBAction func loginButton(sender: UIButton) {
        self.login()
    } // End of func loginButton
    
    func login() {
       
    }// End of login
    
    // Check if Remember Me is checked and save/delete values accordingly. Then, end all editing and clear fields when view is left
    override func viewWillDisappear(animated: Bool) {
        self.view.endEditing(true)
        self.clearAllFields()
    }
    
    func clearAllFields () {
        self.usernameTextField.text = nil
        self.passwordTextField.text = nil
    }
    
    // When the user hits the return key, close all keyboards by default
    // if username field, move to password
    // if password, click the login button
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.isEqual(self.usernameTextField) {
            self.passwordTextField.becomeFirstResponder()
        }else if textField.isEqual(self.passwordTextField) {
            self.login()
        }else {
            self.view.endEditing(true)
        }
        return false
    }
}

