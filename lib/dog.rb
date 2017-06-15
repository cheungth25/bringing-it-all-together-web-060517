class Dog

  attr_accessor :name, :breed
  attr_reader :id
  def initialize(name:, breed:, id:nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    if self.id == nil
      DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
    else
      update
    end
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create (name:, breed:)
    new_dog = self.new(name: name, breed: breed)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    find_dog = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0]
    self.new(name:find_dog[1], breed:find_dog[2], id:find_dog[0])
  end

  def self.find_or_create_by(name:, breed:)
    find_dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)[0]
    if !find_dog
      dog = self.create(name:name, breed:breed)
    else
      dog = self.new(name:find_dog[1], breed:find_dog[2], id:find_dog[0])
    end
    dog
  end

  def self.new_from_db(row)
    self.new(name:row[1], breed:row[2], id:row[0])
  end

  def self.find_by_name(name)
    find_dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
    self.new(name:find_dog[1], breed:find_dog[2], id:find_dog[0])
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name= ?, breed= ? WHERE id= ?", self.name, self.breed, self.id)
  end
end
