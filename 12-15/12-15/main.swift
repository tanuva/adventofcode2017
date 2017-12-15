import Foundation

class Generator {
	var last: Int
	let factor: Int

	init(seed: Int, factor: Int) {
		self.last = seed
		self.factor = factor
	}

	func next() -> Int {
		last = (last * factor) % 2147483647
		return last
	}
}

func solve1(_ input: [Int]) -> Int {
	let a = Generator(seed: input[0], factor: 16807)
	let b = Generator(seed: input[1], factor: 48271)
	var matches = 0

	for _ in 0..<40000000 {
		if a.next() & 0x000000000000ffff == b.next() & 0x000000000000ffff {
			matches += 1
		}
	}

	return matches
}

let inputs = [[65,8921],[516,190]]

for input in inputs {
	print("Matches: \(solve1(input))")
}
