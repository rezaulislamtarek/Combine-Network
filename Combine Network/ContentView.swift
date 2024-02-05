//
//  ContentView.swift
//  Combine Network
//
//  Created by Rezaul Islam on 30/1/24.
//

import SwiftUI
import Combine

struct ContentView: View {
    var apiService = APIService()
    @State var cancellable: Set<AnyCancellable> = []
    @State var products: [Product] = []
    
    func addProduct(){
        apiService
            .postData(endpoint: "https://fakestoreapi.com/products", requestBody: Product(id: 0, title: "Product Name", image: "url/productImage"), type: Product.self)
            .sink { completion in
                switch completion{
                case .finished:
                    print(completion)
                    break
                case .failure(let error):
                    switch error{
                    case let networkError as NetworkError:
                        switch networkError{
                        case .validationError(let data):
                            print(data)
                            var validateData = try! JSONDecoder().decode(Product.self, from: data)
                        default:
                            print("def")
                        }
                    default:
                        print(error)
                    }
                    
                }
                
            } receiveValue: { res in
                print( res)
            }
            .store(in: &cancellable)

    }
    
    var body: some View {
        VStack {
        
            List(products){ product in
                HStack(){
                    AsyncImage(url: URL(string: product.image)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .cornerRadius(16)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 80, height: 80)
                    }
                    Text(product.title)
                }
            }
        }
        .task {
            print("OnAppear")
            apiService.fetctData(endpoint: "https://fakestoreapi.com/products", type: [Product].self)
                .sink { completion in
                    
                    switch completion{
                    case .finished:
                        print("Success")
                    case .failure(let error):
                        print(error)
                    }
                } receiveValue: { data in
                    products = data
                }
                .store(in: &cancellable)
                 
            
            
        }
        .task {
            addProduct()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
