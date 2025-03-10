//
//  AccountViewController.swift
//  Assingment
//
//  Created by Sulthan on 09/03/25.
//

import Foundation
import UIKit

class AccountViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    @IBAction func displayAccountsAction(_ sender: Any) {
        performSegue(withIdentifier: "showAccounts", sender: self)
    }
    
    @IBAction func photosButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "cameraActions", sender: self)
    }
    
    @IBAction func viewPDFView(_ sender: Any) {
        performSegue(withIdentifier: "viewPDF", sender: self)
    }
    
}
