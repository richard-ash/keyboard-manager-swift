//
//  ViewController.swift
//  KeyboardManager
//
//  Created by Richard Ash on 3/30/17.
//  Copyright © 2017 Richard. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    KeyboardManager.shared.delegate = self
    // Do any additional setup after loading the view, typically from a nib.
  }


}

extension ViewController: KeyboardManagerDelegate {
  func keyboardManager(_ keyboardManager: KeyboardManager, keyboardWillChangeFrame endFrame: CGRect?, duration: TimeInterval, animationCurve: UIViewAnimationOptions) {
    print("End Frame: \(String(describing: endFrame))")
    print("Duration: \(duration)")
    print("Animation Curve: \(animationCurve)")
  }
}
