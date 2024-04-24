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
            
                init(a: Int) {
                    self.a = a
                }
            
                init(copy: Main, a: Int? = nil) {
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
            
                init(a: Int, b: String?) {
                    self.a = a
                    self.b = b
                }
            
                init(copy: Main, a: Int? = nil, b: String? = nil) {
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
            
                init(value: Int, name: String?) {
                    self.value = value
                    self.name = name
                }
            
                init(copy: Main, value: Int? = nil, name: String? = nil) {
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
}
