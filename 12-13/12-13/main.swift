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

struct Layer {
    let depth: Int
    let range: Int
    var scanner = 0
    var scannerStep = 1 // 1 or -1
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

    return Layer(depth: depth, range: range, scanner: 0, scannerStep: 1)
}

func traverse(firewall fw: inout [Int:Layer]) -> Int {
    var packetPos = 0
    var severity = 0
    
    while packetPos <= fw.keys.max()! {
        if let layer = fw[packetPos] {
            if layer.scanner == 0 {
                severity += layer.depth * layer.range
            }
        }
        
        advanceScanners(in: &fw)
        packetPos += 1
    }
    
    return severity
}

func advanceScanners(in fw: inout [Int:Layer]) {
    for id in fw.keys {
        var layer = fw[id]!
        layer.scanner += layer.scannerStep
        
        if layer.scanner == layer.range - 1 || layer.scanner == 0 {
            layer.scannerStep *= -1
        }
        fw[id] = layer
    }
}

var inputs = ["example", "puzzle"]

for input in inputs {
    guard let data = read(fileName: input) else {
        continue
    }
    
    var firewall = parse(data)
    let caughtValue = traverse(firewall: &firewall)
    print("Caught: \(caughtValue)")
}
