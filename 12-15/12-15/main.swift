import Foundation

class Generator {
	var last: Int
	let factor: Int
	let multiple: Int

	init(seed: Int, factor: Int, multiple: Int) {
		self.last = seed
		self.factor = factor
		self.multiple = multiple
	}

	func next() -> Int {
		repeat {
			last = (last * factor) % 2147483647
		} while last % multiple != 0;
		return last
	}
}

func solve1(_ input: [Int]) -> Int {
	let a = Generator(seed: input[0], factor: 16807, multiple: 4)
	let b = Generator(seed: input[1], factor: 48271, multiple: 8)
	var matches = 0

	for _ in 0..<5000000 {
		//print("a: \(a.next()) b: \(b.next())")
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
