func parse(input: String) -> [Int] {
	let steps = input.split(separator: ",")
	var lengths = Array(repeating: 0, count: steps.count)
	for i in 0..<steps.count {
		guard let val = Int(steps[i]) else {
			print("Invalid input: \(steps[i])")
			return []
		}

		lengths[i] = val
	}

	return lengths
}

func initList(length: Int) -> [Int] {
	var list = Array<Int>(repeating: 0, count: length)
	var val = 0

	for i in 0..<list.count {
		list[i] = val
		val += 1
	}

	return list
}

func tieKnots(list original: [Int], lengths: [Int]) -> [Int] {
	var list = original
	var cur = 0
	var skip = 0

	for length in lengths {
		reverse(list: &list, range: cur..<(cur + length))
		cur += (length + skip) % list.count
		skip += 1 % list.count
	}

	return list
}

func reverse(list: inout [Int], range: Range<Int>) {
	var front = range.lowerBound
	var back = range.upperBound - 1
	var buf = 0

	while front < back {
		buf = list[front % list.count]
		list[front % list.count] = list[back % list.count]
		list[back % list.count] = buf
		front += 1
		back -= 1
	}
}

var inputs = [
	5: "3,4,1,5",
	256: "88,88,211,106,141,1,78,254,2,111,77,255,90,0,54,205"
]

for (length, lengths) in inputs {
	let lengths = parse(input: lengths)
	let list = initList(length: length)
	let tied = tieKnots(list: list, lengths: lengths)
	print("Tied: \(tied) Magic: \(tied[0] * tied[1])")
}
