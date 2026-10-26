//
//  CollageTemplatePickerView.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-26.
//

import Foundation
import SwiftUI


struct CollageTemplatePickerView: View {
    @ObservedObject var viewModel: CollageViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose a design")
                .font(MemoFont.dmSansSemiBold(18))
                .foregroundStyle(MemoMapTheme.black)
            HStack(spacing: 12) {
                ForEach(CollageTemplate.allCases) { template in
                    templateButton(template)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    private func templateButton(
        _ template: CollageTemplate
    ) -> some View {
        let isSelected = viewModel.selectedTemplate == template
        return Button {
            viewModel.selectTemplate(template)
        } label: {
            VStack(spacing: 6) {
                Image(systemName: template.symbol)
                    .font(.system(size: 21, weight: .medium))
                    .foregroundStyle(
                        isSelected
                            ? MemoMapTheme.White
                            : MemoMapTheme.green
                    )
                    .frame(width: 52, height: 48)
                    .background(
                        isSelected
                            ? MemoMapTheme.green
                            : MemoMapTheme.White
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 13,
                            style: .continuous
                        )
                    )
                    .overlay {
                        RoundedRectangle(
                            cornerRadius: 13,
                            style: .continuous
                        )
                        .stroke(
                            isSelected
                                ? MemoMapTheme.green
                                : MemoMapTheme.inputBorder,
                            lineWidth: 1
                        )
                    }
                Text(template.title)
                    .font(MemoFont.dmSansRegular(10))
                    .foregroundStyle(
                        isSelected
                            ? MemoMapTheme.green
                            : MemoMapTheme.Textsecondary
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(template.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
