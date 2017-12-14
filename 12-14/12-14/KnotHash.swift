import Foundation // for String(format:)

func parse(input: String) -> [UInt8] {
    var lengths: [UInt8] = []
    
    for c in input {
        guard let scalar = c.unicodeScalars.first else {
            print("No scalars in \(c)")
            continue
        }
        if !scalar.isASCII {
            print("Non-ASCII scalar: \(scalar)")
        }
        
        lengths.append(UInt8(scalar.value))
    }
    
    return lengths + [17, 31, 73, 47, 23]
}

func initList(length: Int) -> [UInt8] {
    var list = Array<UInt8>(repeating: 0, count: length)
    
    for i in 0..<list.count {
        list[i] = UInt8(i)
    }
    
    return list
}

func tieKnots(lengths: [UInt8]) -> [UInt8] {
    var list = initList(length: 256)
    var cur: Int = 0
    var skip: Int = 0
    
    for _ in 0..<64 {
        for length in lengths {
            let intLength = Int(length)
            reverse(list: &list, range: cur..<(cur + intLength))
            cur += (Int(length) + skip) % list.count
            skip += 1 % list.count
        }
    }
    
    return list
}

func reverse(list: inout [UInt8], range: Range<Int>) {
    var front = range.lowerBound
    var back = range.upperBound - 1
    var buf: UInt8 = 0
    
    while front < back {
        buf = list[front % list.count]
        list[front % list.count] = list[back % list.count]
        list[back % list.count] = buf
        front += 1
        back -= 1
    }
}

func densify(hash sparse: [UInt8]) -> [UInt8] {
    var dense = Array<UInt8>(repeating: 0, count: 16)
    
    for i in 0..<sparse.count {
        dense[i / 16] ^= sparse[i]
    }
    
    return dense
}

func toHex(hash: [UInt8]) -> String {
    var out = ""
    
    for i in hash {
        out += String(format: "%02x", i)
    }
    
    return out
}

public func knotHash(input: String) -> String {
    let lengths = parse(input: input)
    let sparse = tieKnots(lengths: lengths)
    let dense = densify(hash: sparse)
    return toHex(hash: dense)
}
