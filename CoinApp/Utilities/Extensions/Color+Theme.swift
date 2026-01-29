//
//  Color+Theme.swift
//  CoinApp
//
//  Цветовая тема приложения.
//

import SwiftUI

extension Color {
    /// Цвет для положительного изменения цены
    static let priceUp = Color.green

    /// Цвет для отрицательного изменения цены
    static let priceDown = Color.red

    /// Основной акцентный цвет приложения
    static let accent = Color.orange

    /// Фоновый цвет для карточек
    static let cardBackground = Color(.systemGray6)
}

extension ShapeStyle where Self == Color {
    /// Цвет в зависимости от направления изменения
    static func priceChange(isPositive: Bool) -> Color {
        isPositive ? .priceUp : .priceDown
    }
}
