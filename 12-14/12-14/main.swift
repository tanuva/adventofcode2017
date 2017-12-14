func getOnes(in c: Character) -> Int {
    var ones = 0
    
    guard let num = UInt8(String(c), radix: 16) else {
        print("Invalid input: \(c)")
        return 0
    }
    
    let masks: [UInt8] = [0x1, 0x2, 0x4, 0x8]
    for mask in masks {
        if num & mask > 0 {
            ones += 1
        }
    }
    
    return ones
}

func findUsedSquares(inRow rowId: String) -> Int {
    let hash = knotHash(input: rowId)
    var used = 0
    
    for c in hash {
        used += getOnes(in: c)
    }
    
    return used
}

func solve1(_ base: String) -> Int {
    var usedSquares = 0
    
    for row in 0..<128 {
        let rowId = base + "-" + String(row)
        usedSquares += findUsedSquares(inRow: rowId)
    }
    
    return usedSquares
}

var inputs = ["flqrgnkx", "jzgqcdpd"]

for input in inputs {
    print("\(input): \(solve1(input))")
}
