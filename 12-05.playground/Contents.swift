func convert(_ input: String) -> [Int] {
    var offsets: [Int] = []
    
    for line in input.split(separator: "\n") {
        guard let val = Int(line) else {
            print("Invalid int: \(line)")
            continue
        }
        offsets.append(val)
    }
    
    return offsets
}

func solve(_ offsets: inout [Int], _ newOffset: (Int) -> (Int)) -> Int {
    var steps = 0
    var cur = 0
    while cur >= 0 && cur < offsets.count {
        let oldCur = cur
        cur += offsets[cur]
        offsets[oldCur] = newOffset(offsets[oldCur])
        steps += 1
    }
    
    return steps
}

var inputs = ["""
0
3
0
1
-3
"""]

for input in inputs {
    var offsets = convert(input)
    print("Part 1:")
    var steps = solve(&offsets, { (offset) -> (Int) in
        return offset + 1
    })
    print("Steps: \(steps)")
    
    print("Part 2:")
    steps = solve(&offsets, { (offset) -> (Int) in
        return offset >= 3 ? offset - 1 : offset + 1
    })
    print("Steps: \(steps)")
}
