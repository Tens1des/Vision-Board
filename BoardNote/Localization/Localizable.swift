//
//  Localizable.swift
//  BoardNote
//
//  Localization Strings
//

import Foundation

struct LocalizedStrings {
    
    // MARK: - Language Support
    static func localizedString(for key: String) -> String {
        let language = DataManager.shared.settings.language
        return getLocalizedString(key: key, language: language)
    }
    
    private static func getLocalizedString(key: String, language: AppLanguage) -> String {
        switch language {
        case .russian:
            return russianStrings[key] ?? key
        case .english:
            return englishStrings[key] ?? key
        }
    }
    
    // MARK: - English Strings
    private static let englishStrings: [String: String] = [
        // Home Screen
        "myBoards": "My Boards",
        "createAndOrganize": "Create and organize your vision",
        "searchBoards": "Search boards...",
        "noBoardsYet": "No boards yet",
        "createFirstBoard": "Create your first vision board\nand start visualizing your dreams",
        "createBoard": "Create Board",
        "elements": "elements",
        
        // Board Detail
        "add": "Add",
        "photo": "Photo",
        "text": "Text",
        "arrow": "Arrow",
        "hideGrid": "Hide Grid",
        "showGrid": "Show Grid",
        "deleteElement": "Delete Element",
        
        // Add Element
        "addElement": "Add Element",
        "selectElementType": "Select element type to add to your board",
        "sticker": "Sticker",
        "shape": "Shape",
        "quickStickers": "Quick Stickers",
        "quickShapes": "Quick Shapes",
        "addText": "Add Text",
        "lastUsed": "Last Used",
        
        // New Board
        "newBoard": "New Board",
        "boardTitle": "Board Title",
        "myDreamBoard": "My Dream Board",
        "yearOptional": "Year (Optional)",
        "cancel": "Cancel",
        
        // Settings
        "settings": "Settings",
        "personalization": "Personalization",
        "chooseAvatar": "Choose Avatar",
        "customizeProfile": "Customize your profile",
        "name": "Name",
        "yourName": "Your Name",
        "appearance": "Appearance",
        "theme": "Theme",
        "language": "Language",
        "english": "English",
        "russian": "Русский",
        "interfaceLanguage": "Interface Language",
        "boardSettings": "Board Settings",
        "autoSave": "Auto Save",
        "saveChangesAutomatically": "Save changes automatically",
        "displayGridOnCanvas": "Display grid on canvas",
        "accessibility": "Accessibility",
        "textSize": "Text Size",
        "adjustTextSize": "Adjust text size",
        "achievements": "Achievements",
        "viewProgress": "View your progress",
        "done": "Done",
        "userSettings": "User Settings",
        
        // Avatar Picker
        "preview": "Preview",
        "chooseIcon": "Choose Icon",
        "chooseColor": "Choose Color",
        "saveAvatar": "Save Avatar",
        
        // Achievements
        "achievementProgress": "Achievement Progress",
        "overallProgress": "Overall Progress",
        
        // Element Editor
        "editText": "Edit Text",
        "saveChanges": "Save Changes",
        "edit": "Edit",
        "duplicate": "Duplicate",
        "bringForward": "Bring Forward",
        "sendBackward": "Send Backward",
        "delete": "Delete",
        
        // Arrow Drawing
        "lineWidth": "Line Width",
        "doneDrawing": "Done Drawing",
        
        // General
        "save": "Save",
        "close": "Close",
        "deleteBoard": "Delete Board"
    ]
    
    // MARK: - Russian Strings
    private static let russianStrings: [String: String] = [
        // Home Screen
        "myBoards": "Мои доски",
        "createAndOrganize": "Создавайте и организуйте свои мечты",
        "searchBoards": "Поиск досок...",
        "noBoardsYet": "Пока нет досок",
        "createFirstBoard": "Создайте свою первую доску мечт\nи начните визуализировать свои цели",
        "createBoard": "Создать доску",
        "elements": "элементов",
        
        // Board Detail
        "add": "Добавить",
        "photo": "Фото",
        "text": "Текст",
        "arrow": "Стрелка",
        "hideGrid": "Скрыть сетку",
        "showGrid": "Показать сетку",
        "deleteElement": "Удалить элемент",
        
        // Add Element
        "addElement": "Добавить элемент",
        "selectElementType": "Выберите тип элемента для добавления на доску",
        "sticker": "Стикер",
        "shape": "Фигура",
        "quickStickers": "Быстрые стикеры",
        "quickShapes": "Быстрые фигуры",
        "addText": "Добавить текст",
        "lastUsed": "Последний",
        
        // New Board
        "newBoard": "Новая доска",
        "boardTitle": "Название доски",
        "myDreamBoard": "Моя доска мечт",
        "yearOptional": "Год (необязательно)",
        "cancel": "Отмена",
        
        // Settings
        "settings": "Настройки",
        "personalization": "Персонализация",
        "chooseAvatar": "Выбрать аватар",
        "customizeProfile": "Настройте свой профиль",
        "name": "Имя",
        "yourName": "Ваше имя",
        "appearance": "Внешний вид",
        "theme": "Тема",
        "language": "Язык",
        "english": "English",
        "russian": "Русский",
        "interfaceLanguage": "Язык интерфейса",
        "boardSettings": "Настройки досок",
        "autoSave": "Автосохранение",
        "saveChangesAutomatically": "Автоматически сохранять изменения",
        "displayGridOnCanvas": "Показывать сетку на холсте",
        "accessibility": "Доступность",
        "textSize": "Размер текста",
        "adjustTextSize": "Настроить размер текста",
        "achievements": "Достижения",
        "viewProgress": "Просмотр прогресса",
        "done": "Готово",
        "userSettings": "Настройки пользователя",
        
        // Avatar Picker
        "preview": "Предпросмотр",
        "chooseIcon": "Выбрать иконку",
        "chooseColor": "Выбрать цвет",
        "saveAvatar": "Сохранить аватар",
        
        // Achievements
        "achievementProgress": "Прогресс достижений",
        "overallProgress": "Общий прогресс",
        
        // Element Editor
        "editText": "Редактировать текст",
        "saveChanges": "Сохранить изменения",
        "edit": "Редактировать",
        "duplicate": "Дублировать",
        "bringForward": "На передний план",
        "sendBackward": "На задний план",
        "delete": "Удалить",
        
        // Arrow Drawing
        "lineWidth": "Толщина линии",
        "doneDrawing": "Завершить рисование",
        
        // General
        "save": "Сохранить",
        "close": "Закрыть",
        "deleteBoard": "Удалить доску"
    ]
    
    // MARK: - Convenience Properties
    static var myBoards: String { localizedString(for: "myBoards") }
    static var createAndOrganize: String { localizedString(for: "createAndOrganize") }
    static var searchBoards: String { localizedString(for: "searchBoards") }
    static var noBoardsYet: String { localizedString(for: "noBoardsYet") }
    static var createFirstBoard: String { localizedString(for: "createFirstBoard") }
    static var createBoard: String { localizedString(for: "createBoard") }
    static var elements: String { localizedString(for: "elements") }
    static var add: String { localizedString(for: "add") }
    static var photo: String { localizedString(for: "photo") }
    static var text: String { localizedString(for: "text") }
    static var arrow: String { localizedString(for: "arrow") }
    static var hideGrid: String { localizedString(for: "hideGrid") }
    static var showGrid: String { localizedString(for: "showGrid") }
    static var deleteElement: String { localizedString(for: "deleteElement") }
    static var addElement: String { localizedString(for: "addElement") }
    static var selectElementType: String { localizedString(for: "selectElementType") }
    static var sticker: String { localizedString(for: "sticker") }
    static var shape: String { localizedString(for: "shape") }
    static var quickStickers: String { localizedString(for: "quickStickers") }
    static var quickShapes: String { localizedString(for: "quickShapes") }
    static var addText: String { localizedString(for: "addText") }
    static var newBoard: String { localizedString(for: "newBoard") }
    static var boardTitle: String { localizedString(for: "boardTitle") }
    static var myDreamBoard: String { localizedString(for: "myDreamBoard") }
    static var yearOptional: String { localizedString(for: "yearOptional") }
    static var cancel: String { localizedString(for: "cancel") }
    static var settings: String { localizedString(for: "settings") }
    static var personalization: String { localizedString(for: "personalization") }
    static var chooseAvatar: String { localizedString(for: "chooseAvatar") }
    static var customizeProfile: String { localizedString(for: "customizeProfile") }
    static var name: String { localizedString(for: "name") }
    static var yourName: String { localizedString(for: "yourName") }
    static var appearance: String { localizedString(for: "appearance") }
    static var theme: String { localizedString(for: "theme") }
    static var language: String { localizedString(for: "language") }
    static var english: String { localizedString(for: "english") }
    static var russian: String { localizedString(for: "russian") }
    static var interfaceLanguage: String { localizedString(for: "interfaceLanguage") }
    static var boardSettings: String { localizedString(for: "boardSettings") }
    static var autoSave: String { localizedString(for: "autoSave") }
    static var saveChangesAutomatically: String { localizedString(for: "saveChangesAutomatically") }
    static var displayGridOnCanvas: String { localizedString(for: "displayGridOnCanvas") }
    static var accessibility: String { localizedString(for: "accessibility") }
    static var textSize: String { localizedString(for: "textSize") }
    static var adjustTextSize: String { localizedString(for: "adjustTextSize") }
    static var achievements: String { localizedString(for: "achievements") }
    static var viewProgress: String { localizedString(for: "viewProgress") }
    static var done: String { localizedString(for: "done") }
    static var userSettings: String { localizedString(for: "userSettings") }
    static var preview: String { localizedString(for: "preview") }
    static var chooseIcon: String { localizedString(for: "chooseIcon") }
    static var chooseColor: String { localizedString(for: "chooseColor") }
    static var saveAvatar: String { localizedString(for: "saveAvatar") }
    static var achievementProgress: String { localizedString(for: "achievementProgress") }
    static var overallProgress: String { localizedString(for: "overallProgress") }
    static var editText: String { localizedString(for: "editText") }
    static var saveChanges: String { localizedString(for: "saveChanges") }
    static var edit: String { localizedString(for: "edit") }
    static var duplicate: String { localizedString(for: "duplicate") }
    static var bringForward: String { localizedString(for: "bringForward") }
    static var sendBackward: String { localizedString(for: "sendBackward") }
    static var delete: String { localizedString(for: "delete") }
    static var lineWidth: String { localizedString(for: "lineWidth") }
    static var doneDrawing: String { localizedString(for: "doneDrawing") }
    static var save: String { localizedString(for: "save") }
    static var close: String { localizedString(for: "close") }
    static var deleteBoard: String { localizedString(for: "deleteBoard") }
    static var lastUsed: String { localizedString(for: "lastUsed") }
}