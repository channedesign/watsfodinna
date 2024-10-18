namespace :import do
  desc "Import recipes from JSON file"
  task recipes: :environment do
    json_file_path = Rails.root.join('db', 'recipes-en.json')
    recipes_data = JSON.parse(File.read(json_file_path))

    recipes_data.each do |recipe_data|
      recipe = Recipe.create!(
        title: recipe_data['title'],
        cook_time: recipe_data['cook_time'],
        prep_time: recipe_data['prep_time'],
        ratings: recipe_data['ratings'],
        cuisine: recipe_data['cuisine'],
        category: recipe_data['category'],
        author: recipe_data['author'],
        image: recipe_data['image']
      )

      recipe_data['ingredients'].each do |ingredient_name|
        ingredient = Ingredient.find_or_create_by(name: ingredient_name.downcase)
        RecipeIngredient.create!(recipe: recipe, ingredient: ingredient)
      end
    end
  end
end