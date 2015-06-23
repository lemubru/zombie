//
//  Utilities.swift
//  MobileTutsInvaderz
//
//  Created by Frank du Plessis on 2015/06/14.
//  Copyright (c) 2015 James Tyner. All rights reserved.
//



import Foundation
import SpriteKit

extension Array {
    func randomElement() -> T {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}
