//
//  NewJobView.swift
//  SalaryBud
//
//  Created by Eilon Krauthammer on 20/02/2020.
//  Copyright © 2020 Eilon Krauthammer. All rights reserved.
//

import SwiftUI

struct NewJobView: View {
    enum ViewType {
        case newJob, editJob
    }
    
    let viewType: ViewType
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var job: Job
    
    @State private var title: String = ""
    @State private var payment: Double = 30.0
    @State private var stepAmount: Double = 1.0
    
    public var onFinish: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(localized("s_job_title"))) {
                    TextField(localized("p_enter_title"), text: $title)
                }
                
                Section(header: Text(localized("hourly_salary"))) {
                    Stepper(value: $payment, step: stepAmount, onEditingChanged: { _ in }) {
                        Text(payment.currency)
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
                
                Section {
                    Button(localized("save")) {
                        self.job.title = self.title
                        self.job.hourlyPayment = self.payment
                        self.onFinish()
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationBarTitle(viewType == .newJob ? localized("t_new_job") : localized("t_edit_job"))
        }
        .onAppear {
            self.title = self.job.title
            self.payment = self.job.hourlyPayment == 0 ? 30 : self.job.hourlyPayment
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct NewJobView_Previews: PreviewProvider {
    static var previews: some View {
        NewJobView(viewType: .editJob, job: Job(), onFinish: {})
    }
}
