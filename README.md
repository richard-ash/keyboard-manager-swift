# Keyboard Manager

This repo solves a problem I came across in using notifications to manage the iOS Keyboard. 

## Managing the Keyboard

When I first started managing the keyboard I would use separate Notifications in each ViewController.

**Notification Method (Using Notification):**

```swift
class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
      NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardNotification), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
  }
  
  func keyboardNotification(notification: Notification) {
    guard let userInfo = notification.userInfo else { return }
    
    guard let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
    let duration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
    let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
    let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseOut.rawValue
    let animationCurve: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
    
    if endFrame.origin.y >= UIScreen.main.bounds.size.height {
      lowerViewBottomConstraint.constant = 0
    } else {
      lowerViewBottomConstraint.constant = endFrame?.size.height ?? 0.0
    }

    view.animateConstraint(withDuration: duration, delay: TimeInterval(0), options: animationCurve, completion: nil)
  }
}
```

My problem was that I found myself writing this code again and again for every single ViewController. After experimenting a bit I found using a Singleton + Delegate pattern allowed me to reuse a bunch of code and organize all of the Keyboard Management in a single place!

**Singleton + Delegate Method:**

```swift
protocol KeyboardManagerDelegate: class {
  func keyboardWillChangeFrame(endFrame: CGRect?, duration: TimeInterval, animationCurve: UIViewAnimationOptions)
}

class KeyboardManager {
  
  static let sharedInstance = KeyboardManager()
  
  weak var delegate: KeyboardManagerDelegate?
  
  init() {
    NotificationCenter.default.addObserver(self, selector: #selector(KeyboardManager.keyboardWillChangeFrameNotification), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
  }
  
  @objc func keyboardWillChangeFrameNotification(notification: Notification) {
    guard let userInfo = notification.userInfo else { return }
    
    let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
    let duration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
    let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
    let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseOut.rawValue
    let animationCurve: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
    
    delegate?.keyboardWillChangeFrame(endFrame: endFrame, duration: duration, animationCurve: animationCurve)
  }
}
```

Now when I want to manage the keyboard from a ViewController all I need to do is set the delegate to that ViewController and implement any delegate methods.

```swift
class ViewController: UIViewController {
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    KeyboardManager.sharedInstance.delegate = self
  }
}

// MARK: - Keyboard Manager

extension ViewController: KeyboardManagerDelegate {
  func keyboardWillChangeFrame(endFrame: CGRect?, duration: TimeInterval, animationCurve: UIViewAnimationOptions) {
    guard let endFrame = endFrame else { return }
    
    if endFrame.origin.y >= UIScreen.main.bounds.size.height {
      lowerViewBottomConstraint.constant = 0
    } else {
      lowerViewBottomConstraint.constant = (endFrame?.size.height ?? 0.0)
    }
    view.animateConstraint(withDuration: duration, delay: TimeInterval(0), options: animationCurve, completion: nil)
  }
}
``` 
   
This method is very customizable too! 🎉💯 Say we want to add functionality for `NSNotification.Name.UIKeyboardWillHide`. This is as easy as adding a method to our `KeyboardManagerDelegate`.

`KeyboardManagerDelegate` with `NSNotification.Name.UIKeyboardWillHide`:

```swift
protocol KeyboardManagerDelegate: class {
  func keyboardWillChangeFrame(endFrame: CGRect?, duration: TimeInterval, animationCurve: UIViewAnimationOptions)
  func keyboardWillHide(userInfo: [AnyHashable: Any])
}

class KeyboardManager {
  
  static let sharedInstance = KeyboardManager()
  
  weak var delegate: KeyboardManagerDelegate?
  
  init() {
    NotificationCenter.default.addObserver(self, selector: #selector(KeyboardManager.keyboardWillChangeFrameNotification), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(KeyboardManager.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  
  @objc func keyboardWillChangeFrameNotification(notification: Notification) {
    guard let userInfo = notification.userInfo else { return }
    
    let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
    let duration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
    let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
    let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseOut.rawValue
    let animationCurve: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
    
    delegate?.keyboardWillChangeFrame(endFrame: endFrame, duration: duration, animationCurve: animationCurve)
  }
  
  @objc func keyboardWillHide(notification: Notification) {
    guard let userInfo = notification.userInfo else { return }
    delegate?.keyboardWillHide(userInfo: userInfo)
  }
}
```

Say we only want to implement `func keyboardWillHide(userInfo: [AnyHashable: Any])` in one `UIViewController`. We can also make this method optional.

```swift
typealias KeyboardManagerDelegate = KeyboardManagerModel & KeyboardManagerConfigureable

protocol KeyboardManagerModel: class {
  func keyboardWillChangeFrame(endFrame: CGRect?, duration: TimeInterval, animationCurve: UIViewAnimationOptions)
}

@objc protocol KeyboardManagerConfigureable {
  @objc optional func keyboardWillHide(userInfo: [AnyHashable: Any])
}
```

> *Note:* this pattern helps avoid overuse of `@objc`. See [HERE](http://www.jessesquires.com/avoiding-objc-in-swift/) for more details!

In summary, I've found using a **Singleton + Delegate** to manage the keyboard is both more efficient and easier to use than using **Notifications**.
