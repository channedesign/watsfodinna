class Recipe < ApplicationRecord
  has_many :recipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients

  scope :with_all_inputed_ingredients, ->(ingredient_list) {
    joins(:ingredients)
      .group("recipes.id")
      .having(ingredient_list.map { "SUM(CASE WHEN ingredients.name ILIKE ? THEN 1 ELSE 0 END) > 0" }.join(" AND "), *ingredient_list.map { |ingredient| "%#{ingredient}%" })
  }

  scope :with_max_cooking_time, ->(max_cook_time) {
    where('cook_time <= ?', max_cook_time)
  }

  scope :with_max_preparation_time, ->(max_prep_time) {
    where('prep_time <= ?', max_prep_time)
  }

  scope :with_min_ratings, ->(min_ratings) {
    where('ratings >= ?', min_ratings)
  }

  scope :order_by_ratings, ->() {
    order(ratings: :desc)
  }

end
