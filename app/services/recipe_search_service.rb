class RecipeSearchService
  def initialize(user_inputed_ingredients)
    @ingredients = user_inputed_ingredients.split(",").map(&:strip).map(&:downcase) if user_inputed_ingredients
  end

  def call
    return Recipe.all unless @ingredients.present?
    
    # Start with all recipes
    matching_recipes = Recipe.all

    # Iterate through each ingredient from the input
    @ingredients.each do |ingredient|
      # Store the current matching recipes that have this ingredient
      current_matching_recipes = matching_recipes.joins(:ingredients)
                                                  .where('ingredients.name LIKE ?', "%#{ingredient}%")
                                                  .distinct

      # Check if current matching recipes are the same as previous
      matching_recipes = matching_recipes.where(id: current_matching_recipes.pluck(:id))
    end

    matching_recipes
  end
end