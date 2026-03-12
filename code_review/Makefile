.PHONY: clean clean-all help review

# 默认目标
help:
	@echo "Verilog Code Review Tool - Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  make clean [TARGET]      - 清除指定 example/<TARGET>/output/ 中的输出文件"
	@echo "                             示例: make clean uart_tx"
	@echo "                             不指定 TARGET 时清除所有 output 目录"
	@echo "  make clean-all [TARGET]  - 清除指定 example/<TARGET>/output/ 中的所有文件"
	@echo "  make review              - 对 example/uart_tx/*.v 进行代码审查"
	@echo "  make help                - 显示此帮助信息"

# 清除 output 目录中的 .md 文件和 review_progress.json
# 用法: make clean [TARGET]
clean:
	@if [ -n "$(TARGET)" ]; then \
		echo "清除 example/$(TARGET)/output/ 中的输出文件..."; \
		if [ -d "example/$(TARGET)/output" ]; then \
			find example/$(TARGET)/output -type f -name "*.md" -exec rm -f {} +; \
			rm -f example/$(TARGET)/output/review_progress.json; \
			find example/$(TARGET)/output -type d -empty -delete; \
			echo "✓ 已清除 example/$(TARGET)/output/ 中的输出文件 (.md 和 .json)"; \
		else \
			echo "! example/$(TARGET)/output/ 目录不存在"; \
		fi \
	else \
		echo "清除所有 example/*/output/ 中的输出文件..."; \
		for dir in example/*/output; do \
			if [ -d "$$dir" ]; then \
				find "$$dir" -type f -name "*.md" -exec rm -f {} +; \
				rm -f "$$dir"/review_progress.json; \
				find "$$dir" -type d -empty -delete; \
				echo "✓ 已清除 $$dir 中的输出文件"; \
			fi \
		done \
	fi

# 清除 output 目录中的所有文件
# 用法: make clean-all [TARGET]
clean-all:
	@if [ -n "$(TARGET)" ]; then \
		echo "清除 example/$(TARGET)/output/ 中的所有文件..."; \
		if [ -d "example/$(TARGET)/output" ]; then \
			rm -rf example/$(TARGET)/output/*; \
			echo "✓ 已清除 example/$(TARGET)/output/ 中的所有文件"; \
		else \
			echo "! example/$(TARGET)/output/ 目录不存在"; \
		fi \
	else \
		echo "清除所有 example/*/output/ 中的所有文件..."; \
		for dir in example/*/output; do \
			if [ -d "$$dir" ]; then \
				rm -rf "$$dir"/*; \
				echo "✓ 已清除 $$dir 中的所有文件"; \
			fi \
		done \
	fi

# 代码审查目标（示例）
review:
	@echo "开始代码审查: example/uart_tx/*.v"
	@echo "请使用 Claude Code Skill 调用:"
	@echo '  "调用skill verilog_review, 对example/uart_tx/*.v文件进行审查"'
