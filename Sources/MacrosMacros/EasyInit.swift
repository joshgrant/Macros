import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum ExpansionError: Error {
    case notStruct
    case notVariable
    case notIdentifier
    case notType
}

public struct EasyInit: MemberMacro {
    
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {

        guard let structDeclSyntax = declaration.as(StructDeclSyntax.self) else {
            throw ExpansionError.notStruct
        }

        var members: [(identifier: String, type: String, optional: Bool)] = []
        
        for member in structDeclSyntax.memberBlock.members {
            guard let variableDeclSyntax = member.decl.as(VariableDeclSyntax.self) else {
                continue
            }
            
            for binding in variableDeclSyntax.bindings {
                guard let pattern = binding.pattern.as(IdentifierPatternSyntax.self) else {
                    throw ExpansionError.notIdentifier
                }
                
                if let type = binding.typeAnnotation?.type.as(IdentifierTypeSyntax.self) {
                    members.append((pattern.identifier.text, type.name.text, false))
                } else if let type = binding.typeAnnotation?.type.as(OptionalTypeSyntax.self) {
                    guard let wrappedType = type.wrappedType.as(IdentifierTypeSyntax.self) else {
                        throw ExpansionError.notType
                    }
                    members.append((pattern.identifier.text, wrappedType.name.text, true))
                } else {
                    throw ExpansionError.notType
                }
            }
        }
        
        return [
            """
            init(\(raw: parameters(members: members))) {
                \(raw: assignments(members: members))
            }
            """,
            """
            init(copy: \(raw: structDeclSyntax.name.text), \(raw: optionalParameters(members: members))) {
                \(raw: unwrappingAssignments(members: members))
            }
            """
        ]
    }
}

public func parameters(members: [(String, String, Bool)]) -> String {
    let output: [String] = members.map {
        "\($0.0): \($0.1)\($0.2 ? "?" : "")"
    }
    
    return output.joined(separator: ", ")
}

public func optionalParameters(members: [(String, String, Bool)]) -> String {
    let output: [String] = members.map {
        "\($0.0): \($0.1)? = nil"
    }
    
    return output.joined(separator: ", ")
}

public func assignments(members: [(String, String, Bool)]) -> String {
    let output: [String] = members.map {
        "self.\($0.0) = \($0.0)"
    }
    
    return output.joined(separator: "\n")
}

public func unwrappingAssignments(members: [(String, String, Bool)]) -> String {
    let output: [String] = members.map {
        "self.\($0.0) = \($0.0) ?? copy.\($0.0)"
    }
    
    return output.joined(separator: "\n")
}
