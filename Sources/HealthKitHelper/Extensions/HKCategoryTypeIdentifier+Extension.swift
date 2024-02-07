//
//  HKCategoryTypeIdentifier+Extension.swift
//
//
//  Created by Rodney Aiglstorfer on 12/4/23.
//

import Foundation
import HealthKit
import Ra9rCore

public extension HKCategoryTypeIdentifier {
    
    /// Convinient user-facing description for the `HKCategoryTypeIdentifier` that formats the `rawValue`
    var description: String {
        return self.rawValue.replacingOccurrences(of: "HKCategoryTypeIdentifier", with: "").titlecase()
    }
    
    /// Returns a subset of `HKCategoryTypeIdentifier` that are specifically symptom related.
    static var symptoms: [HKCategoryTypeIdentifier] {
        return [.abdominalCramps,
                .acne,
                .appetiteChanges,
                .bladderIncontinence,
                .bloating,
                .breastPain,
                .chestTightnessOrPain,
                .chills,
                .constipation,
                .coughing,
                .diarrhea,
                .dizziness,
                .drySkin,
                .fainting,
                .fatigue,
                .fever,
                .generalizedBodyAche,
                .hairLoss,
                .headache,
                .heartburn,
                .hotFlashes,
                .lossOfSmell,
                .lossOfTaste,
                .lowerBackPain,
                .memoryLapse,
                .moodChanges,
                .nausea,
                .nightSweats,
                .pelvicPain,
                .rapidPoundingOrFlutteringHeartbeat,
                .runnyNose,
                .shortnessOfBreath,
                .sinusCongestion,
                .sleepChanges,
                .soreThroat,
                .vomiting,
                .wheezing]
    }
}

