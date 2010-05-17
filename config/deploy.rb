require 'erb'
require 'capistrano/ext/multistage'

# General
set :stages, %w{staging production}
set :application, "shoptheblock"
set :deploy_to, "/var/www/apps/#{application}"
#set :deploy_via, :remote_cache


# SSH Info
set :user, "deploy"
set :use_sudo, false
#set :ssh_options, {:forward_agent => true}
default_run_options[:pty] = true


# SCM Info
set :repository,  "git@github.com:brightspark3/shoptheblock.git"
#set :local_repository,  "git@github-az:brightspark3/shoptheblock.git"
set :branch, "master"
set :scm, "git"

set :port, 30745

# Other
set :db_host, "localhost"
set :keep_releases, 7
set :app_symlinks, %w{photos logos}
after "deploy:update", "deploy:cleanup"


namespace :deploy do
 # This task is run for cap deploy:migrations
 task :after_finalize_update, :roles => :app do
   run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
 end

 task :after_symlink, :roles => :app do
   symlinks.update
   #db.create_config
   run "ln -nfs #{shared_path}/config/database.yml #{current_path}/config/database.yml"
 end

 desc "Restart Application"
 task :restart, :roles => :app do
   run "touch #{current_path}/tmp/restart.txt"
 end

 task :before_restart, :roles => [:web] do
   # Copy over robots-disallow-all.txt; only for staging
   run "cp #{current_path}/public/robots-disallow-all.txt #{current_path}/public/robots.txt" if rails_env == "staging"
 end
end


namespace :symlinks do

 desc "Setup application symlinks in the public"
 task :setup, :roles => [:app, :web] do
   if app_symlinks
     app_symlinks.each { |link| run "mkdir -p #{shared_path}/public/#{link}" }
   end
 end

 desc "Link public directories to shared location."
 task :update, :roles => [:app, :web] do
   if app_symlinks
     app_symlinks.each { |link| run "rm -rf #{current_path}/public/#{link};ln -nfs #{shared_path}/public/#{link} #{current_path}/public/#{link}" }
   end
 end

end


namespace :db do

 desc "Dynamically creates and symlinks the database.yml file"
 task :create_config, :roles => :app do
     db_config = ERB.new <<-EOF
 #{rails_env}:
   adapter: mysql
   encoding: utf8
   timeout: 5000
   socket: /var/run/mysqld/mysqld.sock
   database: #{application}_#{rails_env}
   username: root
   password:
   host: #{db_host}
 EOF

     run "mkdir -p #{shared_path}/config"
     put db_config.result, "#{shared_path}/config/database.yml"

     #run "rm #{current_path}/config/database.yml"
     run "ln -nfs #{shared_path}/config/database.yml #{current_path}/config/database.yml"
 end

end

task :tail_log, :roles => :app do
  run "tail -f #{shared_path}/log/#{stage}.log"
end
