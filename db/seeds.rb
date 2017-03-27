# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Restaurant.create(name:"Praha", tables_count:30, time_open:"08:00", time_close:"01:00")
Restaurant.create(name:"Astoria", tables_count:20, time_open:"07:00", time_close:"01:00")
Restaurant.create(name:"Savoy", tables_count:15, time_open:"06:00", time_close:"01:00")

User.create(name:"John")
