import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(MacrosMacros)
import MacrosMacros

let testMacros: [String: Macro.Type] = [
    "EasyInit": EasyInit.self,
]
#endif

final class MacrosTests: XCTestCase {
    func test_single() throws {
        #if canImport(MacrosMacros)
        assertMacroExpansion(
            """
            @EasyInit
            struct Main {
                var a: Int
            }
            """,
            expandedSource: """
            struct Main {
                var a: Int
            }
            
            extension Main {
                init(_ copy: Self, a: Int? = nil) {
                    self.a = a ?? copy.a
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func test_multi() throws {
        #if canImport(MacrosMacros)
        assertMacroExpansion(
            """
            @EasyInit
            struct Main {
                var a: Int
                var b: String?
            }
            """,
            expandedSource: """
            struct Main {
                var a: Int
                var b: String?
            }
            
            extension Main {
                init(_ copy: Self, a: Int? = nil, b: String? = nil) {
                    self.a = a ?? copy.a
                    self.b = b ?? copy.b
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func test_subtypes() throws {
        #if canImport(MacrosMacros)
        assertMacroExpansion(
            """
            @EasyInit
            struct Main {
                
                enum Input {
                    case first
                    case second
                }
                
                enum Output {
                    case first
                    case second
                }
                
                var value: Int
                var name: String?
            }
            """,
            expandedSource: """
            struct Main {
                
                enum Input {
                    case first
                    case second
                }
                
                enum Output {
                    case first
                    case second
                }
                
                var value: Int
                var name: String?
            }
            
            extension Main {
                init(_ copy: Self, value: Int? = nil, name: String? = nil) {
                    self.value = value ?? copy.value
                    self.name = name ?? copy.name
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func test_escapingClosure() throws {
        #if canImport(MacrosMacros)
        assertMacroExpansion(
            """
            @EasyInit
            struct Main {
                var a: Int
                var closure: () -> Void
            }
            """,
            expandedSource: """
            struct Main {
                var a: Int
                var closure: () -> Void
            }
            
            extension Main {
                init(_ copy: Self, a: Int? = nil, closure: (() -> Void)? = nil) {
                    self.a = a ?? copy.a
                    self.closure = closure ?? copy.closure
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func test_optionalClosure() throws {
        #if canImport(MacrosMacros)
        assertMacroExpansion(
            """
            @EasyInit
            struct Main {
                var a: Int
                var closure: (() -> Void)?
            }
            """,
            expandedSource: """
            struct Main {
                var a: Int
                var closure: (() -> Void)?
            }
            
            extension Main {
                init(_ copy: Self, a: Int? = nil, closure: (() -> Void)? = nil) {
                    self.a = a ?? copy.a
                    self.closure = closure ?? copy.closure
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
