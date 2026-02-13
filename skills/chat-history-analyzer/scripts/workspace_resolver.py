#!/usr/bin/env python3
"""
Cursor Workspace Resolver

プロジェクトパスからCursorのワークスペースハッシュを解決し、
該当ワークスペースの会話IDリストを取得する。

使用方法:
    python3 workspace_resolver.py /path/to/project

データソース:
    - ~/Library/Application Support/Cursor/User/workspaceStorage/<hash>/workspace.json
    - ~/Library/Application Support/Cursor/User/workspaceStorage/<hash>/state.vscdb
"""

import json
import sqlite3
import sys
from pathlib import Path
from typing import Dict, List, Optional
from urllib.parse import unquote, urlparse


# Cursor storage paths
CURSOR_WORKSPACE_STORAGE = Path.home() / "Library" / "Application Support" / "Cursor" / "User" / "workspaceStorage"
CURSOR_GLOBAL_STORAGE = Path.home() / "Library" / "Application Support" / "Cursor" / "User" / "globalStorage"
CURSOR_AI_TRACKING = Path.home() / ".cursor" / "ai-tracking" / "ai-code-tracking.db"


def normalize_project_path(project_path: str) -> str:
    """プロジェクトパスを正規化する"""
    return str(Path(project_path).resolve())


def find_workspace_hash(project_path: str) -> Optional[str]:
    """
    プロジェクトパスに対応するワークスペースハッシュを検索する。

    Args:
        project_path: プロジェクトの絶対パス

    Returns:
        ワークスペースハッシュ文字列。見つからない場合はNone。
    """
    normalized = normalize_project_path(project_path)

    if not CURSOR_WORKSPACE_STORAGE.exists():
        return None

    for entry in CURSOR_WORKSPACE_STORAGE.iterdir():
        if not entry.is_dir():
            continue
        workspace_json = entry / "workspace.json"
        if not workspace_json.exists():
            continue

        try:
            with open(workspace_json) as f:
                data = json.load(f)
            folder_uri = data.get("folder", "")
            # file:///Users/... 形式からパスを抽出
            if folder_uri.startswith("file://"):
                parsed = urlparse(folder_uri)
                folder_path = unquote(parsed.path)
                if normalize_project_path(folder_path) == normalized:
                    return entry.name
        except (json.JSONDecodeError, OSError):
            continue

    return None


def get_workspace_db_path(workspace_hash: str) -> Optional[Path]:
    """ワークスペースDBのパスを取得する"""
    db_path = CURSOR_WORKSPACE_STORAGE / workspace_hash / "state.vscdb"
    return db_path if db_path.exists() else None


def get_global_db_path() -> Optional[Path]:
    """グローバルDBのパスを取得する"""
    db_path = CURSOR_GLOBAL_STORAGE / "state.vscdb"
    return db_path if db_path.exists() else None


def get_conversation_ids(workspace_hash: str) -> List[Dict]:
    """
    ワークスペースDBから会話IDとメタデータのリストを取得する。

    Args:
        workspace_hash: ワークスペースハッシュ

    Returns:
        会話情報のリスト。各要素は {"id": str, "name": str, "type": str}
    """
    db_path = get_workspace_db_path(workspace_hash)
    if not db_path:
        return []

    conversations = []
    try:
        conn = sqlite3.connect(str(db_path))
        cursor = conn.cursor()
        cursor.execute(
            "SELECT value FROM ItemTable WHERE key = 'composer.composerData'"
        )
        row = cursor.fetchone()
        if row:
            val = row[0]
            if isinstance(val, bytes):
                data = json.loads(val.decode("utf-8"))
            else:
                data = json.loads(val)

            all_composers = data.get("allComposers", [])
            for c in all_composers:
                if isinstance(c, dict):
                    conversations.append(
                        {
                            "id": c.get("composerId", ""),
                            "name": c.get("name", "N/A"),
                            "type": c.get("type", "unknown"),
                        }
                    )
        conn.close()
    except (sqlite3.Error, json.JSONDecodeError, OSError) as e:
        print(f"Warning: Failed to read workspace DB: {e}", file=sys.stderr)

    return conversations


def resolve_workspace(project_path: str) -> Optional[Dict]:
    """
    プロジェクトパスからワークスペース情報を完全解決する。

    Args:
        project_path: プロジェクトの絶対パス

    Returns:
        ワークスペース情報の辞書。解決できない場合はNone。
        {
            "project_path": str,
            "workspace_hash": str,
            "workspace_db": str,
            "global_db": str,
            "ai_tracking_db": str | None,
            "conversations": [{"id": str, "name": str, "type": str}]
        }
    """
    workspace_hash = find_workspace_hash(project_path)
    if not workspace_hash:
        return None

    workspace_db = get_workspace_db_path(workspace_hash)
    global_db = get_global_db_path()

    if not workspace_db or not global_db:
        return None

    conversations = get_conversation_ids(workspace_hash)

    return {
        "project_path": normalize_project_path(project_path),
        "workspace_hash": workspace_hash,
        "workspace_db": str(workspace_db),
        "global_db": str(global_db),
        "ai_tracking_db": str(CURSOR_AI_TRACKING) if CURSOR_AI_TRACKING.exists() else None,
        "conversations": conversations,
    }


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 workspace_resolver.py <project_path>", file=sys.stderr)
        sys.exit(1)

    project_path = sys.argv[1]

    if not Path(project_path).exists():
        print(f"Error: Project path does not exist: {project_path}", file=sys.stderr)
        sys.exit(1)

    result = resolve_workspace(project_path)
    if result:
        print(json.dumps(result, indent=2, ensure_ascii=False))
    else:
        print(
            f"Error: Could not resolve workspace for: {project_path}", file=sys.stderr
        )
        sys.exit(1)


if __name__ == "__main__":
    main()
