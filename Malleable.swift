//
//  Malleable.swift
//  SelfieSticker
//
//  Created by Hunter Monk on 7/18/16.
//  Copyright © 2016 Hunter Monk. All rights reserved.
//

import Foundation
import UIKit

protocol Malleable {
    func handlePan(recognizer: UIPanGestureRecognizer)
    func handlePinch(recognizer: UIPinchGestureRecognizer)
    func handleRotation(recognizer: UIRotationGestureRecognizer)
    func add(recognizers: [UIGestureRecognizer])
}
