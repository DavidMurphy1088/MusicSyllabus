//
//  MusicSyllabusApp.swift
//  MusicSyllabus
//
//  Created by David Murphy on 5/3/23.
//

import SwiftUI

@main
struct MusicSyllabusApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
