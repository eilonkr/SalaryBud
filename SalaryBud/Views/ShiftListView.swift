//
//  ShiftListView.swift
//  SalaryBud
//
//  Created by Eilon Krauthammer on 20/02/2020.
//  Copyright © 2020 Eilon Krauthammer. All rights reserved.
//

import SwiftUI

struct ShiftListView: View {
    @EnvironmentObject var job: Job
    
    var body: some View {
        List {
            ForEach(0..<job.shifts.count, id: \.self) { index in
                ShiftCell(hash: self.job.shifts.count-1 - index, shift: self.job.shifts[index])
            }
            .onDelete(perform: removeRows)
        }
        .navigationBarTitle(localized("t_shifts"))
        .navigationBarItems(trailing: EditButton())
    }
    
    func removeRows(at offsets: IndexSet) {
        job.shifts.remove(atOffsets: offsets)
        try? Archiver(directory: .jobs).put(job, forKey: job.id)
    }
}

struct ShiftCell: View {
    let hash: Int
    let shift: Job.Shift
    
    var body: some View {
        HStack {
            HStack(spacing: 20.0) {
                Text("\(hash+1)").bold()
                VStack(alignment: .leading, spacing: 8.0) {
                    Text(shift.startDate.dateFormat())
                    VStack(alignment: .leading) {
                        Text(localized("salary") + "  \(shift.baseSalary.currency)/\(localized("hrs"))")
                        Text(localized("bonuses") + " \(currencySymbol)\(shift.bonuses)")
                    }
                    .font(.subheadline)
                    .foregroundColor(Color.secondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(localized("duration") + " " + shift.durationString)
                    .foregroundColor(Color(.systemIndigo))
                Spacer()
                Text(localized("total") + " \(shift.totalEarned.currency)")
                    .font(.headline)
            }
        }
        .padding(.vertical, 8.0)
    }
}

struct ShiftListView_Previews: PreviewProvider {
    static var previews: some View {
        ShiftListView().environmentObject(Job())
    }
}
