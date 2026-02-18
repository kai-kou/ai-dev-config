#!/usr/bin/env python3
"""
Cursor Chat History Extractor & Analyzer

CursorのSQLiteデータベースからチャット履歴を抽出し、
LLMが分析可能な構造化JSONサマリーを出力する。

使用方法:
    python3 extract_chat_history.py <project_path> [--output <output_path>] [--max-conversations <N>] [--max-messages <N>]

データソース:
    - Global State DB: ~/Library/Application Support/Cursor/User/globalStorage/state.vscdb
    - AI Code Tracking: ~/.cursor/ai-tracking/ai-code-tracking.db
"""

import argparse
import json
import sqlite3
import sys
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List, Optional

# workspace_resolver を同一ディレクトリからインポート
sys.path.insert(0, str(Path(__file__).parent))
from workspace_resolver import resolve_workspace


def extract_conversation_messages(
    global_db_path: str,
    composer_id: str,
    max_messages: int = 500,
) -> dict:
    """
    グローバルDBから1会話のメッセージを抽出する。

    Args:
        global_db_path: グローバルstate.vscdbのパス
        composer_id: 会話ID
        max_messages: 最大取得メッセージ数

    Returns:
        会話データの辞書
    """
    conn = sqlite3.connect(global_db_path)
    cursor = conn.cursor()

    # composerData からメッセージヘッダーを取得
    cursor.execute(
        "SELECT value FROM cursorDiskKV WHERE key = ?",
        (f"composerData:{composer_id}",),
    )
    row = cursor.fetchone()
    if not row:
        conn.close()
        return {"id": composer_id, "messages": [], "error": "composerData not found"}

    val = row[0]
    composer_data = json.loads(val) if isinstance(val, str) else json.loads(val.decode("utf-8"))

    headers = composer_data.get("fullConversationHeadersOnly", [])

    # メッセージを抽出
    messages = []
    user_messages = []
    ai_messages_with_text = []

    for i, h in enumerate(headers[:max_messages]):
        bubble_id = h.get("bubbleId", "")
        msg_type = h.get("type")

        key = f"bubbleId:{composer_id}:{bubble_id}"
        cursor.execute("SELECT value FROM cursorDiskKV WHERE key = ?", (key,))
        r = cursor.fetchone()
        if not r:
            continue

        bubble_data = json.loads(r[0]) if isinstance(r[0], str) else json.loads(r[0].decode("utf-8"))
        text = bubble_data.get("text", "")
        created_at = bubble_data.get("createdAt", "")
        capability_type = bubble_data.get("capabilityType")
        model_info = bubble_data.get("modelInfo", {})
        is_agentic = bubble_data.get("isAgentic", False)

        if msg_type == 1:  # User message
            msg = {
                "role": "user",
                "text": text,
                "created_at": created_at,
                "is_agentic": is_agentic,
            }
            messages.append(msg)
            if text.strip():
                user_messages.append(text)
        elif msg_type == 2:  # AI response
            if text.strip():
                msg = {
                    "role": "assistant",
                    "text": text,
                    "created_at": created_at,
                    "capability_type": capability_type,
                    "model": model_info.get("modelName", ""),
                }
                messages.append(msg)
                ai_messages_with_text.append(text)

    conn.close()

    return {
        "id": composer_id,
        "total_headers": len(headers),
        "extracted_messages": len(messages),
        "user_message_count": len(user_messages),
        "ai_message_count": len(ai_messages_with_text),
        "messages": messages,
    }


def extract_file_changes(ai_tracking_db_path: str, project_path: str) -> List[Dict]:
    """
    AI Code Tracking DBからプロジェクト関連のファイル変更を抽出する。

    Args:
        ai_tracking_db_path: ai-code-tracking.dbのパス
        project_path: プロジェクトの絶対パス

    Returns:
        ファイル変更情報のリスト
    """
    if not ai_tracking_db_path or not Path(ai_tracking_db_path).exists():
        return []

    conn = sqlite3.connect(ai_tracking_db_path)
    cursor = conn.cursor()

    # プロジェクトパスに関連するファイル変更を取得
    cursor.execute(
        """
        SELECT fileName, fileExtension, source, model, timestamp, conversationId
        FROM ai_code_hashes
        WHERE fileName LIKE ?
        ORDER BY timestamp DESC
        """,
        (f"%{project_path}%",),
    )
    rows = cursor.fetchall()
    conn.close()

    changes = []
    for r in rows:
        changes.append(
            {
                "file": r[0],
                "extension": r[1],
                "source": r[2],
                "model": r[3],
                "timestamp": r[4],
                "conversation_id": r[5],
            }
        )

    return changes


def analyze_patterns(conversations_data: List[Dict], file_changes: List[Dict]) -> Dict:
    """
    抽出データからパターンを分析する。

    LLMが分析しやすい前処理済みの統計情報を生成する。

    Args:
        conversations_data: 会話データのリスト
        file_changes: ファイル変更のリスト

    Returns:
        分析結果の辞書
    """
    all_user_messages = []
    all_ai_messages = []
    timestamps = []

    for conv in conversations_data:
        for msg in conv.get("messages", []):
            if msg["role"] == "user" and msg["text"].strip():
                all_user_messages.append(msg["text"])
                if msg.get("created_at"):
                    timestamps.append(msg["created_at"])
            elif msg["role"] == "assistant" and msg["text"].strip():
                all_ai_messages.append(msg["text"])

    # ファイル変更パターン
    file_counter = Counter()
    extension_counter = Counter()
    model_counter = Counter()

    for change in file_changes:
        file_name = change.get("file", "")
        if file_name:
            # プロジェクトルート相対パスに変換
            rel_path = file_name.split("/")[-1] if "/" in file_name else file_name
            file_counter[rel_path] += 1
        ext = change.get("extension", "")
        if ext:
            extension_counter[ext] += 1
        model = change.get("model", "")
        if model:
            model_counter[model] += 1

    # 日付範囲
    date_range = {}
    if timestamps:
        sorted_ts = sorted(timestamps)
        date_range = {"first": sorted_ts[0], "last": sorted_ts[-1]}

    return {
        "total_user_messages": len(all_user_messages),
        "total_ai_responses": len(all_ai_messages),
        "date_range": date_range,
        "file_change_count": len(file_changes),
        "most_changed_files": dict(file_counter.most_common(20)),
        "extension_distribution": dict(extension_counter.most_common(10)),
        "models_used": dict(model_counter.most_common(5)),
        "avg_user_message_length": (
            sum(len(m) for m in all_user_messages) // max(len(all_user_messages), 1)
        ),
        "user_messages_for_analysis": all_user_messages,
    }


def create_analysis_summary(
    workspace_info: dict,
    conversations_data: list[dict],
    file_changes: list[dict],
    patterns: dict,
) -> dict:
    """
    LLM分析用のコンパクトなサマリーを生成する。

    Args:
        workspace_info: ワークスペース情報
        conversations_data: 会話データリスト
        file_changes: ファイル変更リスト
        patterns: パターン分析結果

    Returns:
        LLM分析用サマリー辞書
    """
    # 会話ごとのサマリー（ユーザーメッセージのみ抽出）
    conversation_summaries = []
    for conv_info, conv_data in zip(workspace_info["conversations"], conversations_data):
        user_msgs = [
            m["text"]
            for m in conv_data.get("messages", [])
            if m["role"] == "user" and m["text"].strip()
        ]
        if user_msgs:
            conversation_summaries.append(
                {
                    "name": conv_info["name"],
                    "user_message_count": len(user_msgs),
                    "total_messages": conv_data.get("extracted_messages", 0),
                    "user_messages": user_msgs,
                }
            )

    return {
        "metadata": {
            "project_path": workspace_info["project_path"],
            "workspace_hash": workspace_info["workspace_hash"],
            "extraction_date": datetime.now(timezone.utc).isoformat(),
            "extractor_version": "1.0.0",
        },
        "summary": {
            "total_conversations": len(workspace_info["conversations"]),
            "conversations_with_messages": len(conversation_summaries),
            "total_user_messages": patterns["total_user_messages"],
            "total_ai_responses": patterns["total_ai_responses"],
            "date_range": patterns["date_range"],
            "models_used": patterns["models_used"],
            "avg_user_message_length": patterns["avg_user_message_length"],
        },
        "conversations": conversation_summaries,
        "file_changes": {
            "total": patterns["file_change_count"],
            "most_changed_files": patterns["most_changed_files"],
            "extension_distribution": patterns["extension_distribution"],
        },
        "all_user_messages": patterns["user_messages_for_analysis"],
    }


def main():
    parser = argparse.ArgumentParser(
        description="Cursor Chat History Extractor & Analyzer"
    )
    parser.add_argument("project_path", help="プロジェクトの絶対パス")
    parser.add_argument(
        "--output", "-o", help="出力ファイルパス（デフォルト: stdout）"
    )
    parser.add_argument(
        "--max-conversations",
        type=int,
        default=50,
        help="最大会話数（デフォルト: 50）",
    )
    parser.add_argument(
        "--max-messages",
        type=int,
        default=500,
        help="会話あたりの最大メッセージ数（デフォルト: 500）",
    )
    parser.add_argument(
        "--verbose", "-v", action="store_true", help="詳細ログ出力"
    )
    args = parser.parse_args()

    # 1. ワークスペース解決
    if args.verbose:
        print(f"Resolving workspace for: {args.project_path}", file=sys.stderr)

    workspace_info = resolve_workspace(args.project_path)
    if not workspace_info:
        print(
            f"Error: Could not resolve workspace for: {args.project_path}",
            file=sys.stderr,
        )
        sys.exit(1)

    if args.verbose:
        print(
            f"Found workspace: {workspace_info['workspace_hash']}",
            file=sys.stderr,
        )
        print(
            f"Conversations: {len(workspace_info['conversations'])}",
            file=sys.stderr,
        )

    # 2. 会話メッセージ抽出
    conversations_data = []
    conv_limit = min(len(workspace_info["conversations"]), args.max_conversations)

    for i, conv in enumerate(workspace_info["conversations"][:conv_limit]):
        if args.verbose:
            print(
                f"Extracting [{i+1}/{conv_limit}]: {conv['name'][:50]}",
                file=sys.stderr,
            )

        conv_data = extract_conversation_messages(
            workspace_info["global_db"],
            conv["id"],
            max_messages=args.max_messages,
        )
        conversations_data.append(conv_data)

    # 3. ファイル変更抽出
    if args.verbose:
        print("Extracting file changes...", file=sys.stderr)

    file_changes = extract_file_changes(
        workspace_info.get("ai_tracking_db"),
        workspace_info["project_path"],
    )

    # 4. パターン分析
    if args.verbose:
        print("Analyzing patterns...", file=sys.stderr)

    patterns = analyze_patterns(conversations_data, file_changes)

    # 5. サマリー生成
    summary = create_analysis_summary(
        workspace_info, conversations_data, file_changes, patterns
    )

    # 6. 出力
    output_json = json.dumps(summary, indent=2, ensure_ascii=False)

    if args.output:
        output_path = Path(args.output)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, "w") as f:
            f.write(output_json)
        if args.verbose:
            print(f"Output written to: {args.output}", file=sys.stderr)
    else:
        print(output_json)

    # 完了サマリー
    print(
        f"\n--- Extraction Complete ---\n"
        f"Conversations: {summary['summary']['total_conversations']}\n"
        f"User messages: {summary['summary']['total_user_messages']}\n"
        f"AI responses: {summary['summary']['total_ai_responses']}\n"
        f"File changes: {summary['file_changes']['total']}\n",
        file=sys.stderr,
    )


if __name__ == "__main__":
    main()
