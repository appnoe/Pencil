//
//  ViewController.swift
//  Pencil
//
//  Created by Klaus Rodewig on 13.10.16.
//  Copyright © 2016 Appnö UG (haftungsbeschränkt). All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var pencilOperationsView: PencilOperationsView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pencilOperationsView.clearCanvas(animated:true)
    }
}

