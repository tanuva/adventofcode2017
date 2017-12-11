import Foundation

// This SO answer provided significant help in solving today's puzzle:
// https://gamedev.stackexchange.com/a/44814

func read(fileName: String) -> String? {
    if let dir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
        let fileURL = dir.appendingPathComponent(fileName)
        do {
            let text = try String(contentsOf: fileURL, encoding: .utf8)
            return text
        }
        catch _ {
            print("File reading error: \(fileName)")
        }
    }
    
    return nil
}

struct Position {
    var x = 0
    var y = 0
}

func follow(_ s: String) -> Position {
    var pos = Position()
    
    for step in s.split(separator: ",") {
        switch step {
        case "n":
			pos.y += 1
        case "ne":
            pos.x += 1
            pos.y += 1
        case "se":
            pos.x += 1
        case "s":
            pos.y -= 1
        case "sw":
            pos.x -= 1
            pos.y -= 1
        case "nw":
            pos.x -= 1
        default:
            print("Unexpected step: \(step)")
        }
    }
    
    return pos
}

func isWithinBounds(pos: Position, bounds: Position) -> Bool {
    if bounds.x > 0 && bounds.y > 0 {
        // upper right
        return pos.x < bounds.x && pos.y < bounds.y
    } else if bounds.x > 0 && bounds.y < 0 {
        // lower right
        return pos.x < bounds.x && pos.y > bounds.y
    } else if bounds.x < 0 && bounds.y < 0 {
        // lower left
        return pos.x > bounds.x && pos.y > bounds.y
    } else {
        // upper left
        return pos.x > bounds.x && pos.y < bounds.y
    }
}

func stepFurther(pos: Position, bounds target: Position) -> Bool {
    if target.y > 0 {
        // traveling NE
        return pos.x < abs(target.x) && pos.y < target.y
    } else {
        // traveling SW
        return abs(pos.x) < abs(target.x) && pos.y > target.y
    }
}

func findShortestPathLength(to target: Position) -> Int {
    // There has to be a nicer solution to this...
    /*var dx = target.x
    var dy = target.y
    
    if dx.signum() == dy.signum() {
        return abs(dx + dy)
    } else {
        return max(abs(dx), abs(dy))
    }*/
    
    var pos = Position()
    var steps = 0

    while stepFurther(pos: pos, bounds: target) {
        
        // TODO travel more quadrants?!
        
        if target.y > 0 {
            // travel NE
            pos.x += 1
            pos.y += 1
            steps += 1
        } else {
            // travel SW
            pos.x -= 1
            pos.y -= 1
            steps += 1
        }
        //print("Step: \(pos)")
    }
    
    print("After stepping: \(pos)")
    if abs(pos.x) == abs(target.x) {
        steps += abs(pos.y.distance(to: target.y))
    } else if pos.y == target.y {
        steps += abs(pos.x.distance(to: target.x))
    } else {
        print("Oops! \(pos) \(target)")
        return -1
    }
    
    return steps
}

var inputs = ["example", "puzzle", "puzzle11"]
var index: Int

for input in inputs {
    index = 1
    
    guard let data = read(fileName: input) else {
        exit(-1)
    }
    
    for line in data.split(separator: "\n") {
        let target = follow(String(line))
        print("Target \(index): \(target)")
        let pathLength = findShortestPathLength(to: target)
        print("Path length: \(pathLength)\n")
        index += 1
    }
}

