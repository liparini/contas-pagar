# Deploy - Contas a Pagar - GitHub Pages (liparini)

$REPO   = "contas-pagar"
$OWNER  = "liparini"
$BRANCH = "main"

Write-Host "Iniciando deploy de '$REPO' no GitHub Pages..." -ForegroundColor Cyan

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git nao encontrado. Instale em https://git-scm.com/" -ForegroundColor Red
    exit 1
}

$ghAvailable = $null -ne (Get-Command gh -ErrorAction SilentlyContinue)

if ($ghAvailable) {
    Write-Host "Criando repositorio '$REPO' no GitHub..." -ForegroundColor Yellow
    gh repo create "$OWNER/$REPO" --public --description "Sistema de controle de contas a pagar" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Repositorio criado!" -ForegroundColor Green
    } else {
        Write-Host "Repositorio ja existe, continuando..." -ForegroundColor Gray
    }
} else {
    Write-Host "gh CLI nao encontrado." -ForegroundColor Yellow
    Write-Host "Crie o repositorio em: https://github.com/new" -ForegroundColor Gray
    Write-Host "Nome: $REPO (publico)" -ForegroundColor Gray
    Read-Host "Pressione Enter apos criar o repositorio"
}

Write-Host "Configurando repositorio local..." -ForegroundColor Yellow
git init
git checkout -b $BRANCH 2>$null

$remoteUrl = "https://github.com/$OWNER/$REPO.git"
git remote remove origin 2>$null
git remote add origin $remoteUrl
Write-Host "Remote: $remoteUrl" -ForegroundColor Green

Write-Host "Enviando arquivos..." -ForegroundColor Yellow
git add .
git commit -m "feat: sistema de contas a pagar v1.0"
git push -u origin $BRANCH --force

if ($LASTEXITCODE -ne 0) {
    Write-Host "Push falhou. Verifique sua autenticacao com: gh auth status" -ForegroundColor Red
    exit 1
}
Write-Host "Push concluido!" -ForegroundColor Green

if ($ghAvailable) {
    Write-Host "Ativando GitHub Pages..." -ForegroundColor Yellow
    gh api "repos/$OWNER/$REPO/pages" --method POST -f "source[branch]=$BRANCH" -f "source[path]=/" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "GitHub Pages ativado!" -ForegroundColor Green
    } else {
        Write-Host "Pages ja ativo ou ative manualmente." -ForegroundColor Gray
    }
} else {
    Write-Host "Ative o GitHub Pages manualmente:" -ForegroundColor Yellow
    Write-Host "1. Acesse https://github.com/$OWNER/$REPO/settings/pages" -ForegroundColor Gray
    Write-Host "2. Em Source selecione: Branch main / pasta raiz /" -ForegroundColor Gray
    Write-Host "3. Clique em Save" -ForegroundColor Gray
}

$siteUrl = "https://$OWNER.github.io/$REPO"
Write-Host ""
Write-Host "Deploy concluido!" -ForegroundColor Green
Write-Host "Seu site estara disponivel em alguns minutos em:" -ForegroundColor Cyan
Write-Host $siteUrl -ForegroundColor White
Write-Host "GitHub Pages pode levar 1 a 3 minutos para publicar." -ForegroundColor Gray
Write-Host ""
