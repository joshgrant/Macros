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

public struct Member {
    var identifier: String
    var type: String
    var isOptional: Bool
    var isClosure: Bool
}

public struct EasyInit: ExtensionMacro {
//    
//    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
//        return []
//    }
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol, conformingTo protocols: [SwiftSyntax.TypeSyntax], in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        
        guard let structDeclSyntax = declaration.as(StructDeclSyntax.self) else {
            throw ExpansionError.notStruct
        }

        var members: [Member] = []
        
        for member in structDeclSyntax.memberBlock.members {
            guard let variableDeclSyntax = member.decl.as(VariableDeclSyntax.self) else {
                continue
            }
            
            for binding in variableDeclSyntax.bindings {
                guard let pattern = binding.pattern.as(IdentifierPatternSyntax.self) else {
                    throw ExpansionError.notIdentifier
                }
                
                guard let type = binding.typeAnnotation else {
                    throw ExpansionError.notType
                }
                
                let isOptional = type.type.is(OptionalTypeSyntax.self)
                let isClosure = type.type.is(FunctionTypeSyntax.self)
                
                members.append(.init(
                    identifier: pattern.identifier.text,
                    type: type.type.trimmedDescription,
                    isOptional: isOptional,
                    isClosure: isClosure))
            }
        }
        
        let sendableExtension: DeclSyntax =
"""
extension \(type.trimmed) {
    init(_ copy: Self, \(raw: optionalParameters(members: members))) {
        \(raw: unwrappingAssignments(members: members))
    }
}
"""

        guard let extensionDecl = sendableExtension.as(ExtensionDeclSyntax.self) else {
          return []
        }

        return [extensionDecl]
    }
}

public func parameters(members: [Member]) -> String {
    let output: [String] = members.map {
        "\($0.identifier): \($0.type)"
    }
    
    return output.joined(separator: ", ")
}

public func optionalParameters(members: [Member]) -> String {
    let output: [String] = members.map {
        if $0.isOptional {
            if $0.isClosure {
                return "\($0.identifier): (\($0.type))? = nil"
            } else {
                return "\($0.identifier): \($0.type) = nil"
            }
        } else {
            if $0.isClosure {
                return "\($0.identifier): (\($0.type))? = nil"
            } else {
                return "\($0.identifier): \($0.type)? = nil"
            }
        }
    }
    
    return output.joined(separator: ", ")
}

public func assignments(members: [Member]) -> String {
    let output: [String] = members.map {
        "self.\($0.identifier) = \($0.identifier)"
    }
    
    return output.joined(separator: "\n")
}

public func unwrappingAssignments(members: [Member]) -> String {
    let output: [String] = members.map {
        "self.\($0.identifier) = \($0.identifier) ?? copy.\($0.identifier)"
    }
    
    return output.joined(separator: "\n")
}
