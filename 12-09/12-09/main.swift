import Foundation

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

enum ParserError : Error {
	case InvalidCharacter
}

func parse(stream s: String, startIndex: String.Index, depth: Int) throws -> Int {
	var score = 0
	var removed = 0
	var index = startIndex

	while index != s.endIndex {
		switch s[index] {
		case "{":
			index = parseGroup(s, startIndex: s.index(after: index), depth: depth + 1, score: &score, removed: &removed)
		case "<":
			index = skipGarbage(s, startIndex: s.index(after: index), removed: &removed)
		default:
			throw ParserError.InvalidCharacter
		}
	}

	return removed // Return 'score' for part 1 or 'removed' for part 2
}

func skipGarbage(_ s: String, startIndex: String.Index, removed: inout Int) -> String.Index {
	var index = startIndex

	while index != s.endIndex {
		switch s[index] {
		case ">":
			return s.index(after: index)
		case "!":
			index = s.index(after: s.index(after: index))
		default:
			removed += 1
			index = s.index(after: index)
		}
	}

	return index
}

func parseGroup(_ s: String, startIndex: String.Index, depth: Int, score: inout Int, removed: inout Int) -> String.Index {
	var index = startIndex

	while index != s.endIndex {
		switch s[index] {
		case "{":
			index = parseGroup(s, startIndex: s.index(after: index), depth: depth + 1, score: &score, removed: &removed)
		case "}":
			score += depth
			return s.index(after: index)
		case "<":
			index = skipGarbage(s, startIndex: s.index(after: index), removed: &removed)
		default:
			index = s.index(after: index)
		}
	}

	return index
}

guard let input = read(fileName: "inputs") else {
	exit(-1)
}

for line in input.split(separator: "\n") {
	let stream = String(line)
	let score = try parse(stream: stream, startIndex: stream.startIndex, depth: 0)
	print("Score \(line.prefix(10)): \(score)")
}
