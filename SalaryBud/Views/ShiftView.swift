//
//  ShiftView.swift
//  SalaryBud
//
//  Created by Eilon Krauthammer on 22/02/2020.
//  Copyright © 2020 Eilon Krauthammer. All rights reserved.
//

import SwiftUI

struct ShiftView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var job: Job
    
    @State private var isTimerRunning: Bool = false
    @State private var duration: TimeInterval = 0
    @State private var startDate: Date?
    
    @ObservedObject var paymentInfo: PaymentInfo = PaymentInfo()
    
    @State private var isShowingEditingView: Bool = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 20.0) {
                        Text(job.title)
                            .font(.headline)
                        Text("\(duration.timerString())")
                            .font(.largeTitle)
                            .foregroundColor(Color(.systemIndigo))
                            .frame(width: 150, height: 150)
                            .overlay(
                                Circle().stroke(Color(.systemIndigo), lineWidth: 2.0)
                            )
                            .onReceive(timer) { _ in
                                if self.isTimerRunning {
                                    self.duration += 1
                                }
                            }
                    }
                    .padding(.top, 30.0)
                    
                    if isTimerRunning {
                        HStack {
                            ActionButton(action: .cancel, onAction: {
                                do {
                                    try self.deleteCache()
                                    self.presentationMode.wrappedValue.dismiss()
                                } catch {
                                    print(error)
                                }
                            })
                            
                            ActionButton(action: .finish, onAction: {
                                do {
                                    guard let startDate = self.startDate else { return }
                                    let shift = Job.Shift(startDate: startDate, endDate: Date(), baseSalary: self.paymentInfo.salary, multiplier: self.paymentInfo.multiplier, bonuses: Int(self.paymentInfo.bonuses))
                                    self.job.shifts.insert(shift, at: 0)
                                    try Archiver(directory: .jobs).put(self.job, forKey:  self.job.id)
                                    try self.deleteCache()
                                    self.presentationMode.wrappedValue.dismiss()
                                } catch {
                                    print(error.localizedDescription)
                                }
                            })
                        }
                        
                        VStack(spacing: 8.0) {
                            Text(localized("started_at") + " \(startDate?.dateFormat() ?? "--")")
                            Text(localized("earned_sofar") + " \(((paymentInfo.hourly * (duration / 60 / 60)) + paymentInfo.bonuses).currency)")
                        }
                        .foregroundColor(Color.secondary)
                        .font(.subheadline)
                    } else {
                        Button(action: {
                            do {
                                try Archiver(directory: .timer).put(Date(), forKey: self.job.timerKey)
                                self.startDate = Date()
                                withAnimation {
                                    self.isTimerRunning = true
                                }
                            } catch { print(error) }
                        }) {
                            HStack(spacing: 20.0) {
                                Image(systemName: "play.fill").flipsForRightToLeftLayoutDirection(true)
                                Text("\(localized("start"))")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.vertical, 8.0)
                            .background(Color(.systemIndigo))
                            .clipShape(RoundedRectangle(cornerRadius: 8.0))
                            .shadow(radius: 3.0, x: 0, y: 1)
                        }
                    }
                    
                    Divider().padding(.horizontal, 20.0)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 8.0) {
                            HStack(alignment: .top) {
                                Text(localized("payment_info"))
                                    .font(.headline)
                                Spacer()
                                NavigationLink(localized("edit"), destination: EditPaymentView(paymentInfo: paymentInfo, paymentKey: self.job.paymentKey, isPushed: $isShowingEditingView), isActive: $isShowingEditingView)
                            }
                            Text(localized("salary") + ": \(paymentInfo.salary.currency)")
                            Text(localized("multiplier") + ": \(paymentInfo.multiplier.string)")
                            Text(localized("bonuses_tips") + " \(paymentInfo.bonuses.currency)")
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20.0)
                }
            }
            .navigationBarTitle(localized("t_active_shift"))
            .onAppear {
                if self.paymentInfo.salary == 0 {
                    self.paymentInfo.salary = self.job.hourlyPayment
                }
                
                self.setActiveTimer()
                self.observeAppStatus()
            }
            .onDisappear {
                if !self.isTimerRunning {
                    try? Archiver(directory: .payment).deleteItem(forKey: self.job.paymentKey)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Functions
    
    private func setActiveTimer() {
        if let date = self.getStartDate() {
            self.startDate = date
            self.duration = Date().timeIntervalSince1970 - date.timeIntervalSince1970
            self.isTimerRunning = true
            
            if let paymentInfo = getPaymentInfo() {
                self.paymentInfo.set(with: paymentInfo)
            }
        }
    }
    
    private func getStartDate() -> Date? {
        if let timerFiles = try? Archiver(directory: .timer).allFiles() {
            for file in timerFiles {
                let path = file.lastPathComponent
                if path == self.job.timerKey {
                    guard let data = try? Data(contentsOf: file) else { return nil }
                    if let date = try? JSONDecoder().decode(Date.self, from: data) {
                        return date
                    }
                }
            }
        }
        
        return .none
    }
    
    private func getPaymentInfo() -> PaymentInfo? {
        for file in (try? Archiver(directory: .payment).allFiles()) ?? [] {
            let path = file.lastPathComponent
            if path == self.job.paymentKey {
                guard let data = try? Data(contentsOf: file) else { return nil }
                if let pi = try? JSONDecoder().decode(PaymentInfo.self, from: data) {
                    self.paymentInfo.set(with: pi)
                }
            }
        }
        
        return .none
    }
    
    private func deleteCache() throws {
        try Archiver(directory: .timer).deleteItem(forKey: self.job.timerKey)
        try Archiver(directory: .payment).deleteItem(forKey: self.job.paymentKey)
    }

    private func observeAppStatus() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name("didBecomeActive"), object: nil, queue: nil) { _ in
            self.setActiveTimer()
        }
    }
}

struct ActionButton: View {
    enum Action: CaseIterable {
        case finish, cancel
        fileprivate var imageName: String {
            switch self {
                case .finish: return "checkmark.circle.fill"
                case .cancel: return "xmark.circle.fill"
            }
        }
    }
    
    let action: Action
    let onAction: () -> Void
    
    var body: some View {
        Button(action: {
            self.onAction()
        }) {
            Image(systemName: action.imageName)
        }
        .padding(20.0)
        .background(Color(.secondarySystemBackground))
        .foregroundColor(Color(.systemIndigo))
        .font(Font.system(size: 30.0))
        .clipShape(Circle())
    }
}

struct ShiftView_Previews: PreviewProvider {
    static var previews: some View {
        ShiftView().environmentObject(Job())
    }
}

