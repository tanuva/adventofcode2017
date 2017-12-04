import Foundation

struct Position {
    var x = 0
    var y = 0
}

func == (lhs: Position, rhs: Position) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

func walkSpiral(upTo target: Int) -> Position {
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
        // TODO Maybe get rid of special case for 1-4?
        //print("State: \(state) Pos: \(cur)")
        
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

// Walk the spiral and for each square, add its value to the surrounding squares in the buffer.

let origin = Position(x: 0, y: 0)
let pos = walkSpiral(upTo: 23)
print("Final: \(pos) Distance: \(manhattanDistance(from: pos, to: origin))")
