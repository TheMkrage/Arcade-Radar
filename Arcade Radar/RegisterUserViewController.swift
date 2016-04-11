//
//  RegisterUserViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 4/6/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit


class RegisterUserViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    //All the Text Fields
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var teamTextField: UITextField!
    @IBOutlet var eMailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var reEnterPasswordTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    //Label to Display errors; hidden unless needed
    @IBOutlet var errorLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Makes scrolling possible
        self.automaticallyAdjustsScrollViewInsets = false
        // Set title (top of screen)
        self.title = "Register"
        // Password fields are dots
        self.passwordTextField.secureTextEntry = true
        self.reEnterPasswordTextField.secureTextEntry = true
        // Set the delegates
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        self.eMailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.reEnterPasswordTextField.delegate = self
        self.teamTextField.delegate = self
        // Keyboard for Email
        self.eMailTextField.keyboardType = UIKeyboardType.EmailAddress
        // Set Buttons to next and done instead of return
        self.firstNameTextField.returnKeyType = .Next
        self.lastNameTextField.returnKeyType = .Next
        self.eMailTextField.returnKeyType = .Next
        self.passwordTextField.returnKeyType = .Next
        self.reEnterPasswordTextField.returnKeyType = .Next
        self.teamTextField.returnKeyType = .Join
    }
    
   
    @IBAction func registerButton(sender: UIButton) {
        self.createAndAuth()
    }// End of func registerButton
    
    // Checks for pre-connection errors (blank text fields & passwords matching...)
    // Then connects, checks for errors server would throw (invalid email...)
    // Makes account, auths account while storing other info (name & team)
    // Sets name to use for title of Main Menu
    // Presents Main Menu
    func createAndAuth() {
        // Make sure passwords match
        if(self.passwordTextField.text != self.reEnterPasswordTextField.text) {
            self.errorLabel.text = "PASSWORDS DO NOT MATCH!"
            self.errorLabel.hidden = false;
            return
            // Checks if any fields are blank
        }else if(self.firstNameTextField.text!.isEmpty || self.lastNameTextField.text!.isEmpty || self.eMailTextField.text!.isEmpty || self.passwordTextField.text!.isEmpty || self.teamTextField.text!.isEmpty) {
            self.errorLabel.text = "A FIELD WAS LEFT BLANK!"
            self.errorLabel.hidden = false;
            return
        }
    }
    override func viewDidLayoutSubviews() {
        // Height & Width of ScrollView
        self.scrollView.contentSize.height = 1000;
        self.scrollView.contentSize.width = self.view.frame.size.width;
    }
    
    // When the user taps whitespace, close all keyboards
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true);
    }
    
    // When the user hits the return key, close all keyboards by defualt
    // if first name -> last name
    // if last name -> email
    // if email -> password
    // if password -> reenter password
    // if reenter -> team
    // if team -> creatAndAuth()
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.isEqual(self.firstNameTextField) {
            self.lastNameTextField.becomeFirstResponder()
        } else if textField.isEqual(self.lastNameTextField) {
            self.eMailTextField.becomeFirstResponder()
        } else if textField.isEqual(self.eMailTextField) {
            self.passwordTextField.becomeFirstResponder()
        } else if textField.isEqual(self.passwordTextField) {
            self.reEnterPasswordTextField.becomeFirstResponder()
        } else if textField.isEqual(self.reEnterPasswordTextField) {
            self.teamTextField.becomeFirstResponder()
        } else if textField.isEqual(self.teamTextField) {
            self.createAndAuth()
        }else {
            self.view.endEditing(true)
        }
        return false
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.view.endEditing(true)
        self.clearAllFields()
    }
    
    func clearAllFields () {
        self.firstNameTextField.text = nil
        self.lastNameTextField.text = nil
        self.eMailTextField.text = nil
        self.passwordTextField.text = nil
        self.reEnterPasswordTextField.text = nil
        self.teamTextField.text = nil
    }

}
