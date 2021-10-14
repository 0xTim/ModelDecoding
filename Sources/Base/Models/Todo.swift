import Fluent
import Vapor

public final class Todo: Model, Content {
    public static let schema = "todos"
    
    @ID(key: .id)
    public var id: UUID?

    @Field(key: "title")
    public var title: String

    @Field(key: "cool_name")
    public var coolName: String

    public init() { }

    public init(id: UUID? = nil, title: String, coolName: String) {
        self.id = id
        self.title = title
        self.coolName = coolName
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case coolName = "cool_name"
    }
}
