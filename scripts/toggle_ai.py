# -*- coding: utf-8 -*-
"""
Toggle AI analysis and translation on/off in config.yaml for TrendRadar.
"""

import os
import shutil
from pathlib import Path

import yaml

CONFIG_PATH = Path(__file__).parent.parent / "config" / "config.yaml"


def main() -> None:
    if not CONFIG_PATH.exists():
        print(f"配置文件不存在: {CONFIG_PATH}")
        return

    with open(CONFIG_PATH, "r", encoding="utf-8") as f:
        content = f.read()

    config = yaml.safe_load(content)

    ai_analysis = config.setdefault("ai_analysis", {})
    ai_translation = config.setdefault("ai_translation", {})

    current = bool(ai_analysis.get("enabled", False))
    new_state = not current

    ai_analysis["enabled"] = new_state
    ai_translation["enabled"] = new_state

    # Backup before writing
    backup_path = CONFIG_PATH.with_suffix(".yaml.bak")
    shutil.copy2(CONFIG_PATH, backup_path)

    with open(CONFIG_PATH, "w", encoding="utf-8") as f:
        yaml.dump(config, f, allow_unicode=True, sort_keys=False, default_flow_style=False)

    status = "开启" if new_state else "关闭"
    print(f"AI 分析 / AI 翻译已切换为: {status}")
    print(f"备份已保存: {backup_path}")


if __name__ == "__main__":
    main()
