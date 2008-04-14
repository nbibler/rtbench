ActiveRecord::Schema.define(:version => 1) do
	create_table :post do |t|
		t.column :title,				:string
		t.column :description,	:string
	end
end
