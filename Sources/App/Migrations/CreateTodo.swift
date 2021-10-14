import Fluent
import Base

struct CreateTodo: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("todos")
            .id()
            .field("title", .string, .required)
            .field("cool_name", .string, .required)
            .create().flatMap {
                let todo = Todo(id: nil, title: "Cool", coolName: "Cooler")
                return todo.create(on: database)
            }
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("todos").delete()
    }
}
