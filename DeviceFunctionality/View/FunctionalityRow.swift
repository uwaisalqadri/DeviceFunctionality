//
//  FunctionalityRow.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 10/1/24.
//

import SwiftUI

struct FunctionalityRow: View {
  let item: Assessment
  
  var onTestFunction: (() -> Void)?
  
  var body: some View {
    Button(action: {
      UIImpactFeedbackGenerator().impactOccurred()
      onTestFunction?()
    }) {
      VStack(alignment: .leading, spacing: 0) {
        Text(item.icon)
          .font(.system(size: 30))
          .frame(maxWidth: .infinity, alignment: .leading)
        
        Spacer()
        
        Text(item.title)
          .bold()
          .padding(.top, 16)
        
        Text(item.value)
          .font(.system(size: 14))
          .padding(.top, 3)
          .fixedSize(horizontal: false, vertical: true)
      }
      .frame(height: 130)
      .padding(14)
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(Color.gray.opacity(0.1))
      )
    }.buttonStyle(.plain)
  }
}

#Preview {
  FunctionalityRow(item: .batteryStatus)
    .frame(width: 200)
}
