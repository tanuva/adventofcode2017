import Foundation

func readFile() -> String {
	if let dir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
		let fileURL = dir.appendingPathComponent("passphrases")
		do {
			let text = try String(contentsOf: fileURL, encoding: .utf8)
			return text
		}
		catch _ {
			print("File reading error")
		}
	}

	return ""
}

func isAnagram(_ a: String, of b: String) -> Bool {
	if a.count != b.count {
		return false
	}
	if a == b {
		return true
	}

	var chars: [Character] = []
	for c in a {
		chars.append(c)
	}

	for c in b {
		if let index = chars.index(of: c) {
			chars.remove(at: index)
		} else {
			return false
		}
	}

	return true
}

func solve1(input: String) -> Bool {
	let words = input.split(separator: " ")

	/*for a in words {
		for b in words {
			if a != b && isAnagram(String(a), of: String(b)) {
				return false
			}
		}
	}*/
	for var i in 0..<words.count {
		for var j in 0..<words.count {
			let a = words[i]
			let b = words[j]
			if i != j && isAnagram(String(a), of: String(b)) {
				return false
			}
		}
	}

	return true
}

let inputs = readFile().split(separator: "\n")
//let inputs = ["aaab aaab"]
var validCount = 0

for input in inputs {
	if solve1(input: String(input)) {
		validCount += 1
	} else {
//		print(input)
	}
}

print("Valid: \(validCount)")
