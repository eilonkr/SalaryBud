//
//  EditPaymentView.swift
//  SalaryBud
//
//  Created by Eilon Krauthammer on 23/02/2020.
//  Copyright © 2020 Eilon Krauthammer. All rights reserved.
//

import SwiftUI

struct EditPaymentView: View {
    @ObservedObject var paymentInfo: PaymentInfo
    
    let paymentKey: String
    @Binding var isPushed: Bool
    
    @State private var salary: Double = 0
    @State private var stepAmount: Double = 1
    @State private var multiplier: Double = 1
    @State private var bonuses: Int = 0
    
    var body: some View {
        Form {
            Section(header: Text(localized("hourly_salary")), footer:
            Text(localized("multiplier_info"))) {
                Stepper(value: $salary, step: stepAmount, onEditingChanged: { _ in }) {
                    Text(salary.currency)
                        .font(.headline)
                }
                VStack(alignment: .leading) {
                    Text(localized("step_amount"))
                        .font(.subheadline)
                    Picker(selection: $stepAmount, label: Text("")) {
                        ForEach([0.1, 0.5, 1.0, 5.0, 10.0], id: \.self) { n in
                            Text("\(n.string)")
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                VStack(alignment: .leading) {
                    Text(localized("multiplier"))
                    Picker(localized("multiplier"), selection: $multiplier) {
                        ForEach([0.5, 1.0, 1.5, 2.0, 2.5, 3], id: \.self) {
                            Text($0.string)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(.top, 8.0)
            }
            
            Section {
                Stepper(localized("bonuses_tips") + " \(currencySymbol)\(bonuses)", value: $bonuses, in: 0 ... .max)
            }
            
            Section {
                Button(localized("confirm")) {
                    self.paymentInfo.salary = self.salary
                    self.paymentInfo.multiplier = self.multiplier
                    self.paymentInfo.bonuses = Double(self.bonuses)
                    try? Archiver(directory: .payment).put(self.paymentInfo, forKey: self.paymentKey)
                    self.isPushed = false
                }
            }
        }
        .onAppear {
            self.salary = self.paymentInfo.salary
            self.multiplier = self.paymentInfo.multiplier
            self.bonuses = Int(self.paymentInfo.bonuses)
            
        }
        .navigationBarTitle(localized("edit"))
    }
}

