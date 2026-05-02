# Default task: Runs dev
task default: :dev 

desc "Start server in development mode"
task :dev do
  puts "[Crystal Chalk] Starting in development mode..."
  exec({ "APP_ENV" => "development" }, "ruby bin/server")
end

desc "Start server in production mode"
task :prod do 
  puts "[Crystal Chalk] Starting in production mode..."
  exec({ "APP_ENV" => "production" }, "ruby bin/server")
end

desc "Print all registered routes"
task :routes do
  # Prints all registered Sinatra routes without starting the server.
  require_relative "lib/app"
  puts "\nRegistered routes:"
  App.routes.each do |method, routes|
    routes.each do |route|
      puts "  #{method} #{route[0]}"
    end
  end
end

desc "Delete rouge.css so it regenerates on next start"
task :clean do
  rouge_css = File.join("public", "assets", "rouge.css")
  if File.exist?(rouge_css)
    File.delete(rouge_css)
    puts "[Crystal Chalk] Deleted rouge.css. It will regenerate on next start."
  else
    puts "[Crystal Chalk] rouge.css not found, nothing to clean."
  end
end