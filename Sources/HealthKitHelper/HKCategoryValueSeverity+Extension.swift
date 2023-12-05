//
//  File.swift
//  
//
//  Created by Rodney Aiglstorfer on 12/5/23.
//

import Foundation
import HealthKit

public extension HKCategoryValueSeverity {
    var description: String {
        switch self {
            case .notPresent:
                return "Not Present"
            case .mild:
                return "Mild"
            case .moderate:
                return "Moderate"
            case .severe:
                return "Severe"
            case .unspecified:
                fallthrough
            @unknown default:
                return "Unspecified"
        }
    }
}
