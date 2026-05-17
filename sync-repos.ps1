# powershell -ExecutionPolicy Bypass -File .\sync-repos.ps1
# ===== CONFIG =====
setx GITCODE_TOKEN "szyxgyFEqNZ1CJTY6myfxntA"

$repoPaths = @{
    github  = "https://github.com/MengYYY369/My_Verifier.git"
    gitlab  = "https://gitlab.com/MengYYY369/my_verifier.git"
    gitee   = "https://gitee.com/MengYYY666/My_Verifier.git"
    gitcode = "https://2301_76858796:$env:GITCODE_TOKEN@gitcode.com/2301_76858796/My_Verifier.git"
}

# ===== FUNCTIONS =====
function Run-Git($cmd) {
    Write-Host "`n>> $cmd" -ForegroundColor Cyan
    iex $cmd
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FAILED: $cmd" -ForegroundColor Red
    }
}

function Push-Repo($name, $url, $branch) {
    Write-Host "`n===== PUSH TO $name =====" -ForegroundColor Yellow

    git remote remove $name 2>$null
    git remote add $name $url

    Run-Git "git push $name $branch"
    Run-Git "git push --tags $name"
}

# ===== CHECK GIT =====
git --version | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Git is not installed!" -ForegroundColor Red
    exit 1
}

Write-Host "`n===== START SYNC =====" -ForegroundColor Green

# 当前分支
$branch = git rev-parse --abbrev-ref HEAD
Write-Host "Current branch: $branch"

# ===== 1. ADD ALL CHANGES =====
Write-Host "`n===== STAGING CHANGES =====" -ForegroundColor Yellow
Run-Git "git add -A"

# ===== 2. AUTO COMMIT =====
$status = git status --porcelain

if ($status) {
    $message = Read-Host "Enter commit message"

    if (-not $message) {
        $message = "auto commit $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    }

    Run-Git "git commit -m `"$message`""
} else {
    Write-Host "No changes to commit." -ForegroundColor Green
}

# ===== 3. PUSH TO ALL REMOTES =====
Write-Host "`n===== PUSHING TO REMOTES =====" -ForegroundColor Green

Push-Repo "github"  $repoPaths.github  $branch
Push-Repo "gitlab"  $repoPaths.gitlab  $branch
Push-Repo "gitee"   $repoPaths.gitee   $branch
Push-Repo "gitcode" $repoPaths.gitcode $branch

Write-Host "`n===== ALL DONE =====" -ForegroundColor Green