def db_connection
  begin
    connection = PG.connect(dbname: 'recipes')

    yield(connection)

  ensure
    connection.close
  end
end

class Recipe
  attr_reader :id, :name, :description, :instructions

  def initialize(name, description, instructions, id)
    @name = name
    @description = description
    @instructions = instructions
    @id = id
  end

  def self.all
    array = []
    recipes = []
    
    db_connection do |conn|
      @recipe = conn.exec("SELECT recipes.name, recipes.description,
      recipes.instructions, recipes.id
      FROM recipes")
    end

    array = @recipe.to_a

    array.each do |hash|
      @rec_obj = Recipe.new(hash["name"], hash["description"],
      hash["instructions"], hash["id"] )
      recipes << @rec_obj
    end
    recipes
  end

  def self.find(id)
    self.all.each do |recipe|
      if id == recipe.id
        @recipe_instance = Recipe.new(recipe.name, recipe.description, recipe.instructions, recipe.id)
      end
    end
    @recipe_instance
  end

  def ingredients
    array = []
    ingredients = []

    db_connection do |conn|
      @ingredients = conn.exec("SELECT ingredients.name, ingredients.id,
      ingredients.recipe_id FROM ingredients
      JOIN recipes ON recipes.id = ingredients.recipe_id")
    end

    array = @ingredients.to_a
    array.each do |hash|
      @ingredient_obj = Ingredient.new(hash["id"], hash["name"], hash["recipe_id"])
      if @ingredient_obj.recipe_id == @id
        ingredients << @ingredient_obj
      end
    end
    ingredients
  end

end
