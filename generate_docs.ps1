# 文字コード設定
$OutputEncoding = [System.Text.Encoding]::UTF8
$outDir = ".\output_notebooklm"

if (Test-Path $outDir) { Remove-Item $outDir -Recurse -Force }
New-Item -ItemType Directory -Path $outDir | Out-Null

# 1. 全体構造図を出力
tree /f /a > "$outDir\00_directory_structure.txt"

# 結合用関数
function Merge-Files ($fileList, $outputFileName) {
    $outputPath = Join-Path $outDir $outputFileName
    $sw = New-Object System.IO.StreamWriter($outputPath, $false, [System.Text.Encoding]::UTF8)
    
    foreach ($file in $fileList) {
        try {
            $relPath = Resolve-Path -Relative $file.FullName
            $sw.WriteLine("`r`n`r`n========================================")
            $sw.WriteLine("[FILE: $relPath]")
            $sw.WriteLine("========================================`r`n")
            
            $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
            $sw.WriteLine($content)
        } catch {
            Write-Warning "Skip: $($file.Name)"
        }
    }
    $sw.Close()
    Write-Host "生成完了: $outputFileName ($($fileList.Count) ファイル)"
}

# --- 分割定義 ---

# A. ユーザーガイド（セットアップ・利用方法）
$userFiles = Get-ChildItem -Recurse -File -Include *.md, *.mdx | Where-Object {
    $_.FullName -match "docs\\(get-started|inference|manage-sandboxes|configure-agents|deployment|monitoring)\\" -or
    $_.Name -match "^(README\.md)$"
}
Merge-Files $userFiles "01_user_guide.txt"

# B. アーキテクチャ & セキュリティ
$archFiles = Get-ChildItem -Recurse -File -Include *.md, *.mdx | Where-Object {
    $_.FullName -match "docs\\(about|reference|security|network-policy)\\" -or
    $_.Name -match "^(SECURITY\.md)$"
}
Merge-Files $archFiles "02_architecture_security.txt"

# C. エージェントスキル定義
$skillFiles = Get-ChildItem -Recurse -File -Include *.md | Where-Object {
    $_.FullName -match "\.agents\\skills\\"
}
Merge-Files $skillFiles "03_agent_skills.txt"

# D. 開発者・コントリビューター向け
$devFiles = Get-ChildItem -Recurse -File -Include *.md, *.mdx | Where-Object {
    $_.Name -match "^(AGENTS|CLAUDE|CONTRIBUTING|CODE_OF_CONDUCT)\.md$"
}
Merge-Files $devFiles "04_contributor_guide.txt"

Write-Host "`r`nすべての抽出と分割処理が正常に完了しました！ (出力先: $outDir)"