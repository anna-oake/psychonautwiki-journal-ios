// Copyright (c) 2023. Isaak Hanimann.
// This file is part of PsychonautWiki Journal.
//
// PsychonautWiki Journal is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public Licence as published by
// the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
//
// PsychonautWiki Journal is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with PsychonautWiki Journal. If not, see https://www.gnu.org/licenses/gpl-3.0.en.html.

import SwiftUI

struct CustomUnitsChooseDoseScreen: View {
    let customUnit: CustomUnit
    let dismiss: () -> Void

    @State private var dose: Double?
    @State private var isEstimate = false
    @State private var estimatedDoseStandardDeviation: Double?
    @FocusState private var isDoseFieldFocused: Bool
    @AppStorage(PersistenceController.isEyeOpenKey2) var isEyeOpen = false

    var body: some View {
        Form {
            Section("Pure \(customUnit.administrationRouteUnwrapped.rawValue.capitalized) Dose") {
                VStack(alignment: .leading, spacing: 8) {
                    if let roaDose = customUnit.roaDose {
                        RoaDoseRow(roaDose: roaDose)
                    }
                    CustomUnitCalculationText(
                        customUnit: customUnit,
                        dose: dose,
                        isEstimate: isEstimate,
                        estimatedDoseStandardDeviation: estimatedDoseStandardDeviation)
                    if !(customUnit.substance?.isApproved ?? true) {
                        Text("Info is not approved by PsychonautWiki moderators.")
                    }
                }
            }.listRowSeparator(.hidden)
            Section {
                CustomUnitDosePicker(
                    customUnit: customUnit,
                    dose: $dose,
                    isEstimate: $isEstimate,
                    estimatedDoseStandardDeviation: $estimatedDoseStandardDeviation
                ).focused($isDoseFieldFocused)
            } header: {
                Text(customUnit.nameUnwrapped)
            } footer: {
                if !customUnit.noteUnwrapped.isEmpty {
                    Text(customUnit.noteUnwrapped)
                }
            }
            if let dose, let estimatedDoseStandardDeviation {
                Section {
                    StandardDeviationConfidenceIntervalExplanation(mean: dose, standardDeviation: estimatedDoseStandardDeviation, unit: customUnit.unitUnwrapped)
                }
            }
            if isEyeOpen {
                Section {
                    if let remark = customUnit.substance?.dosageRemark {
                        Text(remark)
                            .foregroundColor(.secondary)
                    }
                    if customUnit.administrationRouteUnwrapped == .smoked || customUnit.administrationRouteUnwrapped == .inhaled {
                        Text(
                            "Depending on your smoking/inhalation method different amounts of substance are lost before entering the body. The dose should reflect the amount of substance that is actually inhaled.")
                    }
                    if customUnit.roaDose?.shouldUseVolumetricDosing ?? false {
                        NavigationLink("Volumetric Dosing Recommended") {
                            VolumetricDosingScreen()
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(value: FinishIngestionScreenArguments(
                    substanceName: customUnit.substanceNameUnwrapped,
                    administrationRoute: customUnit.administrationRouteUnwrapped,
                    dose: dose,
                    units: customUnit.originalUnitUnwrapped,
                    isEstimate: isEstimate,
                    estimatedDoseStandardDeviation: estimatedDoseStandardDeviation,
                    customUnit: customUnit))
                {
                    NextLabel()
                }
            }
        }
        .onAppear {
            isDoseFieldFocused = true
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationBarTitle("\(customUnit.substanceNameUnwrapped) Dose")
    }
}

#Preview {
    NavigationStack {
        CustomUnitsChooseDoseScreen(customUnit: CustomUnit.previewSample, dismiss: { })
    }
}
