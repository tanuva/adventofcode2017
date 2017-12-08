import Foundation

class Node : CustomStringConvertible {
    var name: String
    var weight: Int
    var children: [Node] = []
    var parent: Node?
	var description: String {
		return "Node(\(name), \(getTotalWeight()), \(children.count))"
	}
    
    init(name: String, weight: Int) {
        self.name = name
        self.weight = weight
    }
    
    func hasParent() -> Bool {
        return parent != nil
    }
    
    func getTotalWeight() -> Int {
        var childWeight = 0
        for child in children {
            childWeight += child.getTotalWeight()
        }
        
        return childWeight + weight
    }
    
    func isBalanced() -> Bool {
        var weightMap: [Int:Int] = [:] // Maps weights to occurrence counts
        
        for child in children {
            let weight = child.getTotalWeight()
            if weightMap.keys.contains(weight) {
                weightMap[weight]! += 1
            } else {
                weightMap[weight] = 1
            }
        }
        
        if weightMap.keys.count == 1 {
            return true
        }
        
        return false
    }
}

// The same as in 12-04
func read(fileName: String) -> String {
    if let dir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
        let fileURL = dir.appendingPathComponent(fileName)
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

func parse(_ s: String) -> [Node] {
    var nodes: [String:Node] = [:]
    let lines = s.split(separator: "\n")
    
    // Create all of dem nodes
    for line in lines {
        var tokens = line.split(separator: " ")
        let name = String(tokens[0])
        let weightStr = tokens[1]
        guard let weight = Int(weightStr[weightStr.index(after: weightStr.startIndex)..<weightStr.index(of: ")")!]) else {
            print("Weight fail!")
            continue
        }
        nodes[name] = Node(name: name, weight: weight)
    }
    
    // Build the tree structure by parenting
    for line in lines {
        if !line.contains("->") {
            continue
        }
        
        let parent = String(line.split(separator: " ")[0])
        let childrenI = line.index(after: line.index(of: ">")!)
        let childrenStr = line[childrenI..<line.endIndex]
        for childName in childrenStr.split(separator: ",") {
            let strippedName = String(childName.suffix(childName.count - 1)) // strip whitespace
            guard let child = nodes[strippedName] else {
                print("Unknown child: \(strippedName)!")
                continue
            }
            guard let parent = nodes[parent] else {
                print("Unknown parent: \(strippedName)!")
                continue
            }
            
            child.parent = parent
            parent.children.append(child)
        }
    }
    
    return Array(nodes.values)
}

func findRoot(_ nodes: [Node]) -> Node {
    var node = nodes.first!
    while node.hasParent() {
        node = node.parent!
    }
    
    return node
}

func findOddWeightedChild(_ node: Node) -> Node? {
	print("fOWC: oddWeighted? \(node.name) chld: \(node.children)")
    if node.children.isEmpty {
        return nil
    }
	if node.isBalanced() {
		return nil
	}
    
    let sorted = node.children.sorted { (a, b) -> Bool in
        return a.getTotalWeight() < b.getTotalWeight()
    }

	if sorted.first!.getTotalWeight() == sorted[sorted.index(after: sorted.startIndex)].getTotalWeight() {
		print("\(sorted.last!.name)")
        return sorted.last!
    } else {
		print("\(sorted.first!.name)")
        return sorted.first!
    }
}

func findUnbalancedNode(_ node: Node) -> Node? {
    // A node is unbalanced if not all children have the same weight.
	print("fUBN: \(node.name) balanced: \(node.isBalanced())")

	// findOddWC requires the odd child to exist at all
	if let oddChild = findOddWeightedChild(node) {
		return oddChild.isBalanced() ? node : findUnbalancedNode(oddChild)
	}

	return node.isBalanced() ? nil : node
}

func getCorrectedWeight(_ node: Node) -> Int? {
	assert(!node.isBalanced())
	for child in node.children {
		assert(child.isBalanced())
	}

	var weights: [Int:Int] = [:]
	for i in 0..<node.children.count {
		let weight = node.children[i].getTotalWeight()
		if weights.keys.contains(weight) {
			weights[weight]! += 1
		} else {
			weights[weight] = 1
		}
	}

	for pair in weights {
		if pair.value > 1 {
			return pair.key
		}
	}
	return nil
}

var inputs = ["example", "puzzle"]
for input in inputs {
    let data = read(fileName: input)
    let nodes = parse(data)
    let root = findRoot(nodes)
	let unbalanced = findUnbalancedNode(root)!
	let betterWeight = getCorrectedWeight(unbalanced)!
    print("\(input) root: \(root.name) unbalanced: \(unbalanced.name) corrected weight: \(betterWeight)\n")
}
