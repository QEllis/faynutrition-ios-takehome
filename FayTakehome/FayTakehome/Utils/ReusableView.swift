//
//  ReusableView.swift
//  FayTakehome
//
//  Created by Quinn Ellis on 7/15/24.
//

import UIKit

public protocol ReusableView: AnyObject {
    static var defaultReuseIdentifier: String { get }
}

public extension ReusableView where Self: UIView {
    static var defaultReuseIdentifier: String {
        return String(describing: self)
    }
}
