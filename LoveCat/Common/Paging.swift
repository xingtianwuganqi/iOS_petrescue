//
//  Paging.swift
//  App-720yun
//
//  Created by AntScript on 04/03/2018.
//  Copyright © 2018 720yun. All rights reserved.
//

import Foundation

//enum Paging {
//	case refresh
//	case next(Int, Int)
//}

//extension Paging: Equatable {
//	static func == (lhs: Paging, rhs: Paging) -> Bool {
//		switch (lhs, rhs) {
//		case (.refresh, .refresh):
//			return true
//
//		case let (.next(a), .next(b)) where a == b:
//			return true
//
//		default:
//			return false
//		}
//	}
//}

enum Paging {
    case refresh
    case next
}
