# hancom-office-restore

사라진 **정품 한컴오피스(한글)** 를 다시 설치해 편집 가능한 상태로 되돌리는 Claude Code 스킬입니다.

노트북에 있던 한글(예: 삼성 노트북 사은품 "한컴오피스 2022 가정 및 학생용")이 어느 날 사라졌고, 대신 받은 **한컴독스**에서는 편집이 안 되는 상황을 실제로 해결한 과정을 정리했습니다.

## 이런 때 씁니다

- "원래 있던 한글이 없어졌어요"
- 한컴독스만 깔려 있고 HWP 편집이 안 돼요
- 예전 설치 파일을 실행하면 `다운로드 받으신지 5일이 경과 되었습니다. 최신 상태를 유지 하기 위해 다시 다운로드 해주세요.` 창이 떠요
- 한컴독스를 지웠더니 `.hwp` 파일이 아무 프로그램으로도 안 열려요

## 해결 과정 요약

| 단계 | 내용 |
| --- | --- |
| 1. 진단 | 설치 목록과 MsiInstaller 이벤트 로그로 무엇이 언제 사라졌는지 확인. 한컴 자동 업데이트 직후 예전 버전이 조용히 제거된 경우가 있음 |
| 2. 설치 파일 받기 | 예전 `HOfficeDN_*.exe`는 받은 지 5일이 지나면 실행되지 않음. **hancom.com 로그인 → 마이페이지 → 제품등록/정품인증 → [설치파일]** 에서 새로 받음. 같은 화면에서 제품번호도 확인 |
| 3. 설치 | 받은 파일의 한컴 디지털 서명(`Valid`)을 확인한 뒤 실행. 사용권 동의와 제품번호 입력은 사용자가 직접 |
| 4. 확인 | `Hwp.exe` 실행, 체험판/읽기 전용 표시가 없는지 확인 |
| 5. 한컴독스 제거 | 새 버전이 잘 되는 걸 확인한 다음 `msiexec /x` 로 제거 |
| 6. 파일 연결 복구 | 한컴독스를 지우면 `.hwp` 연결도 지워짐. `scripts/fix-hwp-association.ps1` 로 `.hwp/.hwpx/.hwt/.hml/.hwtx/.owpml` 다시 연결 |
| 7. 마무리 | 재시작, 남은 설치 파일 정리(휴지통으로). 자동 업데이트는 보안 때문에 켜 두기를 권장 |

자세한 명령과 판단 기준은 [`hancom-office-restore/SKILL.md`](hancom-office-restore/SKILL.md)에 있습니다.

## 설치

프로젝트에서만 쓰기:

```bash
git clone https://github.com/worksenddl2-source/hancom-office-restore-skill
cp -r hancom-office-restore-skill/hancom-office-restore .claude/skills/
```

모든 프로젝트에서 쓰기: `~/.claude/skills/` 아래에 복사합니다.

설치 후 Claude Code에서 "한글이 없어졌어, 원래 쓰던 걸로 돌려줘"처럼 말하거나 `/hancom-office-restore` 로 호출합니다.

## 포함된 파일

```
hancom-office-restore/
├── SKILL.md                         # 스킬 본문 (진단 → 재설치 → 정리)
└── scripts/
    ├── fix-hwp-association.ps1      # .hwp 계열 확장자 연결 복구 (관리자 권한, -Suffix 120 = 2022)
    └── dump-installer-window.ps1    # 설치 창 메시지를 UI Automation으로 읽기
```

## 주의

- **Windows 전용**입니다.
- 한컴 계정 로그인, 사용권 계약 동의, UAC 승인은 스킬이 대신하지 않고 사용자에게 맡깁니다.
- 라이선스가 계정에 등록돼 있어야 합니다. 목록에 제품이 없으면 한컴 고객센터(1566-5192)에 문의하세요.
- 제품번호 같은 개인 정보는 이 저장소에 들어 있지 않습니다.

## License

MIT
