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
}

let main = Main(value: 3, name: "hello!")
