# 한컴 설치 프로그램 창에 뜬 텍스트를 UI Automation으로 읽는다.
# 사용자가 메시지를 놓쳤을 때(예: "다운로드 받으신지 5일이 경과 되었습니다") 내용을 확인하는 용도.
param(
  [int]$TimeoutSeconds = 120,
  [string]$ProcessPattern = 'HOffice|Hnc|setup|Install'
)

Add-Type -AssemblyName UIAutomationClient, UIAutomationTypes
$root = [Windows.Automation.AutomationElement]::RootElement
$all = [Windows.Automation.Condition]::TrueCondition

for ($i = 0; $i -lt $TimeoutSeconds / 2; $i++) {
  $found = $false
  foreach ($w in $root.FindAll([Windows.Automation.TreeScope]::Children, $all)) {
    try { $proc = Get-Process -Id $w.Current.ProcessId -ErrorAction Stop } catch { continue }
    if ($proc.ProcessName -notmatch $ProcessPattern -or $proc.ProcessName -match 'HncUpdate') { continue }
    "WINDOW: [$($proc.ProcessName)] $($w.Current.Name)"
    $w.FindAll([Windows.Automation.TreeScope]::Descendants, $all) |
      ForEach-Object { if ($_.Current.Name) { "  - " + $_.Current.Name } }
    $found = $true
  }
  if ($found) { return }
  Start-Sleep 2
}
"no installer window found"
