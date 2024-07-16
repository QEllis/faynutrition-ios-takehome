//
//  Notification+Extensions.swift
//  FayTakehome
//
//  Created by Quinn Ellis on 7/15/24.
//

import UIKit

extension Notification {

    // Helper to get frame of keyboard from Notification
    func keyboardFrame() -> CGRect {
        let info = self.userInfo
        return (info?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
    }
}
