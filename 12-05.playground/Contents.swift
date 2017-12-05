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

func solve1(_ offsetsConst: [Int]) -> Int {
    var offsets = offsetsConst
    var steps = 0
    var cur = 0
    while cur >= 0 && cur < offsets.count {
        let oldCur = cur
        cur += offsets[cur]
        offsets[oldCur] += 1
        steps += 1
    }
    
    return steps
}

func solve2(_ offsetsConst: [Int]) -> Int {
    var offsets = offsetsConst
    var steps = 0
    var cur = 0
    while cur >= 0 && cur < offsets.count {
        let oldCur = cur
        cur += offsets[cur]
        if offsets[oldCur] >= 3 {
            offsets[oldCur] -= 1
        } else {
            offsets[oldCur] += 1
        }
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
    let offsets = convert(input)
    print("Steps: \(solve2(offsets))")
}
