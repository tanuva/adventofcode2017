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

func addNode(_ s: String, graph: inout [Int:[Int]]) {
    guard let idEnd = s.index(of: "<") else {
        print("Cannot find '<' in \(s)")
        return
    }
    let idStr = s.prefix(upTo: idEnd)
    guard let id = Int(idStr) else {
        print("Cannot convert \(idStr) to Int")
        return
    }
    
    if !graph.keys.contains(id) {
        graph[id] = []
    }
    
    guard let arrowEndIdx = s.index(of: ">") else {
        print("Cannot find \">\" in \(s)")
        return
    }
    let pipesStrStart = s.index(after: arrowEndIdx)
    let pipesStr = s.suffix(from: pipesStrStart)
    for pipeIdStr in pipesStr.split(separator: ",") {
        guard let pipedNodeId = Int(pipeIdStr) else {
            print("Cannot convert \(pipeIdStr) to Int")
            return
        }
        
        //if !graph[id]!.contains(pipedNodeId) {
            graph[id]!.append(pipedNodeId)
        //}
    }
}

func parse(_ s: String) -> [Int:[Int]] {
    var graph: [Int:[Int]] = [:]
    
    for line in s.split(separator: "\n") {
        let stripped = line.replacingOccurrences(of: " ", with: "")
        addNode(stripped, graph: &graph)
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

func findGroupCount(in graph: [Int:[Int]]) -> Int {
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
    
    return groups.count
}

var inputs = ["example", "puzzle"]

for input in inputs {
    if let data = read(fileName: input) {
        let graph = parse(data)
        let nodeCount = findConnectedNodes(to: 0, in: graph).count
        print("Part 1: Connected to 0: \(nodeCount)")
        
        let groupCount = findGroupCount(in: graph)
        print("Part 2: Group count: \(groupCount)")
    }
}
