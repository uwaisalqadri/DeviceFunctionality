//
//  AssessmentRow.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 10/1/24.
//

import SwiftUI

struct AssessmentRow: View {
  let iconName: String
  let title: String
  let value: String
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Image(systemName: iconName)
        .imageScale(.large)
        .foregroundColor(.accentColor)
      
      Text(title + ": ") +
      Text(value)
        .bold()
    }
  }
}
