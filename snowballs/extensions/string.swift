//
//  string.swift
//  snowballs
//
//  Created by Teodor Chicinaș on 9/2/24.
//

import Foundation

extension String {
    func encodeHTMLEntities() -> String {
        var result = ""
        for scalar in self.unicodeScalars {
            switch scalar {
            case "&":
                result.append("&amp;")
            case "<":
                result.append("&lt;")
            case ">":
                result.append("&gt;")
            case "\"":
                result.append("&quot;")
            case "'":
                result.append("&apos;")
            default:
                if scalar.isASCII {
                    result.append(String(scalar))
                } else {
                    result.append("&#\(scalar.value);")
                }
            }
        }
        return result
    }
}
