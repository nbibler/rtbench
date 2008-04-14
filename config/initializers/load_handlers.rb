Dir.glob(File.join(RAILS_ROOT, 'app/models/handlers/**/*.rb')) do |handler|
	require handler
end