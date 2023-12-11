//
//  HealthKitQuantity.swift
//  HealthKitStudy
//
//  Created by Rodney Aiglstorfer on 12/9/23.
//

import SwiftUI
import HealthKit

@propertyWrapper
public struct HealthKitQuantityQuery : DynamicProperty {
    @EnvironmentObject var healthKitManager: HealthKitManager
    @State private var samples: [HKQuantitySample] = []
    let quantityType: HKQuantityTypeIdentifier
    
    
    public init(_ quantityType: HKQuantityTypeIdentifier) {
        self.quantityType = quantityType
    }
    
    public var wrappedValue: [HKQuantitySample] {
        get {
            return samples
        }
        nonmutating set {
            samples = newValue
        }
    }
    
    public var projectedValue: Binding<[HKQuantitySample]> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }
    
    public func update() {
        if case healthKitManager.isAuthorized(for: quantityType) = .sharingAuthorized {
            healthKitManager.fetch(quantityType) { results, error in
                DispatchQueue.main.async {
                    if let error {
                        print("[\(quantityType.description)] Error fetching: \(error.localizedDescription) ")
                        self.samples = []
                    } else {
                        self.samples = results
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.samples = []
            }
        }
    }
}
