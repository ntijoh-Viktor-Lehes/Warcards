require 'sinatra'
require 'bcrypt'
require 'sqlite3'

#Connect to the database
def connectToDb()
    db = SQLite3::Database.new("../db/warcardsdb.db")
    db.results_as_hash = true
    return db
end

#Check if the user exists in the database
def getUserByUsername(username)
    db = connectToDb()
    user = db.execute("SELECT * FROM users WHERE username=?", username).first || nil
    return user
end

#create user with username and password, return status code 200 if user created, and userId
def createUser(username, password, passwordConfirm)
    status = 200
    db = connectToDb()
    user = getUserByUsername(username)

    if password != passwordConfirm
        return status = 400
    end

    if user 
        return status = 400
    end

    passwordDigest = BCrypt::Password.create(password)
    db.execute(
      "INSERT INTO users (username, passwordDigest) VALUES (?, ?);",
      [username.downcase, passwordDigest]
    )
    userId = user["id"]

    return status, userId 
end

def loginUser(username, password)
    status = 200
    db = connectToDb()

    user = getUserByUsername(username)

    if BCrypt::Password.new(user["passwordDigest"]) != password 
        return status = 400
    end

    userId = user["id"]

    return status, userId 
end

# Get all users ranked by hs from highest to lowest, return array of users
def fetchSortedUsersbyHs()

    db = connectToDb()

    sortedUsersbyHs = db.execute("SELECT * FROM users ORDER BY highscore DESC")

    return sortedUsersbyHs
end

# Get all cards, return array of cards with cardId, name, img_url
def fetchCards()

    db = connectToDb()

    cards = db.execute("SELECT * FROM cards")

    return cards
end
