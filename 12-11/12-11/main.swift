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

func follow(_ s: String) -> [Int] {
    var pos = Position()
	var pathLengths: [Int] = []
    
    for step in s.split(separator: ",") {
        switch step {
        case "n":
			pos.y += 1
        case "ne":
            pos.x += 1
        case "se":
            pos.x += 1
			pos.y -= 1
        case "s":
            pos.y -= 1
        case "sw":
            pos.x -= 1
        case "nw":
            pos.x -= 1
			pos.y += 1
        default:
            print("Unexpected step: \(step)")
        }

		pathLengths.append(findPathLength(to: pos))
    }
    
    return pathLengths
}

func findPathLength(to target: Position) -> (Int) {
    let dx = target.x
    let dy = target.y
    
    if dx.signum() == dy.signum() {
        return abs(dx + dy)
    } else {
        return max(abs(dx), abs(dy))
    }
}

var inputs = ["example", "puzzle", "puzzle11"]
var index: Int

for input in inputs {
    index = 1
    
    guard let data = read(fileName: input) else {
        exit(-1)
    }
    
    for line in data.split(separator: "\n") {
        let pathLengths = follow(String(line))
		let longestPath = pathLengths.max()!
		print("Final path: \(pathLengths.last!) Longest path: \(longestPath)\n")
        index += 1
    }
}

