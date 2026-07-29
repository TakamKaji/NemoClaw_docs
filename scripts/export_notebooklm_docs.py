import os
import glob

# 出力先ディレクトリ
OUT_DIR = "output_notebooklm"
os.makedirs(OUT_DIR, exist_ok=True)

# A. ユーザーガイド
user_patterns = [
    "docs/get-started/**/*",
    "docs/inference/**/*",
    "docs/manage-sandboxes/**/*",
    "docs/configure-agents/**/*",
    "docs/deployment/**/*",
    "docs/monitoring/**/*",
    "README.md"
]

# B. アーキテクチャ & セキュリティ
arch_patterns = [
    "docs/about/**/*",
    "docs/reference/**/*",
    "docs/security/**/*",
    "docs/network-policy/**/*",
    "SECURITY.md"
]

# C. エージェントスキル
skill_patterns = [
    ".agents/skills/**/SKILL.md"
]

# D. 開発者ガイド
dev_patterns = [
    "AGENTS.md",
    "CLAUDE.md",
    "CONTRIBUTING.md",
    "CODE_OF_CONDUCT.md"
]

def merge_files(patterns, output_filename):
    out_path = os.path.join(OUT_DIR, output_filename)
    matched_files = []
    
    for pattern in patterns:
        # 再帰的にファイルを検索
        for filepath in glob.glob(pattern, recursive=True):
            if os.path.isfile(filepath) and (filepath.endswith('.md') or filepath.endswith('.mdx')):
                matched_files.append(filepath)
                
    # 重複排除とソート
    matched_files = sorted(list(set(matched_files)))
    
    with open(out_path, "w", encoding="utf-8") as outfile:
        for filepath in matched_files:
            try:
                outfile.write(f"\n\n========================================\n")
                outfile.write(f"[FILE: {filepath}]\n")
                outfile.write(f"========================================\n\n")
                with open(filepath, "r", encoding="utf-8", errors="ignore") as infile:
                    outfile.write(infile.read())
            except Exception as e:
                print(f"Skip {filepath}: {e}")
                
    print(f"Generated: {out_path} ({len(matched_files)} files)")

if __name__ == "__main__":
    # 構造図の作成（Linuxコマンド）
    os.system(f"tree -a -I 'node_modules|.git|dist|test|ci' > {OUT_DIR}/00_directory_structure.txt")
    
    # 用途別結合
    merge_files(user_patterns, "01_user_guide.txt")
    merge_files(arch_patterns, "02_architecture_security.txt")
    merge_files(skill_patterns, "03_agent_skills.txt")
    merge_files(dev_patterns, "04_contributor_guide.txt")
    
    print("\nAll docs successfully exported to:", OUT_DIR)