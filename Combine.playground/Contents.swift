import UIKit
import Combine
let urlStr = "https://api.unsplash.com/photos/random"
let apiK = "9_r4V4DKP2VAKPUskWrL8vvR4B97hne3dHWhlztbNVg"
// https://api.unsplash.com/photos/random
// 9_r4V4DKP2VAKPUskWrL8vvR4B97hne3dHWhlztbNVg

//extension JSONDecoder {
//
//	static func defaultParse<T: Codable>(_ data: Data) throws -> T {
//		try JSONDecoder().decode(T.self, from: data)
//	}
//}
//
//struct CoreNetworkService {
//
//	enum HTTPMethod: String {
//		case get = "GET"
//		case post = "POST"
//	}
//
//	static func doRequest<Result: Codable>(
//		with url: String,
//		parseClosure: @escaping ((Data) throws -> Result) = JSONDecoder.defaultParse,
//		method: HTTPMethod = .get,
//		headers: [String: String] = [:],
//		queryParameters: [String: String] = [:],
//		parameters: [AnyHashable: Any] = [:]
//	)
//	-> AnyPublisher<Result, Error> {
//		var req = URLRequest(url: .init(string: url)!)
//		req.httpMethod = method.rawValue
//		if headers.isEmpty == false {
//			headers.forEach({ key, value in
//				req.setValue(value, forHTTPHeaderField: key)
//			})
//		}
//		if queryParameters.isEmpty == false {
//			var comps = URLComponents(url: req.url!, resolvingAgainstBaseURL: false)
//			comps?.queryItems = queryParameters.map({ key, value in URLQueryItem(name: key, value: value) })
//			req.url = comps?.url
//		}
//		if method != .get {
//			req.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
//		}
//		return Future<Result, Error>.init { promise in
//			URLSession.shared.dataTask(with: req) { data, response, error in
//				guard let data = data else {
//					print(error)
//					promise(.failure(error!))
//					return
//				}
//				do {
//					let value = try parseClosure(data)
//					promise(.success(value))
//				} catch {
//					promise(.failure(error))
//				}
//			}.resume()
//		}
//		.eraseToAnyPublisher()
//	}
//}
//
//let pictureUrlPublisher: PassthroughSubject<String, Never> = .init()
//
//var canc = (0...250).map { _ in
//	let picturePublisher: AnyPublisher<Data, Error> = CoreNetworkService.doRequest(
//		with: urlStr,
//		parseClosure: { data in data },
//		headers: ["Authorization": "Client-ID \(apiK)"]
//	)
//	return picturePublisher.sink { completion in
//		switch completion {
//		case .failure(let error):
//			print(error.localizedDescription)
//		case .finished:
//			print("FINISHED REQUEST")
//		}
//	} receiveValue: { data in
//		let obj = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any]
//		let urls = obj?["urls"] as? [String: Any]
//		let small = urls?["small"] as? String
//		pictureUrlPublisher.send(small ?? "")
//	}
//}
//
//let syncQueue = DispatchQueue(label: "sync")
//var images: [UIImage?] = []
//let canc2 = pictureUrlPublisher.flatMap { str in
//	print(str)
//	return CoreNetworkService.doRequest(with: str, parseClosure: { $0 })
//}
//.sink { completion in
//	switch completion {
//	case .failure(let error):
//		print(error.localizedDescription)
//	case .finished:
//		print("FINISHED REQUEST")
//		print(images)
//	}
//} receiveValue: { data in
//	let img = UIImage(data: data)
//	syncQueue.async {
//		images.append(img)
//	}
//}

let queue = DispatchQueue(label: "ru.pockerhead.MyQUEUE", attributes: .concurrent)

//func foo1(completion: @escaping ((String) -> Void)) {
//	queue.asyncAfter(deadline: .now() + 1.3) {
//		print("foo1")
//		completion("Hello world!")
//	}
//}
//
//func foo2(string: String, completion: @escaping ((Int) -> Void)) {
//	queue.asyncAfter(deadline: .now() + 1.3) {
//		print("foo2 ", string)
//		completion(string.count)
//	}
//}
//
//func foo3(int: Int, completion: @escaping ((Int) -> Void)) {
//	queue.asyncAfter(deadline: .now() + 1.3) {
//		print("foo3 ", int)
//		completion(int * int)
//	}
//}

//foo1 { str in
//	foo2(string: str) { int in
//		foo3(int: int) { int in
//			print(int)
//		}
//	}
//}

let ps = PassthroughSubject<String, Never>()

func foo1() {
//	Future { promise in
		queue.asyncAfter(deadline: .now() + 1.3) {
			print("foo1")
			ps.send("Hello world!")
//			promise(.success(("Hello world!")))

		}
	queue.asyncAfter(deadline: .now() + 3) {
		print("foo1")
		ps.send("Hello world!")
//			promise(.success(("Hello world!")))

	}
//	}
}

func foo2(string: String) -> Future<Int, Never> {
	Future { promise in
		queue.asyncAfter(deadline: .now() + 1.3) {
			print("foo2 ", string)
			promise(.success(string.count))
		}
	}
	
}

func foo3(int: Int) -> Future<Int, Never>  {
	Future { promise in
		queue.asyncAfter(deadline: .now() + 1.3) {
			print("foo3 ", int)
			promise(.success(int * int))
		}
	}
}

var cancellables: [AnyCancellable] = []


ps
	.flatMap { str in
		foo2(string: str)
	}
	.flatMap { int in
		foo3(int: int)
	}
	.sink { result in
		print(result)
	}
	.store(in: &cancellables)
foo1()
RunLoop.current.run()

class Networking {
	
	let images: PassthroughSubject<Data, Never> = .init()
	func download() {
		
	}
}

class ViewModel {
	
	let imagePublisher: PassthroughSubject<UIImage, Never> = .init()
	
	func main() {
		Networking().images.sink { data in
			self.imagePublisher.send(UIImage.init(data: data)!)
		}
	}
}

class View: UIView {
	
	var image = UIImageView()
	
	func configure(with vm: ViewModel) {
		vm.imagePublisher.sink { image in
			self.image.image = image
		}
	}
}
