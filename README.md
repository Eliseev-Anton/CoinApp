# CoinApp

Pet-проект на SwiftUI для отслеживания криптовалют.

## Особенности

- **SwiftUI** + **MVVM** архитектура
- **@Observable** макрос (iOS 17+)
- **Async/Await** для асинхронных операций
- **CoreData** для хранения избранных монет
- **SwiftUI Charts** для графиков
- **Unit-тесты** для ViewModel и сервисов

## Требования

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Установка

### Шаг 1: Создание проекта в Xcode

1. Откройте Xcode
2. File → New → Project
3. Выберите "App" (iOS)
4. Настройки:
   - Product Name: `CoinApp`
   - Team: Ваш Apple ID
   - Organization Identifier: `com.yourname`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **None** (CoreData создаем программно)
   - ✅ Include Tests
5. Сохраните проект в папку `~/CoinApp`

### Шаг 2: Структура папок

Создайте следующую структуру папок в Xcode (правый клик → New Group):

```
CoinApp/
├── App/
├── Models/
├── ViewModels/
├── Views/
│   └── Components/
├── Services/
├── CoreData/
├── Utilities/
│   └── Extensions/
└── Resources/
```

### Шаг 3: Добавление файлов

1. Удалите автосгенерированный `ContentView.swift`
2. Перетащите все `.swift` файлы из соответствующих папок в Xcode
3. Убедитесь, что все файлы добавлены в target `CoinApp`

### Шаг 4: Настройка Info.plist

Добавьте разрешение для сетевых запросов (если нужно для HTTP):

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### Шаг 5: Тесты

1. Перетащите файлы из `CoinAppTests/` в target тестов
2. Убедитесь, что тестовые файлы имеют доступ к главному модулю (`@testable import CoinApp`)

## Архитектура

### MVVM

```
View ←→ ViewModel ←→ Service ←→ API/CoreData
```

- **View**: SwiftUI views, только UI логика
- **ViewModel**: Бизнес-логика, использует `@Observable`
- **Service**: Работа с данными (сеть, CoreData)

### Состояния экрана

```swift
enum ViewState<T> {
    case idle      // Начальное состояние
    case loading   // Загрузка
    case loaded(T) // Данные загружены
    case error(Error) // Ошибка
    case empty     // Пустые данные
}
```

### Структура файлов

```
CoinApp/
├── App/
│   └── CoinAppApp.swift          # Точка входа
├── Models/
│   ├── Coin.swift                # Модель криптовалюты
│   └── CoinDetail.swift          # Детальная информация
├── ViewModels/
│   ├── CoinsListViewModel.swift  # VM списка монет
│   ├── CoinDetailViewModel.swift # VM детального экрана
│   └── FavoritesViewModel.swift  # VM избранного
├── Views/
│   ├── ContentView.swift         # TabView
│   ├── CoinsListView.swift       # Список монет
│   ├── CoinDetailView.swift      # Детальный экран
│   ├── FavoritesView.swift       # Избранное
│   ├── SettingsView.swift        # Настройки
│   └── Components/
│       ├── CoinRowView.swift     # Строка монеты
│       ├── LoadingView.swift     # Индикатор загрузки
│       ├── ErrorView.swift       # Экран ошибки
│       └── EmptyStateView.swift  # Пустое состояние
├── Services/
│   ├── NetworkService.swift      # HTTP запросы
│   ├── CoinService.swift         # CoinGecko API
│   └── CoreDataService.swift     # Работа с CoreData
├── CoreData/
│   └── FavoriteCoin.swift        # Entity избранного
└── Utilities/
    ├── ViewState.swift           # Enum состояний
    ├── NetworkError.swift        # Типы ошибок
    └── Extensions/
        ├── Double+Formatting.swift
        └── Color+Theme.swift
```

## API

Приложение использует бесплатный [CoinGecko API](https://www.coingecko.com/api/documentation).

Основные эндпоинты:
- `/coins/markets` - список криптовалют
- `/coins/{id}` - детальная информация
- `/search` - поиск

**Ограничения:** 10-30 запросов в минуту (бесплатный план)

## Функциональность

### Список криптовалют
- Отображение топ монет по рыночной капитализации
- Pull-to-refresh
- Пагинация (бесконечная прокрутка)
- Поиск по названию/символу
- Выбор валюты (USD, RUB, EUR)

### Детальный экран
- График цены за 7 дней
- Статистика (капитализация, объем, ATH/ATL)
- Описание монеты
- Ссылки на ресурсы
- Добавление в избранное

### Избранное
- Список сохраненных монет
- Хранение в CoreData
- Удаление свайпом

### Настройки
- Выбор темы (системная/светлая/темная)
- Валюта по умолчанию

## Тестирование

```bash
# В Xcode
Cmd + U # Запуск всех тестов
```

Покрытие тестами:
- `ViewState` - все методы и computed properties
- `CoinService` - формирование URL, обработка ответов
- `CoinsListViewModel` - загрузка, фильтрация, пагинация

## Технологии

| Технология | Использование |
|------------|---------------|
| SwiftUI | UI framework |
| @Observable | State management (iOS 17) |
| Async/Await | Асинхронность |
| CoreData | Локальное хранение |
| Charts | Графики |
| URLSession | Сетевые запросы |

## Дальнейшее развитие

Идеи для расширения проекта:

- [ ] Widget для главного экрана
- [ ] Push-уведомления о изменении цены
- [ ] Portfolio tracking
- [ ] Сравнение монет
- [ ] Конвертер валют
- [ ] SwiftData вместо CoreData
- [ ] App Intents для Siri

## Лицензия

MIT License
