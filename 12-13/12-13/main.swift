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

struct Layer : CustomDebugStringConvertible {
    let depth: Int
    let range: Int
    var debugDescription: String {
        return "L(d: \(depth) r: \(range))"
    }
}

func parse(_ s: String) -> [Int:Layer] {
    var firewall: [Int:Layer] = [:]
    
    for line in s.split(separator: "\n") {
        guard let layer = parseLine(line) else {
            continue
        }
        firewall[layer.depth] = layer
    }
    
    return firewall
}

func parseLine(_ s: Substring) -> Layer? {
    guard let colonIndex = s.index(of: ":") else {
        print("Cannot parse line \(s)")
        return nil
    }
    guard let depth = Int(s.prefix(upTo: colonIndex)) else {
        print("Cannot parse Int: \(s.prefix(upTo: colonIndex))")
        return nil
    }
    
    let rangeIndex = s.index(after: s.index(after: colonIndex))
    guard let range = Int(s.suffix(from: rangeIndex)) else {
        print("Cannot parse Int: \(s.suffix(from: rangeIndex))")
        return nil
    }

    return Layer(depth: depth, range: range)
}

func traverse(firewall fw: [Int:Layer], delay: Int) -> Int {
    var severity = 0
    var caught = false // Helps noticing if we get caught in layer 0 *only*
    
    for (depth, layer) in fw {
        let picosec = depth + delay
        
        if calculateScannerPos(for: layer, at: picosec) == 0 {
            caught = true
            severity += layer.depth * layer.range
        }
    }
    
    return severity == 0 && caught ? 1 : severity
}

func calculateScannerPos(for layer: Layer, at picosec: Int) -> Int {
    // range-1 because of how the magic here works
    let adaptedRange = layer.range - 1
    let mod = picosec % adaptedRange
    let div = picosec / adaptedRange
    
    if div % 2 == 0 {
        // forward
        return mod
    } else {
        // backward
        return adaptedRange - mod
    }
}

var inputs = ["example", "puzzle"]

for input in inputs {
    guard let data = read(fileName: input) else {
        continue
    }
    
    let firewall = parse(data)
    var delay = 0
    
    print("Part 1 Severity: \(traverse(firewall: firewall, delay: 0))")
    
    while true {
        if traverse(firewall: firewall, delay: delay) == 0 {
            print("Part 2 Delay: \(delay)")
            break
        }
        
        delay += 1
    }
}
