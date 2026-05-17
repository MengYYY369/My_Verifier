# .\sync-repos.ps1
# =========================
# CONFIG
# =========================

$repos = @{
    github  = "https://github.com/MengYYY369/My_Verifier.git"
    gitlab  = "https://gitlab.com/MengYYY369/my_verifier.git"
    gitee   = "https://gitee.com/MengYYY666/My_Verifier.git"
    gitcode = "git@gitcode.com:2301_76858796/My_Verifier.git"  # SSH ONLY
}

# =========================
# CHECK GIT
# =========================

git --version > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Git not installed" -ForegroundColor Red
    exit 1
}

Write-Host "`n===== START SYNC =====" -ForegroundColor Green

# 当前分支
$branch = git rev-parse --abbrev-ref HEAD
Write-Host "Branch: $branch"

# =========================
# STAGE FILES
# =========================

Write-Host "`n===== STAGING FILES =====" -ForegroundColor Yellow
git add -A

# =========================
# COMMIT (AUTO = "同步")
# =========================

$status = git status --porcelain

if ($status) {

    Write-Host "`n===== COMMIT =====" -ForegroundColor Yellow

     $msg = "" # Read-Host "Enter commit message (default: 同步)"

    if (-not $msg) {
        $msg = "同步"
    }

    git commit -m "$msg"

} else {
    Write-Host "No changes to commit." -ForegroundColor Green
}

# =========================
# PUSH FUNCTION
# =========================

function Push-Repo($name, $url, $branch) {

    Write-Host "`n===== PUSH TO $name =====" -ForegroundColor Cyan

    git remote remove $name 2>$null
    git remote add $name $url

    $success = $false

    for ($i = 1; $i -le 3; $i++) {

        Write-Host "Attempt $i..."

        git push $name $branch
        if ($LASTEXITCODE -eq 0) {
            $success = $true
            break
        }

        Write-Host "Retrying in 5s..." -ForegroundColor DarkYellow
        Start-Sleep -Seconds 5
    }

    if (-not $success) {
        Write-Host "$name push failed after retries" -ForegroundColor Red
    }

    git push --tags $name 2>$null
}

# =========================
# EXECUTION
# =========================

Push-Repo "github"  $repos.github  $branch
Push-Repo "gitlab"  $repos.gitlab  $branch
Push-Repo "gitee"   $repos.gitee   $branch
Push-Repo "gitcode" $repos.gitcode $branch

Write-Host "`n===== SYNC DONE =====" -ForegroundColor Green