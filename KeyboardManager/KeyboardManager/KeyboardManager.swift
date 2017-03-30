//
//  KeyboardManager.swift
//  KeyboardManager
//
//  Created by Richard Ash on 3/30/17.
//  Copyright © 2017 Richard. All rights reserved.
//

import UIKit

class KeyboardManager {
  
  // MARK: - Static Variables
  
  static let shared = KeyboardManager()
  
  // MARK: - Variables
  
  weak var delegate: KeyboardManagerDelegate?
  
  // MARK: - Init
  
  init() {
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: .UIKeyboardWillChangeFrame, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
  }
  
  // MARK: - Functions
  
  @objc private func keyboardWillChangeFrame(notification: Notification) {
    guard let userInfo = notification.userInfo else { return }
    
    let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
    let duration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
    let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
    let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseOut.rawValue
    let animationCurve: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
    
    delegate?.keyboardManager(self, keyboardWillChangeFrame: endFrame, duration: duration, animationCurve: animationCurve)
  }
  
  @objc private func keyboardWillHide(notification: Notification) {
    guard let userInfo = notification.userInfo else { return }
    delegate?.keyboardWillHide?(userInfo: userInfo)
  }
}
