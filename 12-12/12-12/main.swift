import Foundation

func read(fileName: String) -> String? {
    if let dir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
        let fileURL = dir.appendingPathComponent(fileName)
        do {
            let text = try String(contentsOf: fileURL, encoding: .utf8)
            return text
        } catch _ {
            print("File reading error: \(fileName)")
        }
    }
    
    return nil
}

func parseNode(_ s: String, graph: inout [Int:[Int]]) -> Int? {
    guard let idEnd = s.index(of: "<") else {
        print("Cannot find '<' in \(s)")
        return nil
    }
    let idStr = s.prefix(upTo: idEnd)
    guard let id = Int(idStr) else {
        print("Cannot convert \(idStr) to Int")
        return nil
    }
    
    if !graph.keys.contains(id) {
        graph[id] = []
    }
    
    return id
}

func parseConnectedNodes(_ s: String, graph: inout [Int:[Int]], node: Int) {
    guard let arrowEndIdx = s.index(of: ">") else {
        print("Cannot find \">\" in \(s)")
        return
    }
    let pipesStr = s.suffix(from: s.index(after: arrowEndIdx))
    
    for connectedNodeStr in pipesStr.split(separator: ",") {
        guard let connectedNode = Int(connectedNodeStr) else {
            print("Cannot convert \(connectedNodeStr) to Int")
            continue
        }
        
        graph[node]!.append(connectedNode)
    }
}

func parseLine(_ s: String, graph: inout [Int:[Int]]) {
    // Input is stripped from whitespace, e.g. "2<->0,3,4"
    guard let node = parseNode(s, graph: &graph) else {
        return
    }
    parseConnectedNodes(s, graph: &graph, node: node)
}

func parse(_ s: String) -> [Int:[Int]] {
    var graph: [Int:[Int]] = [:]
    
    for line in s.split(separator: "\n") {
        let stripped = line.replacingOccurrences(of: " ", with: "")
        parseLine(stripped, graph: &graph)
    }
    
    return graph
}

func countConnectedNodes(to node: Int, in graph: [Int:[Int]], seenNodes: inout [Int]) -> Int {
    if seenNodes.contains(node) {
        return 0
    }
    seenNodes.append(node)
    
    var connected = 1 // 'node' is connected.
    for child in graph[node]! {
        connected += countConnectedNodes(to: child, in: graph, seenNodes: &seenNodes)
    }
    
    return connected
}

func findConnectedNodes(to node: Int, in graph: [Int:[Int]]) -> [Int] {
    var seenNodes: [Int] = []
    _ = countConnectedNodes(to: node, in: graph, seenNodes: &seenNodes)
    return seenNodes
}

func findAllGroups(in graph: [Int:[Int]]) -> [[Int]] {
    var groups: [[Int]] = []

    for node in graph.keys {
        var knownNode = false

        for group in groups {
            if group.contains(node) {
                knownNode = true
                break
            }
        }
        
        if !knownNode {
            groups.append(findConnectedNodes(to: node, in: graph))
        }
    }
    
    return groups
}

var inputs = ["example", "puzzle"]

for input in inputs {
    if let data = read(fileName: input) {
        let graph = parse(data)
        let nodeCount = findConnectedNodes(to: 0, in: graph).count
        let groupCount = findAllGroups(in: graph).count
        print("Nodes connected to node 0: \(nodeCount) Total group count: \(groupCount)")
    }
}
