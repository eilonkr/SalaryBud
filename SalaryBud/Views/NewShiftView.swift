//
//  NewShiftView.swift
//  SalaryBud
//
//  Created by Eilon Krauthammer on 21/02/2020.
//  Copyright © 2020 Eilon Krauthammer. All rights reserved.
//

import SwiftUI

struct NewShiftView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var job: Job
    
    @State private var hours = 3
    
    @State private var start: Date = Date()
    @State private var end: Date = Date()
    
    @State private var salary: Double = 0
    @State private var multiplier: Double = 1.0
    @State private var bonuses: Int = 0
    
    @State private var stepAmount: Double = 1.0
    
    @State private var isShowingAlert: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(localized("s_date_time"))) {
                    DatePicker(selection: Binding<Date>(
                       get: { self.start },
                       set: { self.start = $0
                           if self.end < $0 {
                               self.end = $0
                           }
                       }), in: Date.distantPast...Date.distantFuture) {
                        Text(localized("worked_from"))
                    }
                    
                    DatePicker(selection: $end, in: start ... Date.distantFuture, label: {
                        Text(localized("until"))
                    })
                }
                
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
                    Picker(localized("multiplier"), selection: $multiplier) {
                        ForEach([0.5, 1.0, 1.5, 2.0, 2.5, 3], id: \.self) {
                            Text(String(format: "%.1f", $0))
                        }
                    }
                }
                
                Section {
                    Stepper(localized("bonuses_tips") + " \(currencySymbol)\(bonuses)", value: $bonuses, in: 0 ... .max)
                }
                
                Section {
                    Button(localized("confirm")) {
                        guard self.start != self.end else {
                            self.isShowingAlert = true
                            return
                        }
                        
                        let shift = Job.Shift(startDate: self.start, endDate: self.end, baseSalary: self.salary, multiplier: self.multiplier, bonuses: self.bonuses)
                        self.job.shifts.insert(shift, at: 0)
                        try? Archiver(directory: .jobs).put(self.job, forKey: self.job.id)
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationBarTitle(localized("t_new_shift"))
            .onAppear {
                self.salary = self.job.hourlyPayment
            }
            .alert(isPresented: $isShowingAlert) {
                Alert(title: Text(localized("hey")), message: Text(localized("error_cantadd")), dismissButton: .cancel())
            }
        }
    }
}

struct NewShiftView_Previews: PreviewProvider {
    static var previews: some View {
        NewShiftView().environmentObject(Job())
    }
}
