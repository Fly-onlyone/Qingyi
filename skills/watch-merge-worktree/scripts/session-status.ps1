<#
.SYNOPSIS
    Prints one snapshot of a repository's worktrees and of the Claude Code sessions working in them.

.DESCRIPTION
    For each worktree: branch, lock, uncommitted file count, and commits ahead of and behind the main
    branch. For each session transcript of the repository written in the last -Hours hours: the
    session name (as ListAgents shows it), whether it is busy, idle or not running, the worktree it
    works in, when it last wrote, and its last assistant message. The main checkout's branch is
    checked against the main branch, and unpushed commits on the main branch are counted.

    A session is listed under the worktree that holds its last working folder. Many sessions keep
    the main checkout as their working folder and reach a worktree by path; for those, the worktrees
    their recent transcript names are listed with counts, as a hint to confirm by reading the last
    message.

    Transcripts are read from <config>/projects/<slug>*, where <config> is $env:CLAUDE_CONFIG_DIR or
    ~/.claude, and <slug> is a worktree's path with every character that is not a letter or a digit
    replaced by '-'. A transcript whose session started outside every worktree is left out: another
    repository can share the slug's prefix (D:\repo-old next to D:\repo).

    Names and live status come from <config>/sessions/*.json, one file per running session. Its name
    is the one ListAgents shows, also when Claude Code made it up (<folder>-<2 hex digits>); such a
    name can change when the session restarts. A session that is not running keeps the name the user
    gave it in its transcript, or shows as '(no name)'. Both formats are internal to Claude Code;
    unknown lines and files are skipped.

.PARAMETER Repo
    Any folder inside the repository. Default: the current folder.

.PARAMETER MainBranch
    Default: the target of origin/HEAD, else main, else master.

.PARAMETER Hours
    Only transcripts written in the last this many hours. Default: 6.

.PARAMETER Exclude
    Session names or session ids to leave out. The running session ($env:CLAUDE_CODE_SESSION_ID) is
    always left out.

.PARAMETER Chars
    Longest last message to print, in characters. Default: 1500.

.EXAMPLE
    pwsh -NoProfile -File session-status.ps1 -Exclude myrepo-3f
#>
param(
    [string]$Repo = (Get-Location).Path,
    [string]$MainBranch,
    [double]$Hours = 6,
    [string[]]$Exclude = @(),
    [int]$Chars = 1500
)

$ErrorActionPreference = 'Stop'

function Get-Norm([string]$Path) {
    ($Path -replace '\\', '/').TrimEnd('/').ToLowerInvariant()
}

function Get-Short([string]$Text, [int]$Max) {
    if (-not $Text) { return '' }
    if ($Text.Length -le $Max) { return $Text }
    $Text.Substring(0, $Max) + ' [...]'
}

# The main checkout is the parent of the shared .git folder, even when -Repo is a worktree.
$common = git -C $Repo rev-parse --path-format=absolute --git-common-dir
if ($LASTEXITCODE -ne 0) { throw "Not a git repository: $Repo" }
$root = (Split-Path $common -Parent) -replace '\\', '/'

if (-not $MainBranch) {
    $originHead = git -C $root symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>$null
    if ($originHead) {
        $MainBranch = $originHead -replace '^origin/', ''
    } else {
        git -C $root show-ref --verify --quiet refs/heads/main
        $MainBranch = if ($LASTEXITCODE -eq 0) { 'main' } else { 'master' }
    }
}

# --- Worktrees ---------------------------------------------------------------
$worktrees = [System.Collections.Generic.List[object]]::new()
$current = $null
foreach ($line in (git -C $root worktree list --porcelain)) {
    if ($line -like 'worktree *') {
        $current = [pscustomobject]@{ Path = $line.Substring(9); Branch = '(detached)'; Locked = $false; Sessions = [System.Collections.Generic.List[object]]::new() }
        $worktrees.Add($current)
    } elseif ($line -like 'branch *') {
        $current.Branch = $line.Substring(7) -replace '^refs/heads/', ''
    } elseif ($line -like 'locked*') {
        $current.Locked = $true
    }
}

# --- Transcripts -------------------------------------------------------------
$config = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $HOME '.claude' }
$projects = Join-Path $config 'projects'
$slugs = @($worktrees | ForEach-Object { $_.Path -replace '[^A-Za-z0-9]', '-' })
$since = (Get-Date).AddHours(-$Hours)
$elsewhere = [System.Collections.Generic.List[object]]::new()
if ($env:CLAUDE_CODE_SESSION_ID) { $Exclude += $env:CLAUDE_CODE_SESSION_ID }
$mainNorm = Get-Norm $root

# The worktree whose path is the longest prefix of a folder, or $null.
function Get-Owner([string]$Folder) {
    if (-not $Folder) { return $null }
    $norm = Get-Norm $Folder
    $worktrees |
        Where-Object { $norm -eq (Get-Norm $_.Path) -or $norm.StartsWith((Get-Norm $_.Path) + '/') } |
        Sort-Object { $_.Path.Length } -Descending |
        Select-Object -First 1
}

# Running sessions, by session id: the name ListAgents shows and busy or idle.
$live = @{}
$sessionsDir = Join-Path $config 'sessions'
if (Test-Path $sessionsDir) {
    foreach ($json in Get-ChildItem $sessionsDir -Filter *.json -File) {
        try { $record = Get-Content $json.FullName -Raw | ConvertFrom-Json } catch { continue }
        if (-not $record.sessionId -or -not $record.pid) { continue }
        # A file left behind by a session that crashed names a process that is gone.
        if (-not (Get-Process -Id $record.pid -ErrorAction SilentlyContinue)) { continue }
        $live[$record.sessionId] = $record
    }
}

# Patterns that name a worktree in a transcript: its folder under .../worktrees/ or its branch.
$mentionPatterns = @{}
foreach ($wt in $worktrees) {
    if ((Get-Norm $wt.Path) -eq $mainNorm) { continue }
    $leaf = [regex]::Escape((Split-Path $wt.Path -Leaf))
    $pattern = "worktrees(?:/|\\\\)+$leaf\b"
    if ($wt.Branch -ne '(detached)') { $pattern += '|' + [regex]::Escape($wt.Branch) + '\b' }
    $mentionPatterns[$wt.Path] = $pattern
}

$files = @()
if (Test-Path $projects) {
    $files = Get-ChildItem $projects -Directory |
        Where-Object { $dir = $_.Name; $slugs | Where-Object { $dir -eq $_ -or $dir -like "$_-*" } } |
        ForEach-Object { Get-ChildItem $_.FullName -Filter *.jsonl -File } |
        Where-Object { $_.LastWriteTime -gt $since } |
        Sort-Object LastWriteTime -Descending
}

foreach ($file in $files) {
    $id = $file.BaseName

    # The folder the session started in. Outside every worktree, it is another repository whose
    # slug shares this one's prefix.
    $start = $null
    foreach ($raw in (Get-Content $file.FullName -TotalCount 50)) {
        try { $entry = $raw | ConvertFrom-Json } catch { continue }
        if ($entry.cwd) { $start = $entry.cwd; break }
    }
    if ($start -and -not (Get-Owner $start)) { continue }

    $record = $live[$id]
    $name = if ($record -and $record.name) { $record.name } else { $null }
    if (-not $name) {
        $nameHit = Select-String -Path $file.FullName -Pattern '"type":"agent-name"' | Select-Object -Last 1
        if ($nameHit) { try { $name = ($nameHit.Line | ConvertFrom-Json).agentName } catch { } }
    }
    if ($Exclude -contains $id -or ($name -and $Exclude -contains $name)) { continue }

    # Read the end of the transcript; go further back when a long run of tool calls holds no text.
    foreach ($count in 400, 4000) {
        $cwd = $null; $branch = $null; $title = $null
        $texts = [System.Collections.Generic.List[string]]::new()
        $tail = @(Get-Content $file.FullName -Tail $count)
        foreach ($raw in $tail) {
            try { $entry = $raw | ConvertFrom-Json } catch { continue }
            if ($entry.cwd) { $cwd = $entry.cwd }
            if ($entry.gitBranch) { $branch = $entry.gitBranch }
            if ($entry.type -eq 'ai-title' -and $entry.aiTitle) { $title = $entry.aiTitle }
            if ($entry.type -eq 'assistant') {
                foreach ($part in $entry.message.content) {
                    if ($part.type -eq 'text' -and $part.text) { $texts.Add($part.text) }
                }
            }
        }
        if ($texts.Count -or $tail.Count -lt $count) { break }
    }

    $last = if ($texts.Count) { $texts[$texts.Count - 1] } else { '' }
    $limit = $last -match "hit your .*limit|usage limit (has been |was )?reached"
    $before = if ($limit -and $texts.Count -gt 1) { $texts[$texts.Count - 2] } else { $null }

    $session = [pscustomobject]@{
        Name = if ($name) { $name } else { '(no name)' }
        Id = $id
        State = if ($record -and $record.status) { $record.status } elseif ($record) { 'running' } else { 'not running' }
        Path = $file.FullName
        Title = $title
        Cwd = $cwd
        Branch = $branch
        Written = $file.LastWriteTime
        Last = $last
        Limit = $limit
        Before = $before
        Hint = $null
    }

    # Assign the session to the worktree whose path is the longest prefix of its last cwd.
    $owner = Get-Owner $cwd

    # Working folder is the main checkout: list the worktrees the transcript names, as a hint only.
    # A count is no proof: sessions also name worktrees they merely listed or looked at.
    if ($owner -and (Get-Norm $owner.Path) -eq $mainNorm -and $mentionPatterns.Count) {
        $joined = $tail -join "`n"
        $hits = foreach ($path in $mentionPatterns.Keys) {
            $count = [regex]::Matches($joined, $mentionPatterns[$path], 'IgnoreCase').Count
            if ($count) { [pscustomobject]@{ Leaf = Split-Path $path -Leaf; Count = $count } }
        }
        if ($hits) {
            $session.Hint = ($hits | Sort-Object Count -Descending | ForEach-Object { "$($_.Leaf) ($($_.Count))" }) -join ', '
        }
    }
    if ($owner) { $owner.Sessions.Add($session) } else { $elsewhere.Add($session) }
}

# --- Output ------------------------------------------------------------------
function Write-Session($s) {
    $ago = [int]((Get-Date) - $s.Written).TotalMinutes
    "  session $($s.Name) [$($s.Id.Substring(0, [Math]::Min(8, $s.Id.Length)))] $($s.State), wrote $($s.Written.ToString('HH:mm')) ($ago min ago), branch $($s.Branch)"
    if ($s.Title) { "    title: $($s.Title)" }
    if ($s.Hint) { "    names worktrees: $($s.Hint)" }
    "    transcript: $($s.Path)"
    if ($s.Limit) {
        "    USAGE LIMIT: $($s.Last)"
        if ($s.Before) { "    message before it: " + (Get-Short $s.Before $Chars) }
    } elseif ($s.Last) {
        "    last message: " + (Get-Short $s.Last $Chars)
    } else {
        "    last message: (none yet)"
    }
}

"repository: $root"
"main branch: $MainBranch"
$unpushed = git -C $root rev-list --count "origin/$MainBranch..$MainBranch" 2>$null
if ($LASTEXITCODE -eq 0) { "unpushed commits on ${MainBranch}: $unpushed" }

foreach ($wt in $worktrees) {
    $isMain = (Get-Norm $wt.Path) -eq (Get-Norm $root)
    $dirty = @(git -C $wt.Path status --porcelain 2>$null).Count
    $ahead = git -C $wt.Path rev-list --count "$MainBranch..HEAD" 2>$null
    $behind = git -C $wt.Path rev-list --count "HEAD..$MainBranch" 2>$null
    ''
    $label = if ($isMain) { 'MAIN CHECKOUT' } else { 'worktree' }
    $lock = if ($wt.Locked) { ' locked' } else { '' }
    "== $label $($wt.Path) [$($wt.Branch)]$lock"
    "  uncommitted files: $dirty, ahead of ${MainBranch}: $ahead, behind: $behind"
    if ($isMain -and $wt.Branch -ne $MainBranch) {
        "  WARNING: the main checkout is on '$($wt.Branch)', not '$MainBranch'. Merges into $MainBranch need it switched back."
    }
    if (-not $isMain) {
        $commits = git -C $wt.Path log --oneline "$MainBranch..HEAD" 2>$null | Select-Object -First 10
        foreach ($c in $commits) { "    $c" }
    }
    if ($wt.Sessions.Count -eq 0 -and -not $isMain) { '  no recent session transcript' }
    foreach ($s in $wt.Sessions) { Write-Session $s }
}

if ($elsewhere.Count) {
    ''
    '== sessions outside every worktree'
    foreach ($s in $elsewhere) { Write-Session $s; "    cwd: $($s.Cwd)" }
}
