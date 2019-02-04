CSV_FILE = "#{::Rails.root}/spec/fixtures/csv_files/three_line_example.csv"

namespace :csv_import do
  desc 'Import the three line sample CSV'
  task :simple_import => [:environment] do |_task|
    SimpleImporter.new(CSV_FILE).import
  end
end
