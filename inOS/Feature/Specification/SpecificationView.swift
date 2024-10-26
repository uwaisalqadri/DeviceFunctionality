//
//  SpecificationView.swift
//  DeviceFunctionality
//
//  Created by Uwais Alqadri on 27/10/24.
//

import Foundation
import SwiftUI

struct SpecificationView: View {
  let models: [Model]
  
  init(_ models: [Model]) {
    self.models = models
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text("Device Component")
          .fontWeight(.bold)
          .frame(maxWidth: .infinity, alignment: .leading)
        Text("Status")
          .fontWeight(.bold)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .padding()
      .background(Color.gray.opacity(0.2))
      
      List(models) { model in
        HStack {
          Text(model.title)
            .frame(maxWidth: .infinity, alignment: .leading)
          Text(model.value)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
      }
      .listStyle(PlainListStyle())
    }
    .padding()
  }
}

extension SpecificationView {
  struct Model: Identifiable {
    let id = UUID()
    let title: String
    let value: String
  }
}

#Preview {
  SpecificationView([])
}
