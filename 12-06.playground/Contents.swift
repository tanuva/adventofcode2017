func convert(_ s: String) -> [Int] {
    let separator: Character = s.contains(" ") ? " " : "\t"
    var out: [Int] = []
    for part in s.split(separator: separator) {
        guard let val = Int(String(part)) else {
            continue
        }
        
        out.append(val)
    }
    
    return out
}

func equal(a: [Int], b: [Int]) -> Bool {
    for i in 0..<a.count {
        if a[i] != b[i] {
            return false
        }
    }
    
    return true
}

func known(state: [Int], seenStates: [[Int]]) -> Bool {
    for seenState in seenStates {
        if equal(a: state, b: seenState) {
            return true
        }
    }
    
    return false
}

func findFullestBank(_ state: [Int]) -> Int {
    var fullest = 0
    var fullestHeight = -1
    for i in 0..<state.count {
        if state[i] > fullestHeight {
            fullest = i
            fullestHeight = state[i]
        }
    }
    
    return fullest
}

func redistribute(blockIndex: Int, state constState: [Int]) -> [Int] {
    var state = constState
    var blockCount = state[blockIndex]
    state[blockIndex] = 0
    
    var i = (blockIndex + 1) % state.count
    while blockCount > 0 {
        state[i] += 1
        blockCount -= 1
        i = (i + 1) % state.count
    }
    
    return state
}

var inputs = ["0 2 7 0",
              "2    8    8    5    4    2    3    1    5    5    1    2    15    13    5    14"]

func solve1(_ input: String) -> Int {
    var seenStates: [[Int]] = []
    var state = convert(input)
    var redistributions = 0
    
    while !known(state: state, seenStates: seenStates) {
        seenStates.append(state)
        let fullestBankIndex = findFullestBank(state)
        state = redistribute(blockIndex: fullestBankIndex, state: state)
        redistributions += 1
    }
    
    return redistributions
}

func solve2(_ input: String) -> Int {
    var seenStates: [[Int]] = []
    var state = convert(input)
    var redistributions = 0
    
    for _ in 0..<2 {
        redistributions = 0
        seenStates = []
        
        while !known(state: state, seenStates: seenStates) {
            seenStates.append(state)
            let fullestBankIndex = findFullestBank(state)
            state = redistribute(blockIndex: fullestBankIndex, state: state)
            redistributions += 1
        }
    }
    
    return redistributions
}

print("Redistributions: \(solve2(inputs[0]))")
