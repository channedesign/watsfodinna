class RecipesController < ApplicationController
  def index
    begin 
      recipe_search_service = RecipeSearchService.new(params)
      @pagy, @recipes = pagy(recipe_search_service.call)

      respond_to do |format|
        format.html
        format.json {
          render json: {
            recipes_html: render_to_string(partial: 'recipe_list', locals: { recipes: @recipes }, formats: [:html]),
            pagination_html: render_to_string(partial: 'pagination', locals: { pagy: @pagy }, formats: [:html])
          }
        }
      end
    
    rescue ActiveRecord::RecordNotFound
      flash.now[:alert] = "No recipes found."
      @pagy, @recipes = pagy(Recipe.none)
      render json: { error: "No recipes found" }, status: :not_found

    rescue => e
      flash.now[:alert] = "An error occurred: #{e.message}"
      @pagy, @recipes = pagy(Recipe.none)
      Rails.logger.error("Error fetching recipes: #{e.message}")
      render json: { error: "An error occurred: #{e.message}" }, status: :internal_server_error
    end
  end
end
