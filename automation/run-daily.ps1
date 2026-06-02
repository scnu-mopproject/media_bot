# ============================================================
#  每日自动生成文章脚本
#  作用：读取 idea.txt 里今天的灵感，自动生成文章 + 公众号排版
#  使用：由 Windows“任务计划程序”每天定时调用，或手动右键“用 PowerShell 运行”
# ============================================================

# 1) 设置代理（端口改成你自己代理软件里的端口！默认示例是 15236）
$env:HTTPS_PROXY = "http://127.0.0.1:15236"
$env:HTTP_PROXY  = "http://127.0.0.1:15236"

# 2) 进入仓库根目录（本脚本在 automation\ 下，上一级就是根目录）
Set-Location -Path (Join-Path $PSScriptRoot "..")

# 3) 读取今天的灵感
$ideaFile = Join-Path $PSScriptRoot "idea.txt"
if (-not (Test-Path $ideaFile)) {
    Write-Host "找不到 idea.txt，已退出。请先在 automation\idea.txt 里写一句灵感。"
    exit 1
}
$idea = (Get-Content $ideaFile -Raw).Trim()
if ([string]::IsNullOrWhiteSpace($idea)) {
    Write-Host "idea.txt 是空的，今天不生成。"
    exit 0
}

Write-Host "今天的灵感：$idea"
Write-Host "开始生成，请稍候……（首次运行可能需要几分钟）"

# 4) 读取工作流模板，把 $ARGUMENTS 替换成今天的灵感
$template = Get-Content (Join-Path "." ".claude/commands/daily-article.md") -Raw
$prompt   = $template -replace '\$ARGUMENTS', $idea

# 5) 调用 Claude Code 无人值守模式生成内容
#    --dangerously-skip-permissions 让它在本文件夹内自动写文件、不用每次确认
claude -p $prompt --dangerously-skip-permissions

Write-Host "完成！请到 output 文件夹查看今天的文章(.md)和排版(.html)。"
