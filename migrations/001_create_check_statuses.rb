Sequel.migration do
  up do
    create_table :uptime_checker_statuses do
      primary_key :key, :text
      column :data, :jsonb, null: false
    end
  end

  down do
    drop_table :uptime_checker_statuses
  end
end
