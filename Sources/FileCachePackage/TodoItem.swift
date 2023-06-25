import Foundation

@available(iOS 15, *)
struct ToDoItem {
    
    let id: String
    var text: String
    var priority: Priority
    var deadline: Date?
    var isDone: Bool
    var creationDate: Date
    var modifyDate: Date?
    var colorHEX: String
    
    enum Priority: String {
        case low
        case normal
        case high
    }
    
    init(id number: String = UUID().uuidString,
         text: String,
         priority: Priority,
         deadline: Date? = nil,
         isDone: Bool = false,
         creationDate: Date = .now,
         modifyDate: Date? = nil,
         colorHEX: String = "000000FF") {
        id = number
        self.text = text
        self.priority = priority
        self.deadline = deadline
        self.isDone = isDone
        self.creationDate = creationDate
        self.modifyDate = modifyDate
        self.colorHEX = colorHEX
    }
  
}

@available(iOS 15, *)
extension ToDoItem {
    
    var json: Any {
        var contentOfObj = ["text": text,
                            "isDone": String(isDone),
                            "creationDate": String(creationDate.timeIntervalSince1970),
                            "modifyDate": String(modifyDate?.timeIntervalSince1970 ?? 0),
                            "colorHEX": colorHEX]
        if deadline != nil {
            contentOfObj["deadline"] = String(deadline?.timeIntervalSince1970 ?? 0)
        }
        if priority.rawValue != "normal" {
            contentOfObj["priority"] = priority.rawValue
        }
        let jsonObject = [id: contentOfObj as [String: Any]]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
            return jsonString
        } catch {
            print("error writing JSON: \(error)")
        }
        return jsonObject
    }
    
    static func parseJson(json: Any) -> ToDoItem? {
        guard let json = json as? String else {
            print("JSON not String")
            return nil
        }
        guard let jsonData = json.data(using: String.Encoding.utf8) else {
            print("couldn't encode string as UTF-8")
            return nil
        }
        guard let dictionaryFunc = try? JSONSerialization.jsonObject(with: jsonData,
                                                                     options: .fragmentsAllowed) as? [String: [String: String]] else {
            print("Ошибка JSONSerialization")
            return nil
        }
        return createToDoFromDictionary(dictionaryFunc: dictionaryFunc)
    }

}

@available(iOS 15, *)
extension ToDoItem {
    
    var csv: Any {
        let contentOfObj = "\(id),\(text),\(priority.rawValue),\((deadline?.timeIntervalSince1970) ?? 0),\(isDone),\(creationDate.timeIntervalSince1970),\((modifyDate?.timeIntervalSince1970) ?? 0)"
   
        return contentOfObj
    }

    static func parseCSV(csv: Any) -> ToDoItem? {
        guard let csv = csv as? String else {
            print("csv not String")
            return nil
        }
        let parsedCSV = csv.components(
            separatedBy: ",")
        guard parsedCSV.count >= 7 else {return nil}
        var dictionaryFunc = [parsedCSV[0]: ["text": parsedCSV[1], "priority": parsedCSV[2], "deadline": parsedCSV[3], "isDone": parsedCSV[4], "creationDate": parsedCSV[5], "modifyDate": parsedCSV[6]]]

        if dictionaryFunc[parsedCSV[0]]?["deadline"] == "0.0" {
            dictionaryFunc[parsedCSV[0]]?["deadline"] = nil
        }
        if dictionaryFunc[parsedCSV[0]]?["modifyDate"] == "0.0" {
            dictionaryFunc[parsedCSV[0]]?["modifyDate"] = nil
        }
        return createToDoFromDictionary(dictionaryFunc: dictionaryFunc)
    }
}

@available(iOS 15, *)
extension ToDoItem {
    
    static func createToDoFromDictionary(dictionaryFunc: [String: [String: String]]) -> ToDoItem? {
        
        let id = dictionaryFunc.keys.first ?? ""
        guard let dictionaryId = dictionaryFunc[id] else {
            print("Error dictionaryId")
            return nil
        }
        guard let textFunc = dictionaryId["text"] else {
            return nil
        }
        let priorityFunc = Priority(rawValue: dictionaryId["priority"] ?? "") ?? .normal
        var deadlineFunc: Date?
        if let deadlineString = dictionaryId["deadline"] {
            if let deadlineDouble = Double(deadlineString) {
                deadlineFunc = Date(timeIntervalSince1970: deadlineDouble)
            }
        }
        let isDoneFunc = dictionaryId["isDone"] == "true"
        var creationDateFunc = Date()
        if let creationDateString = dictionaryId["creationDate"] {
            if let creationDateDouble = Double(creationDateString) {
                creationDateFunc = Date(timeIntervalSince1970: creationDateDouble)
            }
        }
        var modifyDateFunc: Date?
        if let modifyDatecreationDateString = dictionaryId["modifyDate"] {
            if let creationModifyDouble = Double(modifyDatecreationDateString) {
                modifyDateFunc = Date(timeIntervalSince1970: creationModifyDouble)
            }
        }
        let colorHEX = dictionaryId["colorHEX"] ?? "000000FF"
        
        let toDo = ToDoItem(id: id,
                            text: textFunc,
                            priority: priorityFunc,
                            deadline: deadlineFunc,
                            isDone: isDoneFunc,
                            creationDate: creationDateFunc,
                            modifyDate: modifyDateFunc,
                            colorHEX: colorHEX)
        return toDo
    }
}