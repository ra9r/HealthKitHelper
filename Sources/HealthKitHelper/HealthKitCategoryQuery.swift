import HealthKit
import SwiftUI

@propertyWrapper
public struct HealthKitCategoryQuery : DynamicProperty {
    @EnvironmentObject var healthKitManager: HealthKitManager
    @State private var samples: [HKCategorySample] = []
    let categoryType: HKCategoryTypeIdentifier
    
    public init(_ categoryType: HKCategoryTypeIdentifier) {
        self.categoryType = categoryType
    }
    
    public var wrappedValue: [HKCategorySample] {
        get {
            return samples
        }
        nonmutating set {
            samples = newValue
        }
    }
    
    public var projectedValue: Binding<[HKCategorySample]> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }
    
    public func update() {
        if case healthKitManager.isAuthorized(for: categoryType) = .sharingAuthorized {
            healthKitManager.fetch(categoryType) { results, error in
                DispatchQueue.main.async {
                    if let error {
                        print("[\(categoryType.description)] Error fetching: \(error.localizedDescription) ")
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
