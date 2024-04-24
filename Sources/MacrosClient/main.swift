import Macros

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
    var test: () -> Void
}

let main = Main(value: 3, name: "hello!", test: {})

let newMain = Main(main, value: 4)
print(newMain.value)
