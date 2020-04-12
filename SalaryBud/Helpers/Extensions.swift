//
//  Extensions.swift
//  SalaryBud
//
//  Created by Eilon Krauthammer on 21/02/2020.
//  Copyright © 2020 Eilon Krauthammer. All rights reserved.
//

import Foundation

func localized(_ key: String, comment: String? = nil) -> String {
    NSLocalizedString(key, comment: comment ?? "")
}

extension Date {
    enum FormatStyle { case regular, short }

    var timeFormat: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "H:mm"
        return formatter.string(from: self)
    }

    func dateFormat() -> String {
        if Calendar.current.isDateInToday(self) {
            return "\(localized("today"))" + ", " + timeFormat
        } else if Calendar.current.isDateInYesterday(self) {
            return "\(localized("yesterday"))" + ", " + timeFormat
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: self)
        }
    }
}

extension Double {
    var string: String {
        guard !isNaN else { return "0" }
        return String(format: "%.1f", self)
    }
    
    var currency: String {
        guard !isNaN else { return Double(0).currency }
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.currency
        numberFormatter.maximumFractionDigits = 1
        return numberFormatter.string(from: NSNumber(value: self)) ?? ""
    }
}

extension TimeInterval {
    var timerString: String {
        guard isFinite else { return "--" }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional // Use the appropriate positioning for the current locale
        formatter.allowedUnits = [.hour, .minute, .second] // Units to display in the formatted string
        formatter.zeroFormattingBehavior = .default // Pad with zeroes where appropriate for the locale
        return formatter.string(from: self) ?? "0:00"
    }
    
    func timerString(chopped: Bool = true, decimalPlaces: Bool = false) -> String {
        guard !self.isNaN else { return "0:00" }
        let hours = Int(self / (60*60))
        let minutes = Int((self - (Double((hours*60*60)))) / 60)
        
        let deci = (self - (Double((hours*60*60)) + Double((minutes*60))))
        let seconds = Int(deci)
        
        var str = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
        
        if decimalPlaces, self != .zero {
            let miliseconds = Int(deci.truncatingRemainder(dividingBy: max(Double(seconds), 1)) * 10)
            print(miliseconds)
            str.append(String(format: ":%i", miliseconds))
        }
        
        if !chopped { return str }
        
        var chopCount = 0
        if hours == 0 {
            chopCount += 3
        } else if String(hours).count < 2 {
            chopCount += 1
        }
        
        if String(minutes).count == 1 {
            chopCount += 1
        }
        
        str = str.chopPrefix(chopCount)
        
        return str
    }
}


extension String {
    func chopPrefix(_ count: Int = 1) -> String {
        if count >= 0 && count <= self.count {
            let indexStartOfText = self.index(self.startIndex, offsetBy: count)
            return String(self[indexStartOfText...])
        }
        return ""
    }

    func chopSuffix(_ count: Int = 1) -> String {
        if count >= 0 && count <= self.count {
            let indexEndOfText = self.index(self.endIndex, offsetBy: -count)
            return String(self[..<indexEndOfText])
        }
        return ""
    }
}

// The Graveyard

//public extension View {
//    /// Creates an `ActionSheet` on an iPhone or the equivalent `popover` on an iPad, in order to work around `.actionSheet` crashing on iPad (`FB7397761`).
//    ///
//    /// - Parameters:
//    ///     - isPresented: A `Binding` to whether the action sheet should be shown.
//    ///     - content: A closure returning the `PopSheet` to present.
//    func popSheet(isPresented: Binding<Bool>, arrowEdge: Edge = .bottom, content: @escaping () -> PopSheet) -> some View {
//        Group {
//            if UIDevice.current.userInterfaceIdiom == .pad {
//                popover(isPresented: isPresented, attachmentAnchor: .rect(.bounds), arrowEdge: arrowEdge, content: { content().popover(isPresented: isPresented) })
//            } else {
//                actionSheet(isPresented: isPresented, content: { content().actionSheet() })
//            }
//        }
//    }
//}
//
///// A `Popover` on iPad and an `ActionSheet` on iPhone.
//public struct PopSheet {
//    let title: Text
//    let message: Text?
//    let buttons: [PopSheet.Button]
//
//    /// Creates an action sheet with the provided buttons.
//    public init(title: Text, message: Text? = nil, buttons: [PopSheet.Button] = [.cancel()]) {
//        self.title = title
//        self.message = message
//        self.buttons = buttons
//    }
//
//    /// Creates an `ActionSheet` for use on an iPhone device
//    func actionSheet() -> ActionSheet {
//        ActionSheet(title: title, message: message, buttons: buttons.map({ popButton in
//            // convert from PopSheet.Button to ActionSheet.Button (i.e., Alert.Button)
//            switch popButton.kind {
//            case .default: return .default(popButton.label, action: popButton.action)
//            case .cancel: return .cancel(popButton.label, action: popButton.action)
//            case .destructive: return .destructive(popButton.label, action: popButton.action)
//            }
//        }))
//    }
//
//    /// Creates a `.popover` for use on an iPad device
//    func popover(isPresented: Binding<Bool>) -> some View {
//        VStack {
//            ForEach(Array(buttons.enumerated()), id: \.offset) { (offset, button) in
//                Group {
//                    SwiftUI.Button(action: {
//                        // hide the popover whenever an action is performed
//                        isPresented.wrappedValue = false
//                        // another bug: if the action shows a sheet or popover, it will fail unless this one has already been dismissed
//                        DispatchQueue.main.async {
//                            button.action?()
//                        }
//                    }, label: {
//                        button.label.font(.title)
//                    })
//                    Divider()
//                }
//            }
//        }
//    }
//
//    /// A button representing an operation of an action sheet or popover presentation.
//    ///
//    /// Basically duplicates `ActionSheet.Button` (i.e., `Alert.Button`).
//    public struct Button {
//        let kind: Kind
//        let label: Text
//        let action: (() -> Void)?
//        enum Kind { case `default`, cancel, destructive }
//
//        /// Creates a `Button` with the default style.
//        public static func `default`(_ label: Text, action: (() -> Void)? = {}) -> Self {
//            Self(kind: .default, label: label, action: action)
//        }
//
//        /// Creates a `Button` that indicates cancellation of some operation.
//        public static func cancel(_ label: Text, action: (() -> Void)? = {}) -> Self {
//            Self(kind: .cancel, label: label, action: action)
//        }
//
//        /// Creates an `Alert.Button` that indicates cancellation of some operation.
//        public static func cancel(_ action: (() -> Void)? = {}) -> Self {
//            Self(kind: .cancel, label: Text("Cancel"), action: action)
//        }
//
//        /// Creates an `Alert.Button` with a style indicating destruction of some data.
//        public static func destructive(_ label: Text, action: (() -> Void)? = {}) -> Self {
//            Self(kind: .destructive, label: label, action: action)
//        }
//    }
//}
