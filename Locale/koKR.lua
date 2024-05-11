local addonName, _ = ...
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "koKR")

if not L then return end

L["CHANNELS_SAY"]     = "S,말,ㄴ,SAY"
L["CHANNELS_YELL"]    = "Y,외침,외치기,SHOUT,ㅛ,YELL,SH,SHOUT"
L["CHANNELS_PARTY"]   = "P,PARTY,ㅔ,파티,ㅍ"
L["CHANNELS_RAID"]    = "공,RAID,RA,공격대,공대,RSAY"
L["CHANNELS_INSTANCE"] = "I,인스턴스"
L["CHANNELS_RAID_WARNING"] = "RW,경보"

L["SAY"]     = "일반"
L["YELL"]    = "외침"
L["PARTY"]   = "파티"
L["RAID"]    = "공대"
L["INSTANCE"] = "인스턴스"
L["RAID_WARNING"] = "경보"

L["Inspect Target"] = "대상 살펴보기 "
L["Inspect Mouseover"] = "마우스오버 살펴보기"

L["SLASH_CMD_UPNE2"] = "/ㅇㅇ"
L["SLASH_CMD_UPNE3"] = "/dd"
L["SLASH_CMD_CALC2"] = "/계산"
L["SLASH_CMD_CALC_SILENT2"] = "/계산2"

L["SLASH_OPT_INTERRUPT"] = {
    ["차단"] = true,
    ["INT"]  = true, ["INTERRUPT"] = true
}

L["Calculator"] = "계산기"
L["Calculation Error"] = "계산 오류"

L["Turn On"] = "(|cffffffff켜기|r) "
L["Turn Off"] = "(|cff999999끄기|r) "

L["Announce Interruption"] = "차단 알림"
L["Announce Interruption: Channel"] = "차단 알림 채널"
L["Interrupt"] = "차단"
L["No Target"] = "대상 없음"
L["'s "] = "의 "
L["Item Level"] = "아이템 레벨"
L["Show [Item Lv/ID] on Tooltip"] = "툴팁에 [아이템 레벨/ID] 표시"
L["Show GS/ILvl on Target Tooltip"] = "대상 툴팁에 [기어스코어/평균템레벨] 표시(살펴보기 후 적용)"
L["Show [Spell ID] on Aura Tooltip"] = "버프/디버프 툴팁에 [주문 ID] 표시"
L["Show [Caster Name] on Aura Tooltip"] = "버프/디버프 툴팁에 [시전자] 표시"
L["Show Target Class Color on Trade Window"] = "거래창에서 상대방 직업색상 보이기"
L["Automatically Input DELETE CONFIRM String"] = "아이템 파괴 확인 문자 자동 입력"
L["Show Raid Icon on ToT/ToF"] = "[대상의 대상]/[주시대상의 대상] 공격대 아이콘 표시"
L["Show GearScore on Inspection"] = "살펴보기 기어스코어 표시"
L["Fix Combat Message ON"] = "전투 메시지 표시하기 고정"
L["Combat Message Enabled"] = "전투 메시지가 꺼져 있어서 켰습니다."
L["Description_FixCombatMessage"] = "로그인 시 전투 메시지를 켜 줍니다."
L["Alarm when Someone calls My Name"] = "내 이름 불렸을 때 알람(콜미)"
L["Alarm Sound"] = "콜미 소리"
L["Play"] = "듣기"
L["Zoom Vehicle UI Size"] = "탈것 UI 크기 조정"
L["Hide Vehicle UI Background"] = "탈것 UI 배경 제거"
L["Enhance Druid ManaBar"] = "드루이드 마나바 향상"
L["Description_DruidManaBar"] = "숫자 항상 표시, 폰트 크기 조정, 플레이어 프레임과 크기 맞춤, 테두리 제거. 되돌리려면 리로드가 필요합니다."
L["FPS: Show FPS"] = "FPS 표시"
L["FPS: Move Frame"] = "FPS 표시 위치조절"
L["FPS: Anchor Point"] = "기준점"
L["FPS: Anchor Frame"] = "기준 프레임"
L["FPS: Anchor Frame's Anchor Point"] = "기준 프레임의 기준점"
L["X Offset"] = "좌우 이동"
L["Y Offset"] = "상하 이동"

L["TOPLEFT"]    = "좌상"
L["TOP"]        = "상"
L["TOPRIGHT"]   = "우상"
L["LEFT"]       = "좌"
L["CENTER"]     = "중간"
L["RIGHT"]      = "우"
L["BOTTOMLEFT"] = "좌하"
L["BOTTOM"]     = "하"
L["BOTTOMRIGHT"] = "우하"
