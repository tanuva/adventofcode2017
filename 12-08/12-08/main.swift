import Foundation

func read(fileName: String) -> String? {
    if let dir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
        let fileURL = dir.appendingPathComponent(fileName)
        do {
            let text = try String(contentsOf: fileURL, encoding: .utf8)
            return text
        }
        catch _ {
            print("File reading error: \(fileName)")
        }
    }
    
    return nil
}

struct Condition {
    var op: (Int, Int) -> Bool = (==)
    var lhs = ""
    var rhs = 0
}

struct RegisterChange {
    var register = ""
    var op: (Int, Int) -> Int = (+)
    var value = 0
    var condition = Condition()
}

func parse(_ s: String) -> [RegisterChange] {
    var index = s.startIndex
    var changes: [RegisterChange] = []
    while index < s.endIndex {
        var change = RegisterChange()
        (index, change.register) = parseIdentifier(s, fromIndex: index)
        (index, change.op) = parseRegisterOperator(s, fromIndex: index)
        (index, change.value) = parseIntLiteral(s, fromIndex: index)
        (index, change.condition) = parseCondition(s, fromIndex: index)
        changes.append(change)
    }
    
    return changes
}

func parseIdentifier(_ s: String, fromIndex startIndex: String.Index) -> (String.Index, String) {
    var buf = ""
    var index = startIndex
    
    while index != s.endIndex && s[index] != " " && s[index] != "\n" {
        buf.append(s[index])
        index = s.index(after: index)
    }
    
    if index != s.endIndex {
        index = s.index(after: index)
    }
    return (index, buf)
}

func parseRegisterOperator(_ s: String, fromIndex startIndex: String.Index) -> (String.Index, (Int, Int) -> Int) {
    let endIndex = s.index(startIndex, offsetBy: 4)
    
    if s[startIndex] == "i" {
        return (endIndex, +)
    } else {
        return (endIndex, -)
    }
}

func parseCondition(_ s: String, fromIndex startIndex: String.Index) -> (String.Index, Condition) {
    var c = Condition()
    var index = s.index(startIndex, offsetBy: 3) // skip "if "
    (index, c.lhs) = parseIdentifier(s, fromIndex: index)
    (index, c.op) = parseConditionOperator(s, fromIndex: index)
    (index, c.rhs) = parseIntLiteral(s, fromIndex: index)
    return (index, c)
}

func parseConditionOperator(_ s: String, fromIndex startIndex: String.Index) -> (String.Index, (Int, Int) -> Bool) {
    var index: String.Index
    var opStr: String
    (index, opStr) = parseIdentifier(s, fromIndex: startIndex)
    switch opStr {
    case "<":
        return (index, <)
    case ">":
        return (index, >)
    case ">=":
        return (index, >=)
    case "==":
        return (index, ==)
    case "<=":
        return (index, <=)
    case "!=":
        return (index, !=)
    default:
        print("Unexpected operator: \(opStr)")
        return (index, ==)
    }
}

func parseIntLiteral(_ s: String, fromIndex startIndex: String.Index) -> (String.Index, Int) {
    var index: String.Index
    var intStr: String
    (index, intStr) = parseIdentifier(s, fromIndex: startIndex)
    if let val = Int(intStr) {
        return (index, val)
    } else {
        print("Unparseable int literal: \(intStr)")
        return (index, 0)
    }
}

func getOrCreateValue(key: String, dict: inout [String:Int]) -> Int {
    if !dict.keys.contains(key) {
        dict[key] = 0
    }
    
    return dict[key]!
}

func isTrue(_ c: Condition, regs: inout [String:Int]) -> Bool {
    let lhs = getOrCreateValue(key: c.lhs, dict: &regs)
    return c.op(lhs, c.rhs)
}

func evaluate(changes: [RegisterChange], regs: inout [String:Int], maxCache: inout [Int]) {
    for change in changes {
        if !isTrue(change.condition, regs: &regs) {
            continue
        }
        
        // Make sure the register is initialized
        let _ = getOrCreateValue(key: change.register, dict: &regs)
        regs[change.register] = change.op(regs[change.register]!, change.value)
        maxCache.append(regs.values.max(by: altb)!)
    }
}

// Helper for Array.max, used in several places
let altb = { (a: Int, b: Int) -> Bool in
    return a < b
}

var inputs = ["example", "puzzle"]

for input in inputs {
    guard let data = read(fileName: input) else {
        continue
    }
    
    let changes = parse(data)
    var registers: [String:Int] = [:]
    var maxima: [Int] = []
    evaluate(changes: changes, regs: &registers, maxCache: &maxima)
    let lastMax = registers.values.max(by: altb)!
    let globalMax = maxima.max(by: altb)!
    print("Maximum: \(lastMax) Global max: \(globalMax)")
}
