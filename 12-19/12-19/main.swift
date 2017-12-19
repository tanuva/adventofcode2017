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

enum Direction {
    case North
    case East
    case South
    case West
}

func findStartX(_ s: Substring) -> Int {
    guard let idx = s.index(of: "|") else {
        print("Cannot find start index")
        return -1
    }
    return s.distance(from: s.startIndex, to: idx)
}

func char(at pos: (x: Int, y: Int), lines: [Substring]) -> Character {
    let line = lines[pos.y]
    let xIndex = line.index(line.startIndex, offsetBy: pos.x)
    return line[xIndex]
}

var steps = 0 // Yes, having those global is unbearably ugly.
func move(pos: inout (x: Int, y: Int), to dir: Direction) {
    switch dir {
    case .North:
        pos.y -= 1
    case .East:
        pos.x += 1
    case .South:
        pos.y += 1
    case .West:
        pos.x -= 1
    }
    
    steps += 1
}

let alphabet: [Character] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
func isAcceptable(_ newDir: Direction, _ c: Character) -> Bool {
    let straight: Character = newDir == .East || newDir == .West ? "-" : "|"
    return c == straight || c == "+" || alphabet.contains(c)
}

func findNewDirection(current dir: Direction, at pos: (x: Int, y: Int), lines: [Substring]) -> Direction {
    if dir == .North || dir == .South {
        if isAcceptable(.West, char(at: (x: pos.x - 1, y: pos.y), lines: lines)) {
            return .West
        }
        if isAcceptable(.East, char(at: (x: pos.x + 1, y: pos.y), lines: lines)) {
            return .East
        }
    } else if dir == .East || dir == .West {
        if isAcceptable(.North, char(at: (x: pos.x, y: pos.y - 1), lines: lines)) {
            return .North
        }
        if isAcceptable(.South, char(at: (x: pos.x, y: pos.y + 1), lines: lines)) {
            return .South
        }
    }
    
    print("Cannot determine new direction from \(pos)")
    return .North
}

func traverse(_ s: String) -> [Character] {
    var seenChars: [Character] = []
    let lines = s.split(separator: "\n")
    var pos = (x: 0, y: 0) // X+ -> East, Y+ -> South
    var dir = Direction.South
    
    pos.x = findStartX(lines[0])
    
    var curChar = char(at: pos, lines: lines)
    while curChar != " " {
        switch curChar {
        case "|":
            break
        case "-":
            break
        case "+":
            dir = findNewDirection(current: dir, at: pos, lines: lines)
            break
        default:
            seenChars.append(curChar)
        }
        
        move(pos: &pos, to: dir)
        curChar = char(at: pos, lines: lines)
    }
    
    return seenChars
}

let inputs = ["example", "puzzle"]

for input in inputs {
    guard let data = read(fileName: input) else {
        exit(-1)
    }
    
    steps = 0
    let chars = traverse(data)
    print("Chars: \(String(chars)) Steps: \(steps)")
}
