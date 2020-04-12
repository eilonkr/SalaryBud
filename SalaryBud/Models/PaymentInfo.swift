//
//  PaymentInfo.swift
//  SalaryBud
//
//  Created by Eilon Krauthammer on 23/02/2020.
//  Copyright © 2020 Eilon Krauthammer. All rights reserved.
//

import Foundation

class PaymentInfo: ObservableObject, Codable {
    @Published var salary:     Double = 0
    @Published var multiplier: Double = 1
    @Published var bonuses:    Double = 0
    
    public var hourly: Double { (salary * multiplier) }
    
    init() {}
    
    private enum CodingKeys: String, CodingKey {
        case salary, multiplier, bonuses
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(salary, forKey: .salary)
        try container.encode(multiplier, forKey: .multiplier)
        try container.encode(bonuses, forKey: .bonuses)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.salary = try container.decode(Double.self, forKey: .salary)
        self.multiplier =  try container.decode(Double.self, forKey: .multiplier)
        self.bonuses = try container.decode(Double.self, forKey: .bonuses)
    }
    
    public func set(with other: PaymentInfo) {
        self.salary = other.salary
        self.multiplier = other.multiplier
        self.bonuses = other.bonuses
    }

}
