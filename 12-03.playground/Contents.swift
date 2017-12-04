import Foundation

struct Position {
    var x = 0
    var y = 0
}

func ==(lhs: Position, rhs: Position) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

func walkSpiral1(upTo target: Int) -> Position {
    switch(target) {
    case 1:
        return Position(x: 0, y: 0)
    case 2:
        return Position(x: 1, y: 0)
    case 3:
        return Position(x: 1, y: 1)
    case 4:
        return Position(x: 0, y: 1)
    default:
        break
    }
    
    enum WalkState {
        case start
        case left
        case bottom
        case right
        case top
    }
    
    var topLeft = Position(x: 0, y: 1)
    var btmRight = Position(x: 1, y: 0)
    var cur = topLeft
    var i = 5
    
    // Init for start position
    topLeft.x -= 1
    cur = topLeft
    var state = WalkState.left
    
	while i < target {
        //print("State: \(state) Pos: \(cur) Vals: \(values.count)")
        
        if state == .left {
            if cur.y == btmRight.y {
                btmRight.y -= 1
                state = .bottom
            }
            
            cur.y -= 1
        } else if state == .bottom {
            if cur.x == btmRight.x {
                btmRight.x += 1
                state = .right
            }
            
            cur.x += 1
        } else if state == .right {
            if cur.y == topLeft.y {
                topLeft.y += 1
                state = .top
            }
            
            cur.y += 1
        } else if state == .top {
            if cur.x == topLeft.x {
                topLeft.x -= 1
                state = .left
            }
            
            cur.x -= 1
        }

        i += 1
    }
    
	return cur
}

func manhattanDistance(from a: Position, to b: Position) -> Int {
    return abs(a.x - b.x) + abs(a.y - b.y)
}

// === Begin Part 2 === (had to copy walkSpiral() for laziness)

func makeKey(from pos: Position) -> String {
	return String(pos.x) + ":" + String(pos.y)
}

var values: [String:Int] = [
	"0:0": 1,
	"1:0": 1,
	"1:1": 2,
	"0:1": 4,
]

func getValue(for pos: Position) -> Int {
	var sum = 0

	print("FOR: \(pos)")
	for x in (pos.x - 1)..<(pos.x + 2) {
		for y in (pos.y - 1)..<(pos.y + 2) {
			let neighborPos = Position(x: x, y: y)
			let key = makeKey(from: neighborPos)
			if let neighborVal = values[key] {
				print("\(neighborPos) adding \(neighborVal)")
				sum += neighborVal
			}
		}
	}

	print("\(pos) sum: \(sum)")
	return sum
}

func walkSpiral2(upTo target: Int) -> Int {
	switch(target) {
	case 1:
		return values[makeKey(from: Position(x: 0, y: 0))]!
	case 2:
		return values[makeKey(from: Position(x: 1, y: 0))]!
	case 3:
		return values[makeKey(from: Position(x: 1, y: 1))]!
	case 4:
		let key = makeKey(from: Position(x: 0, y: 1))
		print(key)
		return values[key]!
	default:
		break
	}

	enum WalkState {
		case start
		case left
		case bottom
		case right
		case top
	}

	var topLeft = Position(x: 0, y: 1)
	var btmRight = Position(x: 1, y: 0)
	var cur = topLeft
	var i = 5

	// Init for start position
	topLeft.x -= 1
	cur = topLeft
	var curValue = getValue(for: cur)
	var state = WalkState.left

	while curValue <= target {
		//print("State: \(state) Pos: \(cur) Vals: \(values.count)")
		curValue = getValue(for: cur)
		values[makeKey(from: cur)] = curValue

		if state == .left {
			if cur.y == btmRight.y {
				btmRight.y -= 1
				state = .bottom
			}

			cur.y -= 1
		} else if state == .bottom {
			if cur.x == btmRight.x {
				btmRight.x += 1
				state = .right
			}

			cur.x += 1
		} else if state == .right {
			if cur.y == topLeft.y {
				topLeft.y += 1
				state = .top
			}

			cur.y += 1
		} else if state == .top {
			if cur.x == topLeft.x {
				topLeft.x -= 1
				state = .left
			}

			cur.x -= 1
		}

		i += 1
	}

	return curValue
}

// Run Part 1
/*let origin = Position(x: 0, y: 0)
let pos = walkSpiral1(upTo: 23)
print("Final: \(pos) Distance: \(manhattanDistance(from: pos, to: origin))")*/

// Run Part 2
let limit = 265149
let val = walkSpiral2(upTo: limit)
print("Final: \(limit) Value: \(val)")
