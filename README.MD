# Presenter

An animation kit to present viewController.

## Usage

```
// code in viewController

// step 0
// init animator and retain(if not dismiss bug)
let rect = CGRect(x: 100, y:200, width: 200, height: 200)
let animator = PresenterAnimator(presentFrame: rect, dummyColor: UIColor.clear, animatorType: .move(from: .bottom))
self.animator = animator

// step 1
// create viewController
let vc = CustomViewController()
vc.transitioningDelegate = animator
vc.modalPresentationStyle = .custom


// step 2
present(vc, animated: true, completion: nil)

```