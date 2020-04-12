//
//  ContentView.swift
//  SalaryBud
//
//  Created by Eilon Krauthammer on 20/02/2020.
//  Copyright © 2020 Eilon Krauthammer. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var newJob = Job()
    
    @State private var isPresentingModal: Bool = false
    @State private var isShowingDetail: Bool = false
    @State private var isPresentingShiftView: Bool = false
    @State private var isPresentingCalculator: Bool = false
    
    @State private var detailJob: Job?
    
    @State private var jobs: [Job] = []
    
    private var greeting: String {
        switch Calendar.current.component(.hour, from: Date()) {
            case 0...5:
                return localized("night")
            case 6...11:
                return localized("morning")
            case 12...14:
                return localized("noon")
            case 16...17:
                return localized("afternoon")
            case 18...23:
                return localized("evening")
            default:
                return localized("day")
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    ForEach(jobs, id: \.title) { job in
                        JobCell(job: job, shouldShowDetail: { job in
                            self.detailJob = job
                            self.isShowingDetail = true
                        }, shouldPresentShiftView: { job in
                            self.detailJob = job
                            self.isPresentingShiftView = true
                        })
                        .contextMenu {
                            Button(action: {
                                do {
                                    try Archiver(directory: .jobs).deleteItem(forKey: job.id)
                                    withAnimation {
                                        self.jobs.removeAll { $0.id == job.id }
                                    }
                                } catch { print(error.localizedDescription) }
                            }) {
                                Text(localized("delete"))
                                Image(systemName: "trash")
                            }
                        }
                    }
                    
                    // Add-New-Job cell
                    HStack {
                        Button(action: {
                            self.isPresentingModal.toggle()
                        }) {
                            VStack(spacing: 12) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                                Text(localized("new_job"))
                                    .font(.subheadline)
                            }
                            .padding(.top, 4)
                        }
                        .frame(maxWidth: .infinity)
                        .modifier(CellStyle())
                        .sheet(isPresented: $isPresentingModal) {
                            NewJobView(viewType: .newJob, job: self.newJob, onFinish: {
                                do {
                                    try Archiver(directory: .jobs).put(self.newJob, forKey: self.newJob.id)
                                    self.jobs.insert(self.newJob, at: 0)
                                } catch {
                                    print(error)
                                }
                            })
                        }
                    }
                }
                
                NavigationLink(destination: JobDetailView(isPushed: $isShowingDetail).environmentObject(detailJob ?? Job()), isActive: $isShowingDetail) {
                    Text("")
                    .hidden()
                }
            }
            .navigationBarTitle(greeting)
            .navigationBarItems(trailing: Button(action: {
                self.isPresentingCalculator = true
            }) { Image("icncalc") }
                .padding()
            .sheet(isPresented: $isPresentingCalculator) {
                CalculatorView()
            })
            .sheet(isPresented: $isPresentingShiftView) {
                ShiftView().environmentObject(self.detailJob ?? Job())
            }
            .onAppear(perform: fetchJobs)
            .modifier(AppTheme())
            .edgesIgnoringSafeArea(.bottom)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func fetchJobs() {
        guard let jobs = try? Archiver(directory: .jobs).all(Job.self) else { return }
        self.jobs = jobs.reversed()
        
        if let timerFiles = try? Archiver(directory: .timer).allFiles() {
            for file in timerFiles {
                for job in jobs {
                    if file.lastPathComponent == job.timerKey {
                        self.detailJob = job
                        self.isPresentingShiftView.toggle()
                        return
                    }
                }
            }
        }
    }
}

struct JobCell: View {
    let job: Job
    let shouldShowDetail: (Job) -> Void
    let shouldPresentShiftView: (Job) -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8.0) {
                Text(job.title)
                    .font(.system(size: 20.0)).bold()
                HStack {
                    Text(localized("total_month") + ":")
                    Text(job.totalEarnedThisMonth.currency).bold()
                }
                Text(localized("last_shift") + ": \(job.shifts.first?.startDate.dateFormat() ?? "--")")
                    .font(.subheadline)
                    .foregroundColor(Color.secondary)
            }
            Spacer()
            Button(action: {
                self.shouldPresentShiftView(self.job)
            }) {
                VStack() {
                    Image(systemName: "play.circle.fill").flipsForRightToLeftLayoutDirection(true)
                        .font(.title)
                    Text(localized("shift"))
                        .font(.subheadline)
                        .frame(width: 60.0)
                        .multilineTextAlignment(.center)
                }
                .foregroundColor(Color(.systemIndigo))
            }
        }
        .modifier(CellStyle())
        .onTapGesture {
            self.shouldShowDetail(self.job)
        }
    }
}

struct CellStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.quaternarySystemFill))
            .cornerRadius(16)
            .padding(.horizontal, 20.0)
            .padding(.vertical, 8.0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
