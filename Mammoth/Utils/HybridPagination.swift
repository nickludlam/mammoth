//
//  HybridPagination.swift
//  Mammoth
//
//  Created by Nick Ludlam on 18/07/2024
//  Copyright © 2024 The BLVD. All rights reserved.
//

import Foundation

// This is a union of a paginated (Link header) response and a cursorId, specifically used in the TimelineService
// as this mixes unpaginated requests which can arbitrarily have a RequestRange constructed from
// any Status item, and feeds like bookmarks and favourites which must explicitly use the pagination
// data returned in the header of API responses, thus this pagination data needs storing in this enum

enum HybridPaginationError: Error {
    case updateWithIncompatibleTypes
}

enum HybridPagination {
    case cursorId(String)
    case pagination(Pagination)
}

extension HybridPagination: CustomStringConvertible {
    var description: String {
        switch self {
        case .cursorId(let id):
            return "HybridPagination - cursor ID: \(id)"
        case .pagination(let pagination):
            return "HybridPagination - pagination: \(pagination)"
        }
    }
}

// updateWith allows us a single method to assign when we're using cursorId, and
// extend the current next/previous range window when we're using pagination
extension HybridPagination {
    func updateWith(_ other: HybridPagination) throws -> HybridPagination {
        switch self {
        case .cursorId(_):
            switch other {
            case .cursorId(let otherCursorId):
                return .cursorId(otherCursorId)
            case .pagination(_):
                throw HybridPaginationError.updateWithIncompatibleTypes
            }
        case .pagination(_):
            switch other {
            case .cursorId(_):
                throw HybridPaginationError.updateWithIncompatibleTypes
            case .pagination(let otherPagination):
                return try self.extendWithPagination(otherPagination)
            }
        }
    }
    
    // As we page through the results, keep updating next and previous with the lowest and highest values
    func extendWithPagination(_ newPagination: Pagination) throws -> HybridPagination {
        // throw if self is not a pagination type
        guard case .pagination(let currentPagination) = self else {
            throw HybridPaginationError.updateWithIncompatibleTypes
        }
        
        // Always prefer the new values
        var updatedNext = newPagination.next
        var updatedPrevious = newPagination.previous
        
        if let currentPaginationNext = currentPagination.next, let newPaginationNext = newPagination.next {
            // Since we defaulted to taking the new value above, we need to keep the existing value if it's from further back
            // i.e. A max_id higher than our current max does not extend the range. Next pages sequentially have lower max_id values
            if currentPaginationNext.isComparableWith(newPaginationNext) && currentPaginationNext < newPaginationNext {
                updatedNext = currentPaginationNext
            }
        }
        
        if let currentPaginationPrevious = currentPagination.previous, let newPaginationPrevious = newPagination.previous {
            // Same as above, a pevious range should have a higher since_id/max_id, so if our current is higher than the new, restore our current
            if currentPaginationPrevious.isComparableWith(newPaginationPrevious) && currentPaginationPrevious > newPaginationPrevious {
                updatedPrevious = currentPaginationPrevious
            }
        }
        
        return .pagination(Pagination(next: updatedNext, previous: updatedPrevious))
    }
}
