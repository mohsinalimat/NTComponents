//
//  Array.swift
//  NTComponents
//
//  Copyright © 2017 Nathan Tannar.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  Created by Nathan Tannar on 6/26/17.
//

public extension Array {
    /**
     Shuffle the array in-place using the Fisher-Yates algorithm.
     */
    public mutating func shuffle() {
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            if j != i {
                swap(&self[i], &self[j])
            }
        }
    }
    
    /**
     Return a shuffled version of the array using the Fisher-Yates
     algorithm.
     
     - returns: Returns a shuffled version of the array.
     */
    public func shuffled() -> [Element] {
        var list = self
        list.shuffle()
        
        return list
    }
    
    /**
     Return a random element from the array.
     - returns: Returns a random element from the array or `nil` if the
     array is empty.
     */
    public func random() -> Element? {
        return (count > 0) ? self.shuffled()[0] : nil
    }
    
    /**
     Return a random subset of `cnt` elements from the array.
     - returns: Returns a random subset of `cnt` elements from the array.
     */
    public func random(_ count : Int = 1) -> [Element] {
        let result = shuffled()
        
        return (count > result.count) ? result : Array(result[0..<count])
    }
}
