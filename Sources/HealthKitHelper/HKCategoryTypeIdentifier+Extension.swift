//
//  File.swift
//  
//
//  Created by Rodney Aiglstorfer on 12/4/23.
//

import Foundation
import HealthKit

public extension HKCategoryTypeIdentifier {
    
    var description: String {
        return self.rawValue.replacingOccurrences(of: "HKCategoryTypeIdentifier", with: "").titlecase()
    }
    
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

