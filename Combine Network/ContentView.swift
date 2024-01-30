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
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
