# Local developer shortcuts (target = dev, uses your .env)
deps:      ; dbt deps
seed:      ; dbt seed
build:     ; dbt seed && dbt run --select elementary && dbt build
test:      ; dbt test
docs:      ; dbt docs generate --static && echo "Open target/static_index.html"
report:    ; edr report --profiles-dir . --profile-target dev
