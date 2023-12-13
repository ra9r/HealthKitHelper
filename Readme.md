`HealthKitHelper` is a collection of utilities that make using Apple Health (HealthKit) easier to use.

# Property Wrappers
HealthKit isn't really very SwiftUI friendly.  To help with this fact, `HealthKitHelper` offers a collection of 
handy property wrappers that were inspired by the `SwiftData` `@Query` property wrappers.

## @HealthKitCategoryQuery
Here is an example of how you can create a dynamic binding for a particular `HKCateogryTypeIdentifier` and get 
an array of the results from HealthKit.  This binding is dynamic, so any time you delete or change HealthKit 
views that show the results will automatically update.

```swift
import SwiftUI
import HealthKit
import HealthKitHelper

struct FatigueList : View {
    @HealthKitCategoryQuery(.fatigue)
    var samples: [HKCategorySample]

    var body: some View {
        List(samples, id: \.uuid) { sample in
            LabeledContent(HKCategoryValueSeverity(rawValue: sample.value)!.description) {
                Text(format(sample.startDate))
            }
        }
    }
    
    func format(_ date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
}
```

## @HealthKitQuantityQuery
Here is an example of how you can create a dynamic binding for a particular `HKQuantityTypeIdentifier` and get 
an array of the results from HealthKit.  This binding is dynamic, so any time you delete or change HealthKit 
views that show the results will automatically update.

```swift
import SwiftUI
import HealthKit
import HealthKitHelper

struct BodyMassList : View {
    @HealthKitCategoryQuery(.bodyMass)
    var samples: [HKQuantitySample]

    var body: some View {
        List(samples, id: \.uuid) { sample in
            LabeledContent(sample.quantity.description) {
                Text(format(sample.startDate))
            }
        }
    }
    
    func format(_ date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
}
```
