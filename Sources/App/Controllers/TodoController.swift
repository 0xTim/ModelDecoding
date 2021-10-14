import Fluent
import Vapor
import SQLKit
import Base

struct TodoController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let todos = routes.grouped("todos")
        todos.get(use: index)
        todos.post(use: create)
        todos.group(":todoID") { todo in
            todo.delete(use: delete)
        }
        todos.get("raw", use: getRaw)
        todos.get("public", use: getPublic)
    }

    func index(req: Request) throws -> EventLoopFuture<[Todo]> {
        return Todo.query(on: req.db).all()
    }

    func create(req: Request) throws -> EventLoopFuture<Todo> {
        let todo = try req.content.decode(Todo.self)
        return todo.save(on: req.db).map { todo }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Todo.find(req.parameters.get("todoID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }

    func getRaw(req: Request) throws -> EventLoopFuture<[Todo]> {
        return req.getAll(from: "SELECT * FROM todos LIMIT 10000", decoding: Todo.self)
    }

    func getPublic(req: Request) throws -> EventLoopFuture<[Todo.Public]> {
        let db = req.db(.psql)
        let sql = db as! SQLDatabase
        return sql.raw("SELECT * FROM todos").all(decoding: Todo.Public.self)
    }
}

extension Request {
    public func getAll<D>(from query: String, decoding type: D.Type) -> EventLoopFuture<[D]> where D: Decodable {
        let db = self.db(.psql)
        guard let sql = db as? SQLDatabase else {
            fatalError("Unable to convert database to SQLDatabase")
        }
        return sql.raw(SQLQueryString(query)).all(decoding: type)
    }
}

extension Todo {
    struct Public: Content {
        var id: UUID?
        var coolName: String

        enum CodingKeys: String, CodingKey {
            case id
            case coolName = "cool_name"
        }
    }
}
