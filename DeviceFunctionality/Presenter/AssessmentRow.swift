//
//  FunctionalityRow.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 10/1/24.
//

import SwiftUI

struct FunctionalityRow: View {
  let icon: String
  let title: String
  let value: String
  
  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(icon)
        .font(.system(size: 30))
        .frame(maxWidth: .infinity, alignment: .leading)
      
      Text(title)
        .bold()
        .padding(.top, 16)
      
      Text(value)
        .font(.system(size: 14))
        .padding(.top, 3)
    }
    .padding(14)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.gray.opacity(0.1))
    )
  }
}

#Preview {
  FunctionalityRow(icon: "📱", title: "CPU", value: "Let's see if something weird happens on this")
    .frame(width: 200)
}
