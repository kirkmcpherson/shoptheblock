# Define Roles
role :app, "67.23.33.108"
role :web, "67.23.33.108"
role :db,  "67.23.33.108", :primary => true

set :rails_env, "production"
