//
//  Job.swift
//  SalaryBud
//
//  Created by Eilon Krauthammer on 20/02/2020.
//  Copyright © 2020 Eilon Krauthammer. All rights reserved.
//

import Foundation

class Job: ObservableObject, Codable {
    struct Shift: Codable, Identifiable {
        let id = UUID()
        let startDate, endDate: Date
        let baseSalary: Double
        let multiplier: Double
        let bonuses: Int
        
        /// In hours.
        fileprivate var duration: TimeInterval {
            (endDate.timeIntervalSince1970 - startDate.timeIntervalSince1970) / (60*60)
        }
        
        fileprivate var pureDuration: TimeInterval {
            endDate.timeIntervalSince1970 - startDate.timeIntervalSince1970
        }
        
        /// In hours.
        public var durationString: String {
            pureDuration.timerString
        }
        
        public var totalEarned: Double {
            ((Double(baseSalary) * multiplier) * duration) + Double(bonuses)
        }
    }
    
    @Published var id: String
    @Published var title: String
    @Published var hourlyPayment: Double
    @Published var shifts: [Shift]
    
    init(title: String, hourlyPayment: Double, shifts: [Shift]) {
        self.id = UUID().uuidString
        self.title = title
        self.hourlyPayment = hourlyPayment
        self.shifts = shifts
    }
    
    init() {
        self.id = UUID().uuidString
        self.title = ""
        self.hourlyPayment = 0
        self.shifts = []
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, hourlyPayment, shifts
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(hourlyPayment, forKey: .hourlyPayment)
        try container.encode(shifts, forKey: .shifts)
    }
    
    required init(from decoder: Decoder) throws {
        let container =      try decoder.container(keyedBy: CodingKeys.self)
        self.id =            try container.decode(String.self, forKey: .id)
        self.title =         try container.decode(String.self, forKey: .title)
        self.hourlyPayment = try container.decode(Double.self, forKey: .hourlyPayment)
        self.shifts =        try container.decode([Shift].self, forKey: .shifts)
    }
}

// MARK: - Helpers

extension Job {
    public func totalEarned(in period: Calendar.Component) -> Double {
        let filtered = shifts.filter {
            Calendar.current.isDate($0.startDate, equalTo: Date(), toGranularity: period)
        }
        return filtered.reduce(0) { $0 + $1.totalEarned }
    }
    
    public var totalEarnedAlltime: Double {
        shifts.reduce(0) { $0 + $1.totalEarned }
    }
    
    public var totalEarnedThisMonth: Double {
        let thisMonthShifts = shifts.filter { Calendar.current.isDate($0.startDate, equalTo: Date(), toGranularity: .month) }
        return thisMonthShifts.reduce(0) { $0 + $1.totalEarned }
    }
    
    public var totalNumberOfShifts: Int {
        shifts.count
    }
    
    public var totalHoursWorked: Double {
        shifts.reduce(0) { $0 + $1.duration }
    }
    
    /// In seconds
    public var averageShiftDuration: Double {
        shifts.reduce(0) { $0 + $1.pureDuration } / Double(shifts.count)
    }
    
    public var averageShiftSalary: Double {
        shifts.reduce(0) { $0 + $1.totalEarned } / Double(shifts.count)
    }
    
    public var averageBonuses: Double {
        shifts.reduce(0) { $0 + Double($1.bonuses) } / Double(shifts.count)
    }
    
    // MARK: - Archiving Keys
    
    public var timerKey: String {
        "\(id)-start_date"
    }
    
    public var paymentKey: String {
        "\(id)-payment_info"
    }
 }

