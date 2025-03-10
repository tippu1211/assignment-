//
//  PDFViewController.swift
//  Assingment
//
//  Created by Sulthan on 09/03/25.
//

import Foundation
import UIKit
import PDFKit

class PDFViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeView))
        
        let pdfView = PDFView(frame: view.bounds)
        pdfView.autoScales = true
        view.addSubview(pdfView)

        if let pdfURL = URL(string: "https://fssservices.bookxpert.co/GeneratedPDF/Companies/nadc/2024-2025/BalanceSheet.pdf"),
           let document = PDFDocument(url: pdfURL) {
            pdfView.document = document
        }
    }

    @objc func closeView() {
        dismiss(animated: true, completion: nil)
    }
}
