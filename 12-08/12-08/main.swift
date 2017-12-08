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
    enum Operator {
        case LT
        case GT
        case GE
        case EE
        case LE
        case NE
    }
    
    var op = Operator.EE
    var lhs = ""
    var rhs = 0
}

struct RegisterChange {
    enum Operator {
        case Increment
        case Decrement
    }
    
    var register = ""
    var op = Operator.Increment
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

func parseRegisterOperator(_ s: String, fromIndex startIndex: String.Index) -> (String.Index, RegisterChange.Operator) {
    let endIndex = s.index(startIndex, offsetBy: 4)
    
    if s[startIndex] == "i" {
        return (endIndex, RegisterChange.Operator.Increment)
    } else {
        return (endIndex, RegisterChange.Operator.Decrement)
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

func parseConditionOperator(_ s: String, fromIndex startIndex: String.Index) -> (String.Index, Condition.Operator) {
    var index: String.Index
    var opStr: String
    (index, opStr) = parseIdentifier(s, fromIndex: startIndex)
    switch opStr {
    case "<":
        return (index, Condition.Operator.LT)
    case ">":
        return (index, Condition.Operator.GT)
    case ">=":
        return (index, Condition.Operator.GE)
    case "==":
        return (index, Condition.Operator.EE)
    case "<=":
        return (index, Condition.Operator.LE)
    case "!=":
        return (index, Condition.Operator.NE)
    default:
        print("Unexpected operator: \(opStr)")
        return (index, Condition.Operator.EE)
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
    switch c.op {
    case .LT:
        return lhs < c.rhs
    case .GT:
        return lhs > c.rhs
    case .GE:
        return lhs >= c.rhs
    case .EE:
        return lhs == c.rhs
    case .LE:
        return lhs <= c.rhs
    case .NE:
        return lhs != c.rhs
    }
}

func evaluate(changes: [RegisterChange], regs: inout [String:Int], maxCache: inout [Int]) {
    for change in changes {
        if !isTrue(change.condition, regs: &regs) {
            continue
        }
        
        // Make sure the register is initialized
        let _ = getOrCreateValue(key: change.register, dict: &regs)
        switch change.op {
        case .Increment:
            regs[change.register]! += change.value
        case .Decrement:
            regs[change.register]! -= change.value
        }
        
        maxCache.append(findLargestValue(regs))
    }
}

func findLargestValue(_ regs: [String:Int]) -> Int {
    var max = Int.min
    
    for val in regs.values {
        if val > max {
            max = val
        }
    }
    
    return max
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
    let globalMax = maxima.max(by: { (a, b) -> Bool in
        return a < b
    })!
    print("Maximum: \(findLargestValue(registers)) Global max: \(globalMax)")
}
