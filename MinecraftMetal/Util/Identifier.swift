//
//  Identifier.swift
//  MinecraftMetal
//
//  Created by YiZhiMCQiu on 2025/4/16.
//

class Identifier: Identifiable, Hashable, Equatable, CustomStringConvertible {
    public static let DefaultNamespace: String = "minecraft"
    public static let Separator: Character = ":"
    
    public let parent: String
    public let path: String
    
    var description: String {
        return "\(parent)\(Identifier.Separator)\(path)"
    }
    
    static func == (lhs: Identifier, rhs: Identifier) -> Bool {
        return lhs.parent == rhs.parent && lhs.path == rhs.path
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(parent)
        hasher.combine(path)
    }
    
    private init(parent: String, path: String) {
        self.parent = parent
        self.path = path
    }
    
    public static func of(_ parent: String, _ path: String) -> Identifier {
        return Identifier(parent: parent, path: path)
    }
    
    public static func of(_ path: String) -> Identifier {
        return Identifier(parent: DefaultNamespace, path: path)
    }
}
