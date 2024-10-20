class RecipesController < ApplicationController
  def index
    begin 
      if params[:ingredients].present?
        @ingredients = params[:ingredients].split(",").map(&:strip).map(&:downcase)

        recipe_ids = Recipe.with_all_inputed_ingredients(@ingredients).pluck(:id) # can't use .includes(:ingredients) because of the use of GROUP BY with aggregate functions in ActiveRecord.
        recipes = Recipe.includes(:ingredients).where(id: recipe_ids)

        # Apply optional params if present
        recipes = recipes.with_max_cooking_time(params[:max_cook_time]) if params[:max_cook_time].present?
        recipes = recipes.with_max_preparation_time(params[:max_prep_time]) if params[:max_prep_time].present?
        recipes = recipes.with_min_ratings(params[:min_ratings]) if params[:min_ratings].present?

        @pagy, @recipes = pagy(recipes)
      else
        @pagy, @recipes = pagy(Recipe.includes(:ingredients).all)
      end
    
    rescue ActiveRecord::RecordNotFound => e
      flash.now[:alert] = "No recipes found."
      @pagy, @recipes = pagy(Recipe.includes(:ingredients).none)

    rescue => e
      flash.now[:alert] = "An error occurred: #{e.message}"
      @pagy, @recipes = pagy(Recipe.includes(:ingredients).none)
      Rails.logger.error("Error fetching recipes: #{e.message}")
    end
  end
end
