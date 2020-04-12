//
//  CalculatorView.swift
//  SalaryBud
//
//  Created by Eilon Krauthammer on 23/02/2020.
//  Copyright © 2020 Eilon Krauthammer. All rights reserved.
//

import SwiftUI

struct CalculatorView: View {
    @State private var stepAmount: Double = 1.0
    @State private var salary: Double = 30.0
    @State private var weeklyShifts: Int = 4
    @State private var hoursPerShift: Int = 7
    
    private var weeklySalary: Double {
        salary * Double(weeklyShifts) * Double(hoursPerShift)
    }
    
    private var monthlySalary: Double {
        (weeklySalary * 52) / 12
    }
    
    private var yearlySalary: Double {
        weeklySalary * 52
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(localized("hourly_salary"))) {
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
                }
                
                Section(header: Text(localized("shift_info"))) {
                    Picker(selection: $weeklyShifts, label: Text(localized("weekly_shifts"))) {
                        ForEach(1...7, id: \.self) { Text("\($0)") }
                    }
                    Picker(selection: $hoursPerShift, label: Text(localized("hours_per_shift"))) {
                        ForEach(1...20, id: \.self) { Text("\($0)") }
                    }
                }
                
                Section(header: Text(localized("result"))) {
                    Text(localized("weekly") + ": \(weeklySalary.currency)")
                    Text(localized("monthly") + ": \(monthlySalary.currency)")
                    Text(localized("yearly") + ": \(yearlySalary.currency)")
                }
            }
            .navigationBarTitle(localized("salary_calc"))
        }
    }
}

struct CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorView()
    }
}
