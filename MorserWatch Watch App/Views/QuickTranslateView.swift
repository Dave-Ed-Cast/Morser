//
//  QuickTranslateView.swift
//  MorserWatch Watch App
//
//  Created by Giuseppe Francione on 26/05/24.
//

import SwiftUI
import CoreData

struct QuickTranslateView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.order, order: .forward)]) private var sentences: FetchedResults<Sentence>
    @Environment(\.managedObjectContext) var moc
    @ObservedObject private var vibrationEngine = VibrationEngine.shared
    var body: some View {
        NavigationView {
            List {
                ForEach(sentences.toArray().sorted(by: { sent1, sent2 in
                    return sent1.order < sent2.order
                })) { sentence in

                    // MARK: Now 'Text' is a button to tap in the list
                    Button {
                        if !vibrationEngine.isVibrating() {
                            WatchCommunicationManager.shared.sendVibrationRequest(sentence.sentence!)
                            vibrationEngine.readMorseCode(morseCode: sentence.sentence!.morseCode())
                        } else if vibrationEngine.morseCodeString == sentence.sentence!.morseCode() {
                            vibrationEngine.stopReading()
                        }
                    } label: {
                        Text(sentence.sentence!)
                    }
                    // MARK: End of change

                    .if(vibrationEngine.isVibrating() && vibrationEngine.morseCodeString == sentence.sentence!.morseCode()) { view in
                        view.listRowBackground(Color.blue)
                    }
                    .if((vibrationEngine.isVibrating() && vibrationEngine.morseCodeString != sentence.sentence!.morseCode())) { view in
                        view
                            .foregroundStyle(Color.gray)
                    }
                }
                .if(!vibrationEngine.isVibrating(), transform: { view in
                    view
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                moc.delete(sentences[index])
                            }
                            do {
                                try moc.save()
                            } catch {
                                print("Error: \(error)")
                            }
                        }
                        .onMove(perform: { source, destination in
                            var tempItems = sentences.toArray()
                            tempItems.move(fromOffsets: source, toOffset: destination)
                            tempItems.indices.forEach({ index in
                                sentences.filter({ $0.sentence! == tempItems[index].sentence!}).first!.order = Int32(index)
                            })
                            do {
                                try moc.save()
                            } catch {
                                print("Error: \(error)")
                            }
                        })
                })
            }
            .listStyle(.plain)
            .navigationTitle("Quick Translate")
            .onAppear {
                ensureSentencesExist(sentences, moc)
            }
        }
    }
}

struct QuickTranslateView_Previews: PreviewProvider {
    static var previews: some View {
        let dataController = DataController()
        let context = dataController.container.viewContext

        let sentence1 = Sentence(context: context)
        sentence1.sentence = "I'm here to help."
        sentence1.order = 0

        let sentence2 = Sentence(context: context)
        sentence2.sentence = "Yes, I can guide you."
        sentence2.order = 1

        let sentence3 = Sentence(context: context)
        sentence3.sentence = "I understand, let me assist you."
        sentence3.order = 2

        return Group {

            VStack {
                QuickTranslateView()
                    .environment(\.managedObjectContext, context)
            }
            VStack {
                QuickTranslateView()
                    .environment(\.managedObjectContext, context)
                    .preferredColorScheme(.dark)
            }
        }
    }
}
