class RecipeSearchService
  SORTABLE_COLUMNS = %w[ratings cook_time prep_time].freeze
  ALLOWED_ORDERS = %w[asc desc].freeze

  def initialize(params)
    @params = params
    @recipes = Recipe.includes(:ingredients).all
  end

  def call
    if @params[:ingredients].present?
      filter_by_inputed_ingredients 
      apply_optional_filters
    end
    apply_sorting
    @recipes
  end

  private

  def filter_by_inputed_ingredients
    ingredients = @params[:ingredients].split(",").map(&:strip).map(&:downcase)
    recipe_ids = Recipe.with_all_inputed_ingredients(ingredients).pluck(:id)
    @recipes = @recipes.where(id: recipe_ids)
  end

  def apply_optional_filters
    @recipes = @recipes.with_max_cooking_time(@params[:max_cook_time]) if @params[:max_cook_time].present?
    @recipes = @recipes.with_max_preparation_time(@params[:max_prep_time]) if @params[:max_prep_time].present?
    @recipes = @recipes.with_min_ratings(@params[:min_ratings]) if @params[:min_ratings].present?
  end

  def apply_sorting
    sort_by = SORTABLE_COLUMNS.include?(@params[:sort_by]) ? @params[:sort_by] : 'ratings'
    order = ALLOWED_ORDERS.include?(@params[:order]) ? @params[:order] : 'desc'
    @recipes = @recipes.order(sort_by => order)
  end
end