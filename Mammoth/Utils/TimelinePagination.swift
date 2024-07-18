//
//  TimelinePagination.swift
//  Mammoth
//
//  Created by Nick Ludlam on 18/07/2024
//  Copyright © 2024 The BLVD. All rights reserved.
//

import Foundation

// This is a union of a Pagination response and a cursorId, specifically used in the TimelineService
// as this mixes unpaginated requests which can arbitrarily have a RequestRange constructed from
// any Status item, and feeds like bookmarks and favourites which must explicitly use the pagination
// data returned in the header of API responses, thus this pagination data needs storing in this enum

enum TimelinePagination {
    case cursorId(String)
    case pagination(Pagination)
}
