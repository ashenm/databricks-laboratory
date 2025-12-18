.SILENT: help
help: ## list make targets
	awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf " \033[36m%-20s\033[0m  %s\n", $$1, $$2}' $(MAKEFILE_LIST)

fmt: ## format terraform files
	terraform fmt -recursive -write

fmt-check: ## check terraform file formatting
	terraform fmt -recursive -check

apply: ## apply all terraform units
	terragrunt run apply --all --non-interactive
