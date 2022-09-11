//
//  ViewController.swift
//  PageController
//
//  Created by Eric Williams on 2022-08-07.
//

import UIKit

class ViewController: UIViewController {

    private let erxPageControl: PageControl = PageControl()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPageControl()
        addConstraintsToPageControl()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        erxPageControl.configureScrollView()
    }
    
    fileprivate func setupPageControl() {
        erxPageControl.bounds = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds
            .height)
        view.addSubview(erxPageControl)
    }
    
    fileprivate func addConstraintsToPageControl() {
        erxPageControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            erxPageControl.topAnchor.constraint(equalTo: view.topAnchor),
            erxPageControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            erxPageControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            erxPageControl.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1)
        ])
    }
}
