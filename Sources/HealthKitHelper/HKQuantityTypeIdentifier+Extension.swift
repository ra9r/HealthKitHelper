//
//  HKQuantityTypeIdentifier+Extension.swift
//  HealthKitStudy
//
//  Created by Rodney Aiglstorfer on 12/9/23.
//

import Foundation
import HealthKit
import Ra9rKit

extension HKQuantityTypeIdentifier {
    /// Convinient user-facing description for the `HKQuantityTypeIdentifier` that formats the `rawValue`
    public var description: String {
        return self.rawValue.replacingOccurrences(of: "HKQuantityTypeIdentifier", with: "").titlecase()
    }
    
    public static var vitals: [HKQuantityTypeIdentifier] {
        return [.bodyMass,
                .bodyTemperature,
                .bodyMassIndex,
                .bodyFatPercentage,
                .leanBodyMass,
                .heartRate,
                .bloodPressureSystolic,
                .bloodPressureDiastolic]
    }
}
