//
//  HybridPagination.swift
//  Mammoth
//
//  Created by Nick Ludlam on 18/07/2024
//  Copyright © 2024 The BLVD. All rights reserved.
//

import Foundation

// This is a union of a linkHeader (API responses with the Link header ) response and a min/max range
// constructed by examining the contents of the objects returned. This is used in TimelineService
// as this mixes unpaginated requests which can arbitrarily have a RequestRange constructed from
// any Status item, and feeds like bookmarks and favourites which must explicitly use the pagination
// data returned in the header of API responses

enum HybridPaginationError: Error {
    case updateWithIncompatibleTypes
}

enum HybridPagination {
    case derivedRange(String?, String?) // firstId, lastId from results - first should have a higher numeric value
    case linkHeader(Pagination)
}

extension HybridPagination: CustomStringConvertible {
    var description: String {
        switch self {
        case .derivedRange(let firstId, let lastId):
            return "HybridPagination.derivedRange firstId: \(String(describing: firstId)), lastId: \(String(describing: lastId))"
        case .linkHeader(let pagination):
            return "HybridPagination.pagination: \(pagination)"
        }
    }
}

// updateWith allows us a single method to assign when we're using cursorId, and
// extend the current next/previous range window when we're using pagination
extension HybridPagination {
    func updateWith(_ other: HybridPagination) throws -> HybridPagination {
        switch self {
        case .derivedRange(_, _):
            switch other {
            case .derivedRange(let otherFirstId, let otherLastId):
                return .derivedRange(otherFirstId, otherLastId)
            case .linkHeader(_):
                throw HybridPaginationError.updateWithIncompatibleTypes
            }
        case .linkHeader(_):
            switch other {
            case .derivedRange(_, _):
                throw HybridPaginationError.updateWithIncompatibleTypes
            case .linkHeader(let otherPagination):
                return try self.extendWithPagination(otherPagination)
            }
        }
    }
    
    // As we page through the results, keep updating next and previous with the lowest and highest values
    func extendWithPagination(_ newPagination: Pagination) throws -> HybridPagination {
        // throw if self is not a pagination type
        guard case .linkHeader(let currentPagination) = self else {
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
            // Same as above, a pevious range should have a higher since_id/min_id, so if our current is higher than the new, restore our current
            if currentPaginationPrevious.isComparableWith(newPaginationPrevious) && currentPaginationPrevious > newPaginationPrevious {
                updatedPrevious = currentPaginationPrevious
            }
        }
        
        return .linkHeader(Pagination(next: updatedNext, previous: updatedPrevious))
    }
}
