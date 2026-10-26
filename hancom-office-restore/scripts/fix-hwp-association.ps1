# 한컴오피스 재설치 후 .hwp 계열 확장자 연결을 다시 등록한다.
# 관리자 권한이 필요하다. 권한이 없으면 UAC로 스스로 다시 실행한다.
param(
  [string]$Suffix = '120'   # 한컴오피스 2022 = 120
)

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
  [Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
  $p = Start-Process powershell.exe -Verb RunAs -PassThru -Wait -ArgumentList @(
    '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"", '-Suffix', $Suffix)
  "exit: $($p.ExitCode)"
  foreach ($ext in '.hwp', '.hwpx') { cmd /c assoc $ext }
  return
}

$map = [ordered]@{
  '.hwp'   = "Hwp.Document.$Suffix"
  '.hwpx'  = "Hwp.Document.hwpx.$Suffix"
  '.hwt'   = "Hwp.Document.hwt.$Suffix"
  '.hml'   = "Hwp.Document.hml.$Suffix"
  '.hwtx'  = "Hwp.Document.hwtx.$Suffix"
  '.owpml' = "Hwp.Document.owpml.$Suffix"
}

foreach ($ext in $map.Keys) {
  $progId = $map[$ext]
  if (-not (Test-Path "Registry::HKEY_CLASSES_ROOT\$progId")) {
    "$ext : $progId 가 없어 건너뜀"
    continue
  }
  $key = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Classes\$ext"
  if (-not (Test-Path $key)) { New-Item $key -Force | Out-Null }
  Set-ItemProperty $key -Name '(default)' -Value $progId
  "$ext -> $progId"
}
