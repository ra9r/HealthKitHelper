//
//  HealthKitManager.swift
//  HealthKitStudy
//
//  Created by Rodney Aiglstorfer on 12/8/23.
//

import Foundation
import HealthKit

public class HealthKitManager : ObservableObject {
    
    private var healthStore = HKHealthStore()
    
    public var store: HKHealthStore {
        return healthStore
    }
    
    public init() {
        // Placeholder for now
    }
    
    // MARK: Authorization Functions
    
    public func isAuthorized(for typeId: HKCategoryTypeIdentifier) -> HKAuthorizationStatus {
        let type = HKCategoryType.categoryType(forIdentifier: typeId)!
        return healthStore.authorizationStatus(for: type)
    }
    
    public func isAuthorized(for typeId: HKQuantityTypeIdentifier) -> HKAuthorizationStatus {
        let type = HKObjectType.quantityType(forIdentifier: typeId)!
        return healthStore.authorizationStatus(for: type)
    }

    public func requestAuthorization(for typeId: HKCategoryTypeIdentifier,
                                     readOnly: Bool = false) async throws {
        var readTypes: Set<HKObjectType> = []
        if let readType = HKObjectType.categoryType(forIdentifier: typeId) {
            readTypes = [readType]
        }
        
        var shareTypes: Set<HKSampleType> = []
        if !readOnly, let shareType = HKSampleType.categoryType(forIdentifier: typeId) {
            shareTypes = [shareType]
        }
        
        try await healthStore.requestAuthorization(toShare: shareTypes, read: readTypes)
    }
    
    public func requestAuthorization(for typeId: HKQuantityTypeIdentifier,
                                     readOnly: Bool = false) async throws {
        var readTypes: Set<HKObjectType> = []
        if let shareType = HKObjectType.quantityType(forIdentifier: typeId) {
            readTypes = [shareType]
        }
        
        var shareTypes: Set<HKSampleType> = []
        if !readOnly, let shareType = HKSampleType.quantityType(forIdentifier: typeId) {
            shareTypes = [shareType]
        }
        
        try await healthStore.requestAuthorization(toShare: shareTypes, read: readTypes)
    }
    
    
    public func requestBatchReadAuthorizations(_ categoryTypes: Set<HKCategoryTypeIdentifier>) async throws {
        var readTypes = Set<HKObjectType>()
        
        for typeId in categoryTypes {
            if let type = HKCategoryType.categoryType(forIdentifier: typeId) {
                readTypes.insert(type)
            }
        }
        
        try await healthStore.requestAuthorization(toShare: [], read: readTypes)
    }
    
    // MARK: Save Functions

    public func saveCategory(_ typeId: HKCategoryTypeIdentifier,
                             severity: HKCategoryValueSeverity,
                             start: Date, 
                             end: Date? = nil,
                             metadata: [String: Any]? = nil) async throws -> HKCategorySample {
        
        let categoryType = HKCategoryType.categoryType(forIdentifier: typeId)!
        
        let sample = HKCategorySample(type: categoryType,
                                      value: severity.rawValue,
                                      start: start, 
                                      end: end ?? start,
                                      metadata: metadata)
        
        try await healthStore.save(sample)
        
        return sample
    }
    
    public func saveQuantity(_ typeId: HKQuantityTypeIdentifier,
                             quantity: Double,
                             start: Date, 
                             end: Date? = nil,
                             metadata: [String: Any]? = nil) async throws -> HKQuantitySample {
        
        let quantityType = HKQuantityType.quantityType(forIdentifier: typeId)!
        
        let units = try await preferredUnits(for: quantityType)
        
        let quantity = HKQuantity(unit: units!, doubleValue: quantity)
        
        let sample = HKQuantitySample(type: quantityType,
                                      quantity: quantity,
                                      start: start,
                                      end: end ?? start,
                                      metadata: metadata)
        
        try await healthStore.save(sample)
        
        return sample
    }
    
    // MARK: Fetching Functions
    
    public func fetch(_ categoryType: HKCategoryTypeIdentifier, 
                      completion: @escaping ([HKCategorySample], Error?) -> Void) {
        guard let objType = HKObjectType.categoryType(forIdentifier: categoryType) else {
            // Handle the error if the category type is not valid.
            print("Error: Invalid category type (\(categoryType.description))) **")
            completion([], nil)
            return
        }
        
        let query = HKSampleQuery(sampleType: objType,
                                  predicate: nil,
                                  limit: HKObjectQueryNoLimit,
                                  sortDescriptors: nil) { (query, results, error) in
            guard let results = results as? [HKCategorySample] else {
                completion([], error)
                return
            }
            completion(results, error)
        }
        
        healthStore.execute(query)
    }
    
    public func fetch(_ quantityType: HKQuantityTypeIdentifier,
                      completion: @escaping ([HKQuantitySample], Error?) -> Void) {
        
        guard let type = HKQuantityType.quantityType(forIdentifier: quantityType) else {
            fatalError("Error: Invalid quantity type \(quantityType.description)")
        }
        
        let query = HKSampleQuery(sampleType: type, predicate: nil, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { query, results, error in
            guard let results = results as? [HKQuantitySample] else {
                completion([], error)
                return
            }
            completion(results, error)
        }
        
        healthStore.execute(query)
    }
    
    // MARK: Utility Functions
    
    func preferredUnits(for typeId: HKQuantityTypeIdentifier) async throws -> HKUnit? {
        guard let type = HKQuantityType.quantityType(forIdentifier: typeId) else {
            fatalError("** Failed to get HKQuantityType for \(typeId.description) **")
        }
        
        return try await preferredUnits(for: type)
    }
    
    func preferredUnits(for type: HKQuantityType)  async throws -> HKUnit? {
        return try await withCheckedThrowingContinuation { continuation in
            healthStore.preferredUnits(for: [type]) { dict, error in
                if let error {
                    print("** Failed to get preferred units for \(type.description), Reason: \(error.localizedDescription) **")
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: dict[type])
                }
            }
        }
    }
}
