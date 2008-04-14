Dir.glob(File.join(RAILS_ROOT, 'app/models/tasks/**/*.rb')) do |task|
	require task
end