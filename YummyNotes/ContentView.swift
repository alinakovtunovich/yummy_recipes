import SwiftUI

struct RecipeResponse: Codable {
    let recipe: [Recipe]
}

struct Recipe: Codable, Identifiable {
    let id: String
    let name: String?
    let description: String
    let tag: [String]
    let ingredient: [Ingredient]
    let step: [RecipeStep]
    var image: String // Используем строку для хранения имени изображения
}

struct Ingredient: Codable {
    let amount: String?
    let unit: String?
    let name: String?
    let preparation: String?
}

struct RecipeStep: Codable, Hashable {
    let description: String
}

class RecipeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []

    func fetchRecipes() {
        if let jsonURL = Bundle.main.url(forResource: "Recipes", withExtension: "json") {
            do {
                let data = try Data(contentsOf: jsonURL)
                let decoder = JSONDecoder()
                let response = try decoder.decode(RecipeResponse.self, from: data)

                // Фильтрация рецептов, оставляем только те, у которых есть имя
                let filteredRecipes = response.recipe.filter { $0.name != nil }

                DispatchQueue.main.async {
                    self.recipes = filteredRecipes
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        } else {
            print("JSON-файл не найден")
        }
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = RecipeViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.recipes) { recipe in
                NavigationLink(destination: RecipeDetailView(recipe: recipe, viewModel: viewModel)) {
                    HStack {
                        // Display the recipe image
                        Image(recipe.image)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .cornerRadius(8)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2)) // Добавьте белую обводку, если необходимо
                            .shadow(radius: 5) // Добавьте тень, если необходимо

                        // Display the recipe name
                        VStack(alignment: .leading) {
                            Text(recipe.name ?? "")
                                .font(.headline)
                            // Other recipe details you want to display
                        }
                    }
                }
            }
            .onAppear {
                viewModel.fetchRecipes()
            }
            .navigationTitle("🤎Recipes🤎")
        }
    }
}

struct RecipeStepView: View {
    var stepDescription: String

    var body: some View {
        VStack {
            Text(stepDescription)
                .font(.body)
                .padding()
        }
    }
}

struct RecipeDetailView: View {
    var recipe: Recipe
    var viewModel: RecipeViewModel

    @State private var selectedStepIndex = 0
    @State private var showingSteps = false // Добавлено новое состояние для отображения окна с шагами

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                                // Display the recipe image
                                Image(recipe.image)
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(10)
                                    .padding(.bottom, 8)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                    .shadow(radius: 5)

                                // Display the ingredients
                                Text("Ingredients:")
                                    .font(.headline)
                                    .padding(.bottom, 8)

                                ForEach(recipe.ingredient, id: \.name) { ingredient in
                                    Text("\(ingredient.amount ?? "") \(ingredient.unit ?? "") \(ingredient.name ?? "")")
                                        .padding(.leading)
                                }

//                                 Display the steps
//                                Text("Steps:")
//                                    .font(.headline)
//                                    .padding(.top, 16)
//                                    .padding(.bottom, 8)
//
//                                TabView(selection: $selectedStepIndex) {
//                                    ForEach(0..<recipe.step.count, id: \.self) { index in
//                                        RecipeStepView(stepDescription: recipe.step[index].description)
//                                            .tag(index)
//                                    }
//                                }
//                                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
//                                .padding()

                // NavigationLink to show steps separately
                               NavigationLink(destination: StepsView(recipe: recipe), isActive: $showingSteps) {
                                   EmptyView()
                               }
                               .hidden() // Hidden, but will be activated programmatically

                               Button(action: {
                                   showingSteps = true // Activate the NavigationLink to show the steps
                               }) {
                                   HStack {
                                       Spacer()
                                       Text("Steps")
                                           .foregroundColor(.white)
                                       Spacer()
                                   }
                                   .padding()
                                   .background(Color.gray) // You can change the color as per your design
                                   .cornerRadius(10)
                                   .padding(.bottom, 16)
                               }
                           }
                           .padding()
                       }
                       .navigationTitle(recipe.name ?? "")
                   }
               }

               // StepsView to display steps separately
struct StepsView: View {
    var recipe: Recipe

    @State private var selectedStepIndex = 0

    var body: some View {
        VStack {
            TabView(selection: $selectedStepIndex) {
                ForEach(0..<recipe.step.count, id: \.self) { index in
                    RecipeStepView(stepDescription: recipe.step[index].description)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .padding()
            if selectedStepIndex < recipe.step.count - 1 {
                Button(action: {
                    withAnimation {
                        selectedStepIndex = min(selectedStepIndex + 1, recipe.step.count - 1)
                    }
                }) {
                    HStack {
                        Spacer()
                        Text("Next Step")
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(10)
                    .padding(.bottom, 16)
                    .frame(width: 150)
                }
                .disabled(selectedStepIndex == recipe.step.count - 1) // Disable button on the last step
            }

        }
        .navigationTitle("Steps")
    }
}
