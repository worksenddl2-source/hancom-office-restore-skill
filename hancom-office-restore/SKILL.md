---
name: hancom-office-restore
description: 사라진 한컴오피스(한글) 정품을 다시 설치해 편집 가능한 상태로 되돌린다. "한글이 없어졌어", "HWP 편집이 안 돼", "한컴독스만 깔려 있어", "다운로드 받으신지 5일이 경과 되었습니다" 오류, 삼성 노트북 번들 한컴오피스 재설치, .hwp 파일 연결 복구에 사용한다. Windows 전용.
license: MIT
---

# hancom-office-restore

예전에 쓰던 정품 한컴오피스(예: 삼성 노트북 사은품 "한컴오피스 2022 가정 및 학생용")가 사라졌고, 대신 편집이 제한된 **한컴독스**가 설치된 상황을 복구한다.
진단 → 한컴 계정에서 설치 파일 다시 받기 → 재설치 → 한컴독스 제거 → `.hwp` 파일 연결 복구 순서로 진행한다.

## 핵심 사실

- **예전 설치 파일은 다시 쓸 수 없다.** 한컴 웹 설치 파일(`HOfficeDN_*.exe`)은 받은 지 5일이 지나면 `다운로드 받으신지 5일이 경과 되었습니다. 최신 상태를 유지 하기 위해 다시 다운로드 해주세요.` 창을 띄우고 멈춘다. 새로 받아야 한다.
- **번들/사은품 라이선스는 한컴 계정에 남아 있다.** 쿠폰을 등록한 제품은 영구 소장형으로 계정에 연결돼 있어, 설치 파일과 제품번호를 다시 받을 수 있다.
- **한컴독스를 지우면 `.hwp` 파일 연결도 같이 지워진다.** 제거한 뒤에 연결을 다시 등록해야 한다.
- **원인은 대개 한컴 자동 업데이트 서비스다.** `HncUpdateService`가 무언가를 내려받은 직후 창 없이 기존 버전이 제거된 사례가 있다. 그래도 hwp 파일은 악성코드 유포에 자주 쓰이므로 자동 업데이트는 끄지 않기를 권한다.

## 사용자만 할 수 있는 일 (대신하지 않는다)

- 한컴 계정 **로그인**: 비밀번호를 묻거나 입력하지 않는다. 로그인 화면만 열어 주고 "로그인했어"를 기다린다.
- 설치 프로그램의 **사용권 계약 동의**와 **UAC [예]** 클릭.
- 파일 삭제, 프로그램 제거 같은 되돌리기 어려운 작업은 실행 직전에 확인을 받는다.
- 제품번호는 사용자에게만 보여 주고, 파일·로그·커밋에 남기지 않는다.

## Workflow

### 1. 진단

```powershell
$paths = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
         'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
         'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
Get-ItemProperty $paths -ErrorAction SilentlyContinue |
  Where-Object { $_.Publisher -match 'Hancom|한글과컴퓨터' } |
  Select-Object PSChildName, DisplayName, DisplayVersion, InstallLocation, InstallDate | Format-List

# 언제 무엇이 제거됐는지 (MsiInstaller 이벤트)
Get-WinEvent -FilterHashtable @{LogName='Application'; ProviderName='MsiInstaller'} -MaxEvents 3000 -ErrorAction SilentlyContinue |
  Where-Object { $_.Message -match 'Hancom|한컴|Hnc' } |
  Select-Object TimeCreated, Id, @{n='Msg';e={$_.Message.Substring(0,[Math]::Min(200,$_.Message.Length))}} | Format-Table -Wrap

# 노트북 제조사 (삼성이면 번들 가능성이 높다)
Get-CimInstance Win32_ComputerSystem | Select-Object Manufacturer, Model
```

확인할 것:
- 지금 깔려 있는 것이 `한컴오피스 2024 한컴독스` 같은 편집 제한판인지.
- 예전 버전(예: `한컴오피스 2022`, 12.x)이 제거된 날짜와 직전의 `HncUpdate` 활동. `%APPDATA%\HNC\HOffice*Install.log`에도 기록이 남는다.
- 남아 있는 예전 설치 파일(`HOfficeDN_*.exe`)이 있으면 서명만 확인한다. 5일이 지났다면 실행해도 위 경과 창이 뜬다.

### 2. 한컴 계정에서 설치 파일 받기

브라우저 자동화를 쓸 수 있으면 대신 진행하고, 없으면 같은 경로를 안내한다.

1. `https://www.hancom.com/login` 을 열고 사용자가 직접 로그인하게 한다. 예전에 쓰던 아이디인지 확인한다(카카오·네이버 간편 로그인일 수 있다).
2. 우측 상단 **마이페이지 메뉴 → 마이페이지**를 연다. 모바일 화면이 열리면 하단의 **PC버전 보기**를 누른다.
   - 직접 주소: `https://store.hancom.com/mypage/myIndivPrdtList.do?showSubMain=P` (제품등록/정품인증)
3. 등록 제품 목록에서 해당 제품(예: 한컴오피스 2022 가정 및 학생용)의 **제품번호**를 확인해 사용자에게 알려 준다.
4. 같은 행의 **[설치파일]** 을 눌러 내려받는다. `Downloads`에 `HOfficeDN_<버전>_<번들>.exe`가 생긴다.
5. 목록에 없으면 다른 아이디로 등록했을 수 있다. 그래도 없으면 한컴 고객센터(1566-5192)에 "노트북 번들 한컴오피스 재설치"로 문의하도록 안내한다.

### 3. 서명 확인 후 설치

```powershell
$f = Get-ChildItem "$env:USERPROFILE\Downloads\HOfficeDN_*.exe" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
$s = Get-AuthenticodeSignature $f.FullName
"$($s.Status) / $($s.SignerCertificate.Subject.Split(',')[0])"   # Valid / CN="HANCOM. INC," 이어야 한다
if ($s.Status -eq 'Valid') { Start-Process $f.FullName }
```

- 서명이 `Valid`가 아니거나 서명자가 한컴이 아니면 실행하지 않는다.
- 설치 창 내용을 읽어야 하면 UI Automation으로 창 텍스트를 덤프한다(`scripts/dump-installer-window.ps1`).
- 사용자에게: UAC **[예]**, 사용권 계약 동의, 제품번호 입력, 설치 완료 후 재시작은 **나중에**.

### 4. 설치 확인

```powershell
Get-ChildItem 'C:\Program Files (x86)\HNC' -Recurse -Filter Hwp.exe -ErrorAction SilentlyContinue |
  ForEach-Object { "$($_.FullName)  $($_.VersionInfo.FileVersion)" }
```

`Hwp.exe`를 실행해 `빈 문서 1 - 한글` 창이 뜨는지, 체험판/읽기 전용 표시가 없는지 확인한다.

### 5. 한컴독스 제거 (사용자 확인 후)

새 버전이 정상 동작하는 것을 확인한 다음에만 제거한다. 그래야 중간에 한글이 아예 없는 상태가 되지 않는다.

```powershell
# 1단계 진단 결과의 한컴독스 PSChildName(ProductCode)을 넣는다
$p = Start-Process msiexec.exe -ArgumentList '/x {PRODUCT-CODE} /qb /norestart' -Verb RunAs -PassThru -Wait
"exit code: $($p.ExitCode)"   # 0 이면 성공
```

제거 후에도 한컴독스의 업데이트 서비스(예: `HncUpdateService_2024`)가 남아 있으면 관리자 권한으로 `sc.exe delete <서비스명>` 해 정리한다. 재설치한 버전의 업데이트 서비스는 건드리지 않는다.

### 6. `.hwp` 파일 연결 복구

`scripts/fix-hwp-association.ps1` 을 관리자 권한으로 실행한다. 한컴오피스 2022(버전 접미사 `120`)이면 다음과 같이 연결된다.

| 확장자 | ProgID |
| --- | --- |
| `.hwp` | `Hwp.Document.120` |
| `.hwpx` | `Hwp.Document.hwpx.120` |
| `.hwt` | `Hwp.Document.hwt.120` |
| `.hml` | `Hwp.Document.hml.120` |
| `.hwtx` | `Hwp.Document.hwtx.120` |
| `.owpml` | `Hwp.Document.owpml.120` |

다른 버전이면 `HKEY_CLASSES_ROOT\Hwp.Document.*` 목록에서 접미사를 확인해 `-Suffix`로 넘긴다. 확인:

```powershell
cmd /c assoc .hwp     # .hwp=Hwp.Document.120
cmd /c assoc .hwpx
```

그다음 실제 `.hwp` 파일을 더블클릭(`Start-Process <file>`)해 새로 설치한 `Hwp.exe`로 열리는지 확인한다.

### 7. 마무리

- 재시작을 안내한다(설치 마무리, 남은 업데이트 서비스 정리).
- 더는 필요 없는 설치 파일(한컴독스 설치 파일, 기간이 지난 `HOfficeDN_*.exe`)은 사용자 동의를 받아 **휴지통으로** 옮긴다.
- 자동 업데이트는 보안 때문에 켜 두기를 권한다. 다시 사라지면 이 스킬로 언제든 재설치할 수 있다는 점을 알려 준다.

## Done when

- 예전 정품 한컴오피스가 설치돼 있고 `Hwp.exe`가 실행된다.
- 한컴독스(편집 제한판)가 제거됐다(사용자가 원한 경우).
- `assoc .hwp`가 새 버전 ProgID를 가리키고, `.hwp` 더블클릭 시 그 버전으로 열린다.
