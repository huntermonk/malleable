//
//  MalleableGestureDelegate.swift
//  malleable
//
//  Created by Hunter Monk on 7/19/16.
//  Copyright © 2016 Hunter Monk. All rights reserved.
//

import Foundation
import UIKit

class MalleableGestureDelegate: NSObject, UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
