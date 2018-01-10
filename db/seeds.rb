# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
include ApplicationHelper

Role.where({name: 'admin'}).first_or_create
Role.where({name: 'user' }).first_or_create

# This doesn't work with devise for some reason
# User.where({name: 'Anonymous', email: anonymous_email, encrypted_password: "$2a$11$AXQ/5kNudC2vorDn9ssSXODHeyLnv7N/OQSz02/sgCO1x8/dtJOrW"}).first_or_create
User.new({name: 'Anonymous', email: anonymous_email, password: "foobar"}).save
