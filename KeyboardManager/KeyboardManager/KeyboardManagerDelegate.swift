//
//  KeyboardManagerDelegate.swift
//  KeyboardManager
//
//  Created by Richard Ash on 3/30/17.
//  Copyright © 2017 Richard. All rights reserved.
//

import UIKit

typealias KeyboardManagerDelegate = KeyboardManagerDelegateRequired & KeyboardManagerDelegateOptional

protocol KeyboardManagerDelegateRequired: class {
  func keyboardManager(_ keyboardManager: KeyboardManager, keyboardWillChangeFrame endFrame: CGRect?, duration: TimeInterval, animationCurve: UIViewAnimationOptions)
}

@objc protocol KeyboardManagerDelegateOptional {
  @objc optional func keyboardWillHide(userInfo: [AnyHashable: Any])
}
