namespace :import do
  desc "Import recipes from JSON file in batches"
  task recipes_in_batch: :environment do
    json_file_path = Rails.root.join('db', 'recipes-en.json')
    recipes_data = JSON.parse(File.read(json_file_path))
    batch_size = 1000

    import_recipes(recipes_data, batch_size)

    puts "Recipes imported successfully!"
  end

  def import_recipes(recipes_data, batch_size)
    current_time = Time.now
    recipe_batch = []
    ingredients_batch = []
    recipe_ingredients_batch = []
    ingredients_cache = {}
    new_ingredients = []

    recipes_data.each do |recipe_data|
      recipe_batch << build_recipe_hash(recipe_data, current_time)
      ingredients_batch << recipe_data['ingredients']

      # Insert recipes in batches
      if recipe_batch.size >= batch_size
        insert_batches(recipe_batch, ingredients_batch, recipe_ingredients_batch, ingredients_cache, new_ingredients, current_time)
      end
    end

    # Insert any remaining recipes
    insert_batches(recipe_batch, ingredients_batch, recipe_ingredients_batch, ingredients_cache, new_ingredients, current_time) unless recipe_batch.empty?
  end

  def build_recipe_hash(recipe_data, current_time)
    {
      title: recipe_data['title'],
      cook_time: recipe_data['cook_time'],
      prep_time: recipe_data['prep_time'],
      ratings: recipe_data['ratings'],
      cuisine: recipe_data['cuisine'],
      category: recipe_data['category'],
      author: recipe_data['author'],
      image: recipe_data['image'],
      created_at: current_time,
      updated_at: current_time
    }
  end

  def insert_batches(recipe_batch, ingredients_batch, recipe_ingredients_batch, ingredients_cache, new_ingredients, current_time)
    Recipe.transaction do
      inserted_recipes = Recipe.insert_all(recipe_batch, returning: %w[id])

      process_and_insert_ingredients_batch(ingredients_batch, ingredients_cache, new_ingredients, current_time)

      inserted_recipes.rows.each_with_index do |(recipe_id), index|
        ingredients = ingredients_batch[index]
        ingredients.each do |ingredient_name|
          ingredient_name = ingredient_name.downcase.strip
          ingredient = ingredients_cache[ingredient_name]

          recipe_ingredients_batch << {
            recipe_id: recipe_id,
            ingredient_id: ingredient.id,
            created_at: current_time,
            updated_at: current_time
          }
        end
      end

      RecipeIngredient.insert_all(recipe_ingredients_batch) unless recipe_ingredients_batch.empty?
    end

    # Clear batches after inserting
    recipe_batch.clear
    ingredients_batch.clear
    recipe_ingredients_batch.clear
  end

  def process_and_insert_ingredients_batch(ingredients_batch, ingredients_cache, new_ingredients, current_time)
    ingredients_batch.each do |ingredients|
      ingredients.each do |ingredient_name|
        ingredient_name = ingredient_name.downcase.strip

        # Check if the ingredient is in the cache
        unless ingredients_cache[ingredient_name]
          build_new_ingredients(new_ingredients, ingredients_cache, ingredient_name, current_time)
        end
      end
    end
    
    insert_new_ingredients_and_update_cache(new_ingredients, ingredients_cache) unless new_ingredients.empty?
  end

  def build_new_ingredients(new_ingredients, ingredients_cache, ingredient_name, current_time)
    ingredient_obj = { name: ingredient_name, created_at: current_time, updated_at: current_time }
    new_ingredients << ingredient_obj
    ingredients_cache[ingredient_name] = ingredient_obj
  end

  def insert_new_ingredients_and_update_cache(new_ingredients, ingredients_cache)
    inserted_ingredients = Ingredient.insert_all(new_ingredients, returning: %w[id name])
    inserted_ingredients.rows.each do |(id, name)|
      ingredients_cache[name] = Ingredient.new(id: id, name: name)
    end
    new_ingredients.clear
  end
end
