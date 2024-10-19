class RecipesController < ApplicationController
  def index
    @pagy, @recipes = pagy(RecipeSearchService.new(params[:ingredients]).call)
end
