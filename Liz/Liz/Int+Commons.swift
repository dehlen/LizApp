import Foundation

extension Int {
    func times(block : () -> ()) {
        for _ in 0..<self {
            block()
        }
    }

    func times(block: (Int) -> ()) -> Int {
        for i in 0..<self {
            block(i)
		}
        return self
	}
}
