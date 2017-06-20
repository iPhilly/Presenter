//
//  TNPresenter.swift
//  ToonanGuard
//
//  Created by leophy on 2017/5/15.
//  Copyright © 2017年 toonan. All rights reserved.
//

import Foundation

enum PresenterAnimatorType {
    /// 从哪个方向
    enum Direction {
        
        case left
        case right
        case top
        case bottom
    }
    
    case fadeIn     // 透明度渐变
    case bounds     // 从中心缩放
    case open       // 中轴线展开
    case downSpread // 从顶部向下展开
    
    // 出现时从哪个方向弹出,消失和进入动画相反
    case move(from: Direction)
}

class PresenterAnimator : NSObject {
    
    var presentFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    var dummyColor = UIColor.clear
    var animatorType = PresenterAnimatorType.fadeIn
    var dismissBlock : (()->())?
    
    fileprivate var isPresented : Bool = true // dismiss , present
    
    init(presentFrame:CGRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height),
         dummyColor:UIColor = UIColor.clear,
         animatorType:PresenterAnimatorType = PresenterAnimatorType.fadeIn,
         dismiss:@escaping ()->() = {}) {
        
        super.init()
        
        self.presentFrame = presentFrame
        self.dummyColor   = dummyColor
        self.animatorType = animatorType
        self.dismissBlock = dismiss
    }
    
    override init() {
        super.init()
    }
}

extension PresenterAnimator : UIViewControllerAnimatedTransitioning {
    
    // 动画时长
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    /// 具体的动画实现
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        //
        //        let fromVc = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        //        let toVc =   transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)
        let toView   = transitionContext.view(forKey: UITransitionContextViewKey.to)
        
        
        let x = self.presentFrame.origin.x
        let y = self.presentFrame.origin.y
        let width = self.presentFrame.size.width
        let height = self.presentFrame.size.height
        
        // 弹出动画
        if isPresented {
            containerView.addSubview(toView!)
            
            switch animatorType {
            case .fadeIn:
                toView?.alpha = 0.0;
                break
                
            case .bounds:
                toView?.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                toView?.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
                break
                
            case .open:
                toView?.layer.anchorPoint = CGPoint(x:0.5,y:0.0)
                toView?.transform = CGAffineTransform(scaleX: 0.001, y: 1.0)
                break
                
            case .downSpread:
                toView?.layer.anchorPoint = CGPoint(x: 0.5, y: 0.01)
                toView?.transform = CGAffineTransform(scaleX: 1.0, y: 0.001)
                break
                
            case .move(from: .top):     toView?.frame = CGRect(x: x, y: -height, width: width, height: height);         break
            case .move(from: .bottom):  toView?.frame = CGRect(x: x, y: kScreenHeight, width: width, height: height);   break
            case .move(from: .left):    toView?.frame = CGRect(x: -width, y: y, width: width, height: height);          break
            case .move(from: .right):   toView?.frame = CGRect(x: kScreenWidth, y: y, width: width, height: height) ;   break
            }
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                toView?.transform = CGAffineTransform.identity
                toView?.alpha = 1.0
                toView?.frame = self.presentFrame
            }, completion: { (finished) in
                transitionContext.completeTransition(finished)
            })
        }
            
            
            // 消失动画
        else {
            switch animatorType {
            case .fadeIn:
                UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                    fromView?.alpha = 0.0
                }, completion: { (finished) in
                    fromView?.removeFromSuperview()
                    transitionContext.completeTransition(finished)
                })
                break
                
            case .bounds:
                UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                    fromView?.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                }, completion: { (finished) in
                    fromView?.removeFromSuperview()
                    transitionContext.completeTransition(finished)
                })
                break
                
            case .open:
                fromView?.layer.anchorPoint = CGPoint(x: 0.5, y: 0.0)
                UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                    fromView?.transform = CGAffineTransform(scaleX: 0.001, y: 1.0)
                }, completion: { (finished) in
                    fromView?.removeFromSuperview()
                    transitionContext.completeTransition(finished)
                })
                break
                
            case .downSpread:
                fromView?.layer.anchorPoint = CGPoint(x: 0.5, y: 0.0)
                UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                    fromView?.transform = CGAffineTransform(scaleX: 1.0, y: 0.001)
                }, completion: { (finished) in
                    fromView?.removeFromSuperview()
                    transitionContext.completeTransition(finished)
                })
                break
                
            case .move(from: .top):
                dismissToFrame(fromView: fromView, context: transitionContext, frame: CGRect(x: x, y: y, width: width, height: -self.presentFrame.height))
                break
                
            case .move(from: .bottom):
                dismissToFrame(fromView: fromView, context: transitionContext, frame: CGRect(x: x, y: kScreenHeight, width: width, height: height))
                break
                
            case .move(from: .left):
                dismissToFrame(fromView: fromView, context: transitionContext, frame: CGRect(x: -self.presentFrame.width, y: y, width: width, height: height))
                break
                
            case .move(from: .right):
                dismissToFrame(fromView: fromView, context: transitionContext, frame: CGRect(x: kScreenWidth, y: y, width: width, height: height))
                break
            }
        }
    }
    
    fileprivate func dismissToFrame(fromView: UIView?, context: UIViewControllerContextTransitioning, frame: CGRect) {
        UIView.animate(withDuration: transitionDuration(using: context), animations: {
            fromView?.frame = frame
        }, completion: { (finished) in
            fromView?.removeFromSuperview()
            context.completeTransition(finished)
        })
    }
}

extension PresenterAnimator : UIViewControllerTransitioningDelegate {
    
    // 弹出动画
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresented = true
        return self
    }
    
    // 消失动画
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresented = false
        return self
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationVc = PresentationController(presentedViewController: presented, presenting: presenting)
        presentationVc.dummyColor = self.dummyColor
        presentationVc.presentFrame = self.presentFrame
        presentationVc.dummyViewTapBlock = self.dismissBlock
        
        return presentationVc
    }
}

class PresentationController : UIPresentationController {
    
    var dummyViewTapBlock : (()->())?
    var presentFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    var dummyColor = UIColor.clear
    
    fileprivate var dummyView = UIButton()
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    override func containerViewWillLayoutSubviews() {
        
        self.presentedView?.frame = self.presentFrame
        self.dummyView.backgroundColor = self.dummyColor
        self.containerView?.insertSubview(self.dummyView, at: 0)
        self.dummyView.frame = (self.containerView?.bounds)!
        self.dummyView.addTarget(self, action: #selector(dummyViewClick), for: UIControlEvents.touchUpInside)
    }
    
    func dummyViewClick() {
        
        self.presentedViewController.dismiss(animated: true, completion: {
            self.dummyViewTapBlock?()
        })
    }
}

