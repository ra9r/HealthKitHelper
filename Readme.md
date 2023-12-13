`HealthKitHelper` is a collection of utilities, extensions, and property-wrappers that make using Apple Health (HealthKit) more "SwiftUI Like".

To use HealthKitHelper you'll need to first add the `HealthKitManager` to the environment.  

```swift
import SwiftUI
import HealthKitHelper

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(HealthKitManager())
        }
    }
}
```

With this done you can access the `HealthKitManager` using `@EnvironmentObject` ...

```swift
import SwiftUI
import HealthKit
import HealthKitHelper

struct MyView: View {
    @EnvironmentObject 
    var healthKitManager: HealthKitManager
    
    // ...
}
```

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

# Useful Extensions

## `HKCategoryTypeIdentifier` Extensions

* `.description` Returns an english (not localized) description of the category type identifier.
* `.symptoms` Returns an array of just the symptom related `HKCategoryTypeIdentifier`'s


## `HKQuantityTypeIdentifier` Extensions

* `.description` Returns an english (not localized) description of the quantity type identifier.
* `.vitals` Returns an array of just the vitals related `HKQuantityTypeIdentifier`'s

## `HKCategoryValueSeverity` Extensions

* `.description` Returns an english (not localized) description of the severity type
* `.allCases` Returns an array of all the enumerated types (because, oddly the native version doesn't have this)
