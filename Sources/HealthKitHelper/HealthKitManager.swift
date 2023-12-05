//
//  HealthKitManager.swift
//  HealthKitHelper
//
//  Created by Rodney Aiglstorfer on 12/2/23.
//

import Foundation
import HealthKit
import Ra9rKit

public class HealthKitManager {
    public static let shared = HealthKitManager()
    
    private var healthStore: HKHealthStore
    
    private init() {
        healthStore = HKHealthStore()
    }
    
    
    // MARK: Setup & Authorization
    
    /// Returns true if HealthKit data is available on this device type, false otherwise.
    public var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    #if !os(watchOS)
    public var supportsHealthRecords: Bool {
        healthStore.supportsHealthRecords()
    }
    #endif
    
    public func isAuthorized(for typeId: HKQuantityTypeIdentifier) -> HKAuthorizationStatus {
        let type = HKObjectType.quantityType(forIdentifier: typeId)!
        return healthStore.authorizationStatus(for: type)
    }
    
    public func isAuthorized(for typeId: HKCategoryTypeIdentifier) -> HKAuthorizationStatus {
        let type = HKCategoryType.categoryType(forIdentifier: typeId)!
        return healthStore.authorizationStatus(for: type)
    }
    
    public func isAuthorized(for typeId: HKCharacteristicTypeIdentifier) -> HKAuthorizationStatus {
        let type = HKCharacteristicType.characteristicType(forIdentifier: typeId)!
        return healthStore.authorizationStatus(for: type)
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
    
    public func requestAuthorization(for typeId: HKCharacteristicTypeIdentifier) async throws {
        var readTypes: Set<HKObjectType> = []
        if let shareType = HKCharacteristicType.characteristicType(forIdentifier: typeId) {
            readTypes = [shareType]
        }
        
        try await healthStore.requestAuthorization(toShare: [], read: readTypes)
    }
    
    public func requestBatchReadAuthorizations(characteristicTypes: Set<HKCharacteristicTypeIdentifier>? = nil,
                                        quantityTypes: Set<HKQuantityTypeIdentifier>? = nil,
                                        categoryTypes: Set<HKCategoryTypeIdentifier>? = nil) async throws {
        var readTypes = Set<HKObjectType>()
        if let characteristicTypes {
            for typeId in characteristicTypes {
                if let type = HKCharacteristicType.characteristicType(forIdentifier: typeId) {
                    readTypes.insert(type)
                }
            }
        }
        
        if let quantityTypes {
            for typeId in quantityTypes {
                if let type = HKQuantityType.quantityType(forIdentifier: typeId) {
                    readTypes.insert(type)
                }
            }
        }
        
        if let categoryTypes {
            for typeId in categoryTypes {
                if let type = HKCategoryType.categoryType(forIdentifier: typeId) {
                    readTypes.insert(type)
                }
            }
        }
        
        try await healthStore.requestAuthorization(toShare: [], read: readTypes)
    }
    
    
    // MARK: Characteristics
    public var biologicalSex: String {
        guard let sex = try? healthStore.biologicalSex().biologicalSex else {
            return "Not Specified"
        }
        switch sex {
            case .notSet:
                return "Not Specified"
            case .female:
                return "Female"
            case .male:
                return "Male"
            default:
                return "Other"
        }
    }
    
    public var bloodType: String {
        guard let bloodType = try? healthStore.bloodType().bloodType else {
            return "Unknown"
        }
        switch bloodType {
            case .aPositive:
                return "A+"
            case .aNegative:
                return "A-"
            case .bPositive:
                return "B+"
            case .bNegative:
                return "B-"
            case .abPositive:
                return "AB+"
            case .abNegative:
                return "AB-"
            case .oPositive:
                return "O+"
            case .oNegative:
                return "O-"
            default:
                return "Unknown"
        }
    }
    
    public var fitzpatrickSkinType: String {
        guard let skinType = try? healthStore.fitzpatrickSkinType().skinType else {
            return "Not Specified"
        }
        switch skinType {
            case .I:
                // Pale white skin, blue/green eyes, blond/red hair
                return "Type I"
            case .II:
                // Fair skin, blue eyes
                return "Type II"
            case .III:
                // Darker white skin
                return "Type III"
            case .IV:
                // Light brown skin
                return "Type IV"
            case .V:
                // Brown skin
                return "Type V"
            case .VI:
                // Dark brown or black skin
                return "Type VI"
            default:
                return "Not Specified"
        }
    }
    
    public var wheelshairUse: Bool {
        guard let wheelChairUse =  try? healthStore.wheelchairUse().wheelchairUse else {
            return false
        }
        switch wheelChairUse {
            case .yes:
                return true
            default:
                return false
        }
    }
    
    // MARK: Save Functions
    
    public func saveCategory(_ typeId: HKCategoryTypeIdentifier,
                      severity: HKCategoryValueSeverity,
                      start: Date, end: Date? = nil) async throws -> HKCategorySample {
        
        let categoryType = HKCategoryType.categoryType(forIdentifier: typeId)!
        
        let sample = HKCategorySample(type: categoryType,
                                      value: severity.rawValue,
                                      start: start, end: end ?? start)
        
        try await healthStore.save(sample)
        
        return sample
        
    }
    
    public func saveQuantity(_ typeId: HKQuantityTypeIdentifier,
                      unit: HKUnit, value: Double,
                      start: Date, end: Date? = nil,
                      metadata: [String : Any]? = nil) async throws -> HKQuantitySample {
        
        let qtyType = HKQuantityType.quantityType(forIdentifier: typeId)!
        
        let qty = HKQuantity(unit: unit, doubleValue: value)
        
        let sample = HKQuantitySample(type: qtyType,
                                      quantity: qty,
                                      start: start, end: end ?? start,
                                      metadata: metadata)
        
        try await healthStore.save(sample)
        
        return sample
    }
    
    // MARK: Fetch Methods
    
    public func fetchSamples(for itemId: HKCategoryTypeIdentifier,
                             since: Date) async -> [HKCategorySample] {
        
        guard let type = HKCategoryType.categoryType(forIdentifier: itemId) else {
            fatalError("Unabled to create HKCategoryType")
        }
        
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: nil, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { query, results, error in
                if let error {
                    print("** Error processing query: \(error.localizedDescription)")
                    continuation.resume(returning: [])
                }
                
                guard let samples = results as? [HKCategorySample] else {
                    continuation.resume(returning: [])
                    return
                }
                
                continuation.resume(returning: samples)
            }
            
            healthStore.execute(query)
        }
        
    }
    
    public func fetchQuantities(for itemId: HKQuantityTypeIdentifier,
                                since: Date) async -> [HKQuantitySample] {
        
        guard let type = HKQuantityType.quantityType(forIdentifier: itemId) else {
            fatalError("Unabled to create HKCategoryType")
        }
        
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: nil, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { query, results, error in
                if let error {
                    print("** Error processing query: \(error.localizedDescription)")
                    continuation.resume(returning: [])
                }
                
                guard let samples = results as? [HKQuantitySample] else {
                    continuation.resume(returning: [])
                    return
                }
                
                continuation.resume(returning: samples)
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: Delete Methods
    
    public func deleteSample(_ object: HKObject) async throws {
        try await healthStore.delete(object)
    }
}


//let shareTypes: Set<HKSampleType> = [
//    HKSampleType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
//    HKSampleType.quantityType(forIdentifier: .bloodPressureSystolic)!,
//    HKSampleType.quantityType(forIdentifier: .heartRate)!,
//    HKSampleType.quantityType(forIdentifier: .bodyTemperature)!,
//    HKSampleType.quantityType(forIdentifier: .bodyMass)!,
//    HKCategoryType.categoryType(forIdentifier: .abdominalCramps)!,
//    HKCategoryType.categoryType(forIdentifier: .acne)!,
//    HKCategoryType.categoryType(forIdentifier: .appetiteChanges)!,
//    HKCategoryType.categoryType(forIdentifier: .bladderIncontinence)!,
//    HKCategoryType.categoryType(forIdentifier: .bloating)!,
//    HKCategoryType.categoryType(forIdentifier: .breastPain)!,
//    HKCategoryType.categoryType(forIdentifier: .chestTightnessOrPain)!,
//    HKCategoryType.categoryType(forIdentifier: .chills)!,
//    HKCategoryType.categoryType(forIdentifier: .constipation)!,
//    HKCategoryType.categoryType(forIdentifier: .coughing)!,
//    HKCategoryType.categoryType(forIdentifier: .diarrhea)!,
//    HKCategoryType.categoryType(forIdentifier: .dizziness)!,
//    HKCategoryType.categoryType(forIdentifier: .drySkin)!,
//    HKCategoryType.categoryType(forIdentifier: .fainting)!,
//    HKCategoryType.categoryType(forIdentifier: .fatigue)!,
//    HKCategoryType.categoryType(forIdentifier: .fever)!,
//    HKCategoryType.categoryType(forIdentifier: .generalizedBodyAche)!,
//    HKCategoryType.categoryType(forIdentifier: .hairLoss)!,
//    HKCategoryType.categoryType(forIdentifier: .headache)!,
//    HKCategoryType.categoryType(forIdentifier: .heartburn)!,
//    HKCategoryType.categoryType(forIdentifier: .hotFlashes)!,
//    HKCategoryType.categoryType(forIdentifier: .lossOfSmell)!,
//    HKCategoryType.categoryType(forIdentifier: .lossOfTaste)!,
//    HKCategoryType.categoryType(forIdentifier: .lowerBackPain)!,
//    HKCategoryType.categoryType(forIdentifier: .memoryLapse)!,
//    HKCategoryType.categoryType(forIdentifier: .moodChanges)!,
//    HKCategoryType.categoryType(forIdentifier: .nausea)!,
//    HKCategoryType.categoryType(forIdentifier: .nightSweats)!,
//    HKCategoryType.categoryType(forIdentifier: .pelvicPain)!,
//    HKCategoryType.categoryType(forIdentifier: .rapidPoundingOrFlutteringHeartbeat)!,
//    HKCategoryType.categoryType(forIdentifier: .runnyNose)!,
//    HKCategoryType.categoryType(forIdentifier: .shortnessOfBreath)!,
//    HKCategoryType.categoryType(forIdentifier: .sinusCongestion)!,
//    HKCategoryType.categoryType(forIdentifier: .sleepChanges)!,
//    HKCategoryType.categoryType(forIdentifier: .soreThroat)!,
//    HKCategoryType.categoryType(forIdentifier: .vomiting)!,
//    HKCategoryType.categoryType(forIdentifier: .wheezing)!
//]
//
//let readTypes: Set<HKObjectType> = [
//    HKCharacteristicType.characteristicType(forIdentifier: .biologicalSex)!,
//    HKCharacteristicType.characteristicType(forIdentifier: .fitzpatrickSkinType)!,
//    HKCharacteristicType.characteristicType(forIdentifier: .bloodType)!,
//    HKCharacteristicType.characteristicType(forIdentifier: .wheelchairUse)!,
//    HKObjectType.workoutType(),
//    HKObjectType.quantityType(forIdentifier: .stepCount)!,
//    HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
//    HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
//    HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
//    HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
//    HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
//    HKObjectType.quantityType(forIdentifier: .heartRate)!,
//    HKObjectType.quantityType(forIdentifier: .basalBodyTemperature)!,
//
//    HKCategoryType.categoryType(forIdentifier: .abdominalCramps)!,
//    HKCategoryType.categoryType(forIdentifier: .acne)!,
//    HKCategoryType.categoryType(forIdentifier: .appetiteChanges)!,
//    HKCategoryType.categoryType(forIdentifier: .bladderIncontinence)!,
//    HKCategoryType.categoryType(forIdentifier: .bloating)!,
//    HKCategoryType.categoryType(forIdentifier: .breastPain)!,
//    HKCategoryType.categoryType(forIdentifier: .chestTightnessOrPain)!,
//    HKCategoryType.categoryType(forIdentifier: .chills)!,
//    HKCategoryType.categoryType(forIdentifier: .constipation)!,
//    HKCategoryType.categoryType(forIdentifier: .coughing)!,
//    HKCategoryType.categoryType(forIdentifier: .diarrhea)!,
//    HKCategoryType.categoryType(forIdentifier: .dizziness)!,
//    HKCategoryType.categoryType(forIdentifier: .drySkin)!,
//    HKCategoryType.categoryType(forIdentifier: .fainting)!,
//    HKCategoryType.categoryType(forIdentifier: .fatigue)!,
//    HKCategoryType.categoryType(forIdentifier: .fever)!,
//    HKCategoryType.categoryType(forIdentifier: .generalizedBodyAche)!,
//    HKCategoryType.categoryType(forIdentifier: .hairLoss)!,
//    HKCategoryType.categoryType(forIdentifier: .headache)!,
//    HKCategoryType.categoryType(forIdentifier: .heartburn)!,
//    HKCategoryType.categoryType(forIdentifier: .hotFlashes)!,
//    HKCategoryType.categoryType(forIdentifier: .lossOfSmell)!,
//    HKCategoryType.categoryType(forIdentifier: .lossOfTaste)!,
//    HKCategoryType.categoryType(forIdentifier: .lowerBackPain)!,
//    HKCategoryType.categoryType(forIdentifier: .memoryLapse)!,
//    HKCategoryType.categoryType(forIdentifier: .moodChanges)!,
//    HKCategoryType.categoryType(forIdentifier: .nausea)!,
//    HKCategoryType.categoryType(forIdentifier: .nightSweats)!,
//    HKCategoryType.categoryType(forIdentifier: .pelvicPain)!,
//    HKCategoryType.categoryType(forIdentifier: .rapidPoundingOrFlutteringHeartbeat)!,
//    HKCategoryType.categoryType(forIdentifier: .runnyNose)!,
//    HKCategoryType.categoryType(forIdentifier: .shortnessOfBreath)!,
//    HKCategoryType.categoryType(forIdentifier: .sinusCongestion)!,
//    HKCategoryType.categoryType(forIdentifier: .sleepChanges)!,
//    HKCategoryType.categoryType(forIdentifier: .soreThroat)!,
//    HKCategoryType.categoryType(forIdentifier: .vomiting)!,
//    HKCategoryType.categoryType(forIdentifier: .wheezing)!
//    ]
