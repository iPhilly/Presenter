# TNPresenter

An animation kit to present viewController.

## Usage

```
// code in viewController

// step 0

// frame
let rect = CGRect(x: 100, y:200, width: 200, height: 200)

// init animator (frame,backColor, animatorType)
let animator = TNPresenterAnimator(presentFrame: rect, dummyColor: UIColor.clear, animatorType: .move(from: .bottom))

// retain animator(if not dismiss bug)
self.animator = animator

// step 1
let vc = CustomViewController()
vc.transitioningDelegate = animator
vc.modalPresentationStyle = .custom


// step 2
present(vc, animated: true, completion: nil)

```