//
//  JobDetail.swift
//  SalaryBud
//
//  Created by Eilon Krauthammer on 20/02/2020.
//  Copyright © 2020 Eilon Krauthammer. All rights reserved.
//

import SwiftUI

struct JobDetailView: View {
    @EnvironmentObject var job: Job
    
    @Binding var isPushed: Bool
    
    @State private var shouldShowEarnings: Bool = true
    @State private var shouldShowShiftInfo: Bool  = true
    
    @State private var isPresentingNewShiftModal: Bool = false
    @State private var isPresentingEditingModal: Bool = false
    @State private var isShowingActionSheet: Bool = false
    @State private var isPresentingShiftView: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16.0) {
                Text(localized("start_shift"))
                    .font(.title).bold()
                    .padding(.top, 20.0)
                Button(action: {
                    self.isPresentingShiftView.toggle()
                }) {
                    Image(systemName: "play.circle.fill").flipsForRightToLeftLayoutDirection(true)
                }
                .font(.system(size: 72.0))
                .foregroundColor(.pink)
                .padding()
                .sheet(isPresented: $isPresentingShiftView) {
                    ShiftView().environmentObject(self.job)
                }
                
                Button(action: {
                    self.isPresentingNewShiftModal.toggle()
                }) {
                    Image(systemName: "pencil")
                    Text(localized("add_manually"))
                        .bold()
                    
                }
                .foregroundColor(Color(.systemIndigo))
                    
                Divider()
                
                VStack {
                    HStack {
                        Text(localized("info"))
                            .font(.title).bold()
                        Spacer()
                    }
                    
                    HStack {
                        NavigationLink(destination: ShiftListView()) {
                            HStack {
                                Text(localized("view_shift_history"))
                                Image(systemName: "chevron.right").flipsForRightToLeftLayoutDirection(true)
                            }
                            .foregroundColor(Color.green)
                        }
                        Spacer()
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 8.0) {
                            // General
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16.0) {
                                    InfoObject(info: "\(job.hourlyPayment.currency)", infoLabel: localized("salary") + " / \(localized("hrs"))")
                                    InfoObject(info: "\(job.totalNumberOfShifts)", infoLabel: localized("number_shifts"))
                                    InfoObject(info: job.totalHoursWorked.string, infoLabel: localized("total_hours"))
                                }
                                .padding(.vertical)
                            }
                            .flipsForRightToLeftLayoutDirection(true)
            
                            // Earnings
                            SectionButton(binding: $shouldShowEarnings, title: localized("earnings_info"))
                            if shouldShowEarnings {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16.0) {
                                        InfoObject(info: job.totalEarned(in: .weekOfYear).currency, infoLabel: localized("total_week"))
                                        InfoObject(info: job.totalEarned(in: .month).currency, infoLabel: localized("total_month"))
                                        InfoObject(info: job.totalEarned(in: .year).currency, infoLabel: localized("total_year"))
                                        InfoObject(info: job.totalEarnedAlltime.currency, infoLabel: localized("total_alltime"))
                                    }
                                    .padding(.vertical)
                                }
                                .flipsForRightToLeftLayoutDirection(true)
                            }
                            
                            // Shifts
                            SectionButton(binding: $shouldShowShiftInfo, title: localized("shifts_info"))
                            if shouldShowShiftInfo {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16.0) {
                                        InfoObject(info: job.averageShiftDuration.timerString, infoLabel: localized("average_shift_duration"))
                                        InfoObject(info: job.averageShiftSalary.currency, infoLabel: localized("average_shift_salary"))
                                        InfoObject(info: job.averageBonuses.currency, infoLabel: localized("average_shift_bonuses"))
                                    }
                                    .padding(.vertical)
                                }
                                .flipsForRightToLeftLayoutDirection(true)
                            }
                        }
                        Spacer()
                    }
                }
                .padding([.top, .leading])
            }
        }
        .navigationBarTitle(job.title)
        .navigationBarItems(trailing: Button(action: {
            self.isShowingActionSheet.toggle()
        }) {
            Image(systemName: "ellipsis")
                .font(.system(size: 24.0))
        }.padding()
            .sheet(isPresented: $isPresentingNewShiftModal) { NewShiftView().environmentObject(self.job) }
        )
        .sheet(isPresented: $isPresentingEditingModal) {
            NewJobView(viewType: .editJob, job: self.job, onFinish: {
                try? Archiver(directory: .jobs).put(self.job, forKey: self.job.id)
            })
        }
        .actionSheet(isPresented: $isShowingActionSheet) {
            ActionSheet(title: Text(self.job.title), buttons: [
                .default(Text(localized("edit"))) {
                    self.isPresentingEditingModal.toggle()
                },
                .destructive(Text(localized("delete"))) {
                    do {
                        try Archiver(directory: .jobs).deleteItem(forKey: self.job.id)
                        self.isPushed = false
                    } catch {
                        print(error.localizedDescription)
                    }
                },
                .cancel()
            ])
        }
    }
}

struct SectionButton: View {
    @Binding var binding: Bool
    let title: String
    
    var body: some View {
        Button(action: {
            withAnimation {
                self.binding.toggle()
            }
        }) {
            HStack {
                Text(title)
                    .font(.headline)
                Image(systemName: "chevron.\(binding ? "up" : "down")")
            }
        }
    }
}

struct InfoObject: View {
    let info: String
    let infoLabel: String
    
    private let width: CGFloat = 125.0
    private let height: CGFloat = 90
    
    var body: some View {
        VStack(spacing: 8.0) {
            Text(info)
                .font(.system(size: 22.0, weight: .bold, design: .rounded))
                .bold()
            Text(infoLabel)
                .foregroundColor(.secondary)
                .font(.system(size: UIFont.systemFontSize, weight: .regular, design: .rounded))
                .multilineTextAlignment(.center)
        }
        .padding(8.0)
        .frame(width: width, height: height)
        .background(Color(.quaternarySystemFill))
        .cornerRadius(8.0)
        .transformEffect(.init(scaleX: isHE ? -1 : 1.0, y: 1))
        .offset(x: isHE ? width : 0)
    }
}

struct JobDetailView_Previews: PreviewProvider {
    @State static var isPushed: Bool = true
    static var previews: some View {
        JobDetailView(isPushed: $isPushed).environmentObject(Job())
    }
}

