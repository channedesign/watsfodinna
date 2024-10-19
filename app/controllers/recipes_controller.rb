class RecipesController < ApplicationController
  def index
    # @pagy, @recipes = pagy(RecipeSearchService.new(params[:ingredients]).call)

    if params[:ingredients]
      @ingredients = params[:ingredients].split(",").map(&:strip).map(&:downcase)
      @pagy, @recipes = pagy(Recipe.with_at_least_one_inputed_ingredients(@ingredients))
    else
      @pagy, @recipes = pagy(Recipe.all)
    end
  end
end
