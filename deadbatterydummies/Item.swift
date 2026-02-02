//
//  Item.swift
//  deadbatterydummies
//
//  Created by Joe Wilson on 2/2/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
