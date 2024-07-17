//
//  Lists.swift
//  MastodonKit
//
//  Created by Ornithologist Coder on 1/2/18.
//  Copyright © 2018 MastodonKit. All rights reserved.
//

import Foundation

public struct Lists {
    /// Retrieves lists.
    ///
    /// - Returns: Request for `[List]`.
    public static func all() -> Request<[List]> {
        return Request<[List]>(path: "/api/v1/lists")
    }

    /// Retrieves accounts in a list.
    ///
    /// - Parameter
    ///     - id: The list ID.
    ///     - range: The bounds used when requesting data from Mastodon.
    /// - Returns: Request for `[Account]`.
    public static func accounts(id: String, range: RequestRange = .default) -> Request<[Account]> {
        let parameters = range.parameters(limit: between(1, and: 80, default: 40))
        let method = HTTPMethod.get(.parameters(parameters))
        
        return Request<[Account]>(path: "/api/v1/lists/\(id)/accounts", method: method)
    }

    /// Retrieves a list.
    ///
    /// - Parameter id: The list ID.
    /// - Returns: Request for `List`.
    public static func list(id: String) -> Request<List> {
        return Request<List>(path: "/api/v1/lists/\(id)")
    }

    /// Creates a list.
    ///
    /// - Parameter title: The title of the list.
    /// - Returns: Request for `List`.
    public static func create(title: String, exclusive: Bool = false) -> Request<List> {
        let parameter = [
            Parameter(name: "title", value: title),
            Parameter(name: "exclusive", value: String(exclusive))
        ]
        let method = HTTPMethod.post(.parameters(parameter))

        return Request<List>(path: "/api/v1/lists", method: method)
    }

    /// Updates the list title.
    ///
    /// - Parameters:
    ///   - id: The list ID.
    ///   - title: The title of the list.
    /// - Returns: Request for `List`.
    public static func update(id: String, title: String, exclusive: Bool = false) -> Request<List> {
        let parameter = [
            Parameter(name: "title", value: title),
            Parameter(name: "exclusive", value: String(exclusive))
        ]
        let method = HTTPMethod.put(.parameters(parameter))

        return Request<List>(path: "/api/v1/lists/\(id)", method: method)
    }
    
    /// Updates only the list exclusive post setting.
    ///
    /// - Parameters:
    ///   - id: The list ID.
    ///   - exclusive: Whether posts in the list show in home timeline.
    /// - Returns: Request for `List`.
    public static func update(id: String, exclusive: Bool) -> Request<List> {
        let parameter = [
            Parameter(name: "exclusive", value: String(exclusive))
        ]
        let method = HTTPMethod.put(.parameters(parameter))

        return Request<List>(path: "/api/v1/lists/\(id)", method: method)
    }
    
    /// Deletes a list.
    ///
    /// - Parameter id: The list ID.
    /// - Returns: Request for `Empty`.
    public static func delete(id: String) -> Request<Empty> {
        return Request<Empty>(path: "/api/v1/lists/\(id)", method: .delete(.empty))
    }

    /// Adds accounts to a list.
    ///
    /// - Parameters:
    ///   - accountIDs: The account IDs to be added to the list.
    ///   - id: The list ID>
    /// - Returns: Request for `Empty`.
    public static func add(accountIDs: [String], toList id: String) -> Request<Empty> {
        let parameter = accountIDs.map(toArrayOfParameters(withName: "account_ids"))
        let method = HTTPMethod.post(.parameters(parameter))

        return Request<Empty>(path: "/api/v1/lists/\(id)/accounts", method: method)
    }

    /// Removes accounts from a list.
    ///
    /// - Parameters:
    ///   - accountIDs: The account IDs to be removed from the list.
    ///   - id: The list ID>
    /// - Returns: Request for `Empty`.
    public static func remove(accountIDs: [String], fromList id: String) -> Request<Empty> {
        let parameter = accountIDs.map(toArrayOfParameters(withName: "account_ids"))
        let method = HTTPMethod.delete(.parameters(parameter))

        return Request<Empty>(path: "/api/v1/lists/\(id)/accounts", method: method)
    }
}
