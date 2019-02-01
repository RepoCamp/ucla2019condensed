unless Rails.env.production?

  desc "Run Continuous Integration"
  task :ci do
    Rake::Task["spec"].invoke
  end
end