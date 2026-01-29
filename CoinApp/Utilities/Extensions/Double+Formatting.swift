//
//  Double+Formatting.swift
//  CoinApp
//
//  Расширения для форматирования чисел.
//

import Foundation

extension Double {
    /// Форматирование цены с автоматическим выбором точности
    /// Для маленьких чисел показываем больше знаков после запятой
    var asCurrencyString: String {
        if self < 0.01 {
            return "$" + self.formatted(.number.precision(.significantDigits(4)))
        } else if self < 1 {
            return "$" + self.formatted(.number.precision(.fractionLength(4)))
        } else {
            return "$" + self.formatted(.number.precision(.fractionLength(2)))
        }
    }

    /// Форматирование процентного изменения
    var asPercentageString: String {
        let sign = self >= 0 ? "+" : ""
        return sign + self.formatted(.number.precision(.fractionLength(2))) + "%"
    }

    /// Форматирование больших чисел с сокращениями (K, M, B, T)
    var asAbbreviatedString: String {
        let trillion = 1_000_000_000_000.0
        let billion = 1_000_000_000.0
        let million = 1_000_000.0
        let thousand = 1_000.0

        switch self {
        case trillion...:
            return "$" + (self / trillion).formatted(.number.precision(.fractionLength(2))) + "T"
        case billion...:
            return "$" + (self / billion).formatted(.number.precision(.fractionLength(2))) + "B"
        case million...:
            return "$" + (self / million).formatted(.number.precision(.fractionLength(2))) + "M"
        case thousand...:
            return "$" + (self / thousand).formatted(.number.precision(.fractionLength(2))) + "K"
        default:
            return "$" + self.formatted(.number.precision(.fractionLength(2)))
        }
    }
}
