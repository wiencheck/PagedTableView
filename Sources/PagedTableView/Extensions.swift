//
//  File.swift
//  
//
//  Created by Adam Wienconek on 26/05/2021.
//

import UIKit

extension UIView {
    func removeAllSubviews() {
        for view in subviews {
            view.removeFromSuperview()
        }
    }
}

extension UIStackView {
    func removeAllArrangedSubviews() {
        for subview in arrangedSubviews {
            subview.removeFromSuperview()
        }
    }
}

