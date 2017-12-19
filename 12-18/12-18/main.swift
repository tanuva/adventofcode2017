import Foundation

func read(fileName: String) -> String? {
    if let dir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
        let fileURL = dir.appendingPathComponent(fileName)
        do {
            let text = try String(contentsOf: fileURL, encoding: .utf8)
            return text
        } catch _ {
            print("File reading error: \(fileName)")
        }
    }
    
    return nil
}

var registers: [String:Int] = [:]

func parse(_ s: String) -> Int {
    let lines = s.split(separator: "\n")
    var pc = 0
    var lastFreq = 0
    var firstFreq: Int? = nil
    
    while pc >= 0 && pc < lines.count {
        print("\(pc + 1): \(registers)")
        let line = lines[pc]
        let tokens = line.split(separator: " ")
        switch tokens[0] {
        case "snd":
            assert(tokens.count == 2)
            if let freq = snd(tokens[1]) {
                lastFreq = freq
            }
            pc += 1
        case "set":
            assert(tokens.count == 3)
            set(tokens[1], tokens[2])
            pc += 1
        case "add":
            assert(tokens.count == 3)
            add(tokens[1], tokens[2])
            pc += 1
        case "mul":
            assert(tokens.count == 3)
            mul(tokens[1], tokens[2])
            pc += 1
        case "mod":
            assert(tokens.count == 3)
            mod(tokens[1], tokens[2])
            pc += 1
        case "rcv":
            assert(tokens.count == 2)
            if let freq = rcv(tokens[1], lastFreq) {
                if firstFreq == nil {
                    firstFreq = freq
                    return firstFreq!
                }
            }
            pc += 1
        case "jgz":
            assert(tokens.count == 3)
            if let target = jgz(tokens[1], tokens[2]) {
                pc += target
            } else {
                pc += 1
            }
        default:
            print("Unexpected instruction: \(tokens[0])")
            return 0
        }
    }
    
    return firstFreq!
}

func snd(_ freq: Substring) -> Int? {
    var rhs = 0
    
    if let val = Int(freq) {
        rhs = val
    } else if let val = registers[String(freq)] {
        rhs = val
    } else {
        print("Cannot parse value \(freq)")
        return nil
    }
    
    return rhs
}

func set(_ reg: Substring, _ value: Substring) {
    var rhs = 0
    
    if let val = Int(value) {
        rhs = val
    } else if let val = registers[String(value)] {
        rhs = val
    } else {
        print("Cannot parse value \(value)")
        return
    }
    
    registers[String(reg)] = rhs
}

func modify(_ reg: Substring, _ value: Substring, _ op: (Int, Int) -> Int) {
    var rhs = 0
    
    if let val = Int(value) {
        rhs = val
    } else if let val = registers[String(value)] {
        rhs = val
    } else {
        print("Cannot parse value \(value)")
        return
    }
    
    let regStr = String(reg)
    if !registers.keys.contains(regStr) {
        registers[regStr] = 0
    }
    
    registers[regStr]! = op(registers[regStr]!, rhs)
}

func add(_ reg: Substring, _ value: Substring) {
    modify(reg, value, +)
}

func mul(_ reg: Substring, _ value: Substring) {
    modify(reg, value, *)
}

func mod(_ reg: Substring, _ value: Substring) {
    modify(reg, value, %)
}

func rcv(_ reg: Substring, _ lastFreq: Int) -> Int? {
    var cond = 0
    
    if let val = Int(reg) {
        cond = val
    } else if let val = registers[String(reg)] {
        cond = val
    } else {
        print("Cannot parse value \(reg)")
        return nil
    }
    
    return cond != 0 ? lastFreq : nil
}

func jgz(_ cond: Substring, _ offset: Substring) -> Int? {
    guard let off = Int(offset) else {
        print("Cannot parse offset \(offset)")
        return nil
    }
    
    if let val = registers[String(cond)] {
        return val > 0 ? off : nil
    } else if let val = Int(cond) {
        return val > 0 ? off : nil
    }
    
    return nil
}

let inputs = ["example", "puzzle"]

for input in inputs {
    guard let data = read(fileName: input) else {
        exit(-1)
    }
    let lastFreq = parse(data)
    print("Last frequency: \(lastFreq)")
}
