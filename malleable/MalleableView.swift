//
//  MalleableView.swift
//  malleable
//
//  Created by Hunter Monk on 7/19/16.
//  Copyright © 2016 Hunter Monk. All rights reserved.
//

import Foundation
import UIKit

class MalleableView: UIView {

    var gestureDelegate = MalleableGestureDelegate()

    var recognizers: [UIGestureRecognizer] {
        get {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))

            let rotate = UIRotationGestureRecognizer(target: self, action:
             #selector(handleRotation))

            return [pan, pinch, rotate]
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        add(recognizers: recognizers)
    }

    func add(recognizers: [UIGestureRecognizer]) {
        for recognizer in recognizers {
            addGestureRecognizer(recognizer)
            recognizer.delegate = gestureDelegate
        }
    }
}

extension MalleableView: Malleable {

    func handlePan(recognizer: UIPanGestureRecognizer) {

        guard let view = recognizer.view else {
            return
        }

        guard isFirstResponder() == false else {
            return
        }

        let translation = recognizer.translation(in: view.superview)

        view.center = CGPoint(x:view.center.x + translation.x,
                              y:view.center.y + translation.y)

        recognizer.setTranslation(CGPoint.zero, in: view.superview)

    }

    func handlePinch(recognizer: UIPinchGestureRecognizer) {
        guard isFirstResponder() == false else {
            return
        }
        transform = transform.scaleBy(x: recognizer.scale, y: recognizer.scale)
        recognizer.scale = 1
    }

    func handleRotation(recognizer: UIRotationGestureRecognizer) {
        guard isFirstResponder() == false else {
            return
        }
        transform = transform.rotate(recognizer.rotation)
        recognizer.rotation = 0
    }
    
}

class MalleableTextField: UITextField {

    var textEntryDelegate: TextEntryDelegate?

    var lastLocation: (transform: CGAffineTransform, center: CGPoint)?

    var keyboardHideCurve: Int!
    var keyboardHideDuration: TimeInterval!

    var currentState = TextEntryState.Started {
        didSet {
            switch currentState {
            case .Started:
                bringBackToStartingState()
                break
            case .Editing:
                beginEditing()
                break
            case .ContainsText:
                break
            }
        }
    }

    func beginEditing() {
        UIView.beginAnimations(nil, context: nil)
        alpha = 1
        UIView.commitAnimations()

        becomeFirstResponder()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(recognizer)
    }

    func addObservers() {
        let center = NotificationCenter.default

        let show = NSNotification.Name.UIKeyboardWillShow
        let hide = NSNotification.Name.UIKeyboardWillHide

        center.addObserver(self, selector: #selector(keyboardWillShow),
                           name: show, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide),
                           name: hide, object: nil)
    }

    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        super.textRect(forBounds: bounds)
        return bounds.insetBy(dx: 10, dy: 10)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        super.editingRect(forBounds: bounds)
        return bounds.insetBy(dx: 10, dy: 10)
    }

    func keyboardWillShow(notification: NSNotification) {

        currentState = .Editing

        if text!.characters.count != 0 {
            lastLocation = (transform, center)
        }

        let info = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue

        guard let keyboardSize = info?.cgRectValue() else {
            return
        }

        guard let superview = superview else {
            return
        }

        UIView.animate(withDuration: 1) {
            self.transform = CGAffineTransform.identity

            let fieldHeight: CGFloat = 72

            let y = superview.frame.height - keyboardSize.height - fieldHeight - 100
            self.frame = CGRect(x: 15, y: y, width: superview.frame.width - 30, height: fieldHeight)
        }

    }

    func animateToLastLocation() {
        guard text!.characters.count != 0 else {
            currentState = .Started
            return
        }

        currentState = .ContainsText

        guard let lastLocation = lastLocation else {
            return
        }

        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(keyboardHideDuration)
        UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: keyboardHideCurve)!)
        UIView.setAnimationBeginsFromCurrentState(true)
        self.transform = lastLocation.transform
        center = lastLocation.center
        UIView.commitAnimations()

    }

    func keyboardWillHide(notification: NSNotification) {

        if let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
            keyboardHideDuration = duration
        }

        if let curve = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as? Int {
            keyboardHideCurve = curve
        }

    }

    func bringBackToStartingState() {
        alpha = 0
        lastLocation = nil
        text = ""

        UIView.animate(withDuration: 1) {
            self.transform = CGAffineTransform.identity

            let fieldHeight: CGFloat = 72

            let y = 0 - fieldHeight

            guard let superview = self.superview else {
                return
            }

            self.frame = CGRect(x: 0, y: y, width: superview.frame.width, height: fieldHeight)
        }
    }

}

extension MalleableTextField {

    func handleTap(recognizer: UITapGestureRecognizer) {
        textEntryDelegate?.willBecomeResponder(textEntry: self)
    }

}
