import 'package:flutter/material.dart';

/// 군사용 HUD 디자인 토큰 시스템
/// 팔란티어/DJI 스타일의 절제된 디자인
class DesignTokens {
  // ===== 색상 시스템 =====
  static const Color primary = Color(0xFF1A1A1A);        // 메인 배경
  static const Color secondary = Color(0xFF2A2A2A);      // 카드 배경
  static const Color surface = Color(0xFF333333);        // 표면
  static const Color accent = Color(0xFF4A9EFF);         // 포인트 (파란색)
  static const Color warning = Color(0xFFFFB800);        // 경고
  static const Color error = Color(0xFFFF4757);          // 오류
  static const Color success = Color(0xFF2ED573);        // 성공
  
  // 프로젝트 상태 색상
  static const Color statusRunning = Color(0xFF4A9EFF);   // 실행 중 (파란색)
  static const Color statusStandby = Color(0xFF00FF41);   // 대기 중 (초록색)
  static const Color statusOffline = Color(0xFFEAB308);   // 오프라인 (노랑색)
  static const Color statusError = Color(0xFFFF0040);     // 오류 (빨간색)
  
  // 텍스트 색상
  static const Color textPrimary = Color(0xFFFFFFFF);    // 주요 텍스트
  static const Color textSecondary = Color(0xFFB0B0B0);  // 보조 텍스트
  static const Color textMuted = Color(0xFF808080);      // 흐린 텍스트
  
  // 테두리
  static const Color border = Color(0xFF404040);         // 기본 테두리
  static const Color borderAccent = Color(0xFF4A9EFF);   // 강조 테두리
  
  // ===== 타이포그래피 =====
  static const String fontFamily = 'Pretendard';
  static const String fontFamilyMono = 'monospace';
  
  // 폰트 크기
  static const double fontSizeXS = 10.0;     // 초소형
  static const double fontSizeSM = 12.0;     // 소형
  static const double fontSizeMD = 14.0;     // 중형
  static const double fontSizeLG = 16.0;     // 대형
  static const double fontSizeXL = 18.0;     // 초대형
  static const double fontSizeXXL = 24.0;    // 2XL
  
  // 폰트 두께
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightNormal = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  
  // ===== 간격 시스템 =====
  static const double spacingXS = 4.0;       // 초소형 간격
  static const double spacingSM = 8.0;       // 소형 간격
  static const double spacingMD = 12.0;      // 중형 간격
  static const double spacingLG = 16.0;      // 대형 간격
  static const double spacingXL = 24.0;      // 초대형 간격
  static const double spacingXXL = 32.0;     // 2XL 간격
  
  // ===== 패널 시스템 =====
  static const double panelRadius = 8.0;     // 패널 모서리
  static const double panelPadding = 16.0;   // 패널 내부 여백
  static const double panelBorderWidth = 1.0; // 패널 테두리 두께
  
  // ===== 버튼 시스템 =====
  static const double buttonHeight = 40.0;   // 버튼 높이
  static const double buttonRadius = 6.0;    // 버튼 모서리
  static const double buttonPadding = 12.0;  // 버튼 내부 여백
  
  // ===== 아이콘 시스템 =====
  static const double iconSizeXS = 12.0;     // 초소형 아이콘
  static const double iconSizeSM = 16.0;     // 소형 아이콘
  static const double iconSizeMD = 20.0;     // 중형 아이콘
  static const double iconSizeLG = 24.0;     // 대형 아이콘
  static const double iconSizeXL = 32.0;     // 초대형 아이콘
  
  // ===== 그림자 시스템 =====
  static const List<BoxShadow> shadowSM = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4.0,
      offset: Offset(0, 2),
    ),
  ];
  
  static const List<BoxShadow> shadowMD = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8.0,
      offset: Offset(0, 4),
    ),
  ];
  
  static const List<BoxShadow> shadowLG = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 16.0,
      offset: Offset(0, 8),
    ),
  ];
  
  // ===== 애니메이션 =====
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  
  // ===== 레이아웃 =====
  static const double sidebarWidth = 320.0;  // 사이드바 너비
  static const double headerHeight = 60.0;   // 헤더 높이
  static const double footerHeight = 120.0;  // 푸터 높이
}

/// 텍스트 스타일 시스템
class TextStyles {
  // 헤더 스타일
  static const TextStyle headerLarge = TextStyle(
    fontFamily: DesignTokens.fontFamily,
    fontSize: DesignTokens.fontSizeXXL,
    fontWeight: DesignTokens.fontWeightBold,
    color: DesignTokens.textPrimary,
  );
  
  static const TextStyle headerMedium = TextStyle(
    fontFamily: DesignTokens.fontFamily,
    fontSize: DesignTokens.fontSizeXL,
    fontWeight: DesignTokens.fontWeightSemiBold,
    color: DesignTokens.textPrimary,
  );
  
  static const TextStyle headerSmall = TextStyle(
    fontFamily: DesignTokens.fontFamily,
    fontSize: DesignTokens.fontSizeLG,
    fontWeight: DesignTokens.fontWeightSemiBold,
    color: DesignTokens.textPrimary,
  );
  
  // 본문 스타일
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: DesignTokens.fontFamily,
    fontSize: DesignTokens.fontSizeLG,
    fontWeight: DesignTokens.fontWeightNormal,
    color: DesignTokens.textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: DesignTokens.fontFamily,
    fontSize: DesignTokens.fontSizeMD,
    fontWeight: DesignTokens.fontWeightNormal,
    color: DesignTokens.textPrimary,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: DesignTokens.fontFamily,
    fontSize: DesignTokens.fontSizeSM,
    fontWeight: DesignTokens.fontWeightNormal,
    color: DesignTokens.textSecondary,
  );
  
  // 라벨 스타일
  static const TextStyle labelLarge = TextStyle(
    fontFamily: DesignTokens.fontFamily,
    fontSize: DesignTokens.fontSizeMD,
    fontWeight: DesignTokens.fontWeightMedium,
    color: DesignTokens.textSecondary,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontFamily: DesignTokens.fontFamily,
    fontSize: DesignTokens.fontSizeSM,
    fontWeight: DesignTokens.fontWeightMedium,
    color: DesignTokens.textSecondary,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontFamily: DesignTokens.fontFamily,
    fontSize: DesignTokens.fontSizeXS,
    fontWeight: DesignTokens.fontWeightMedium,
    color: DesignTokens.textMuted,
  );
  
  // 모노스페이스 스타일 (숫자용)
  static const TextStyle monoLarge = TextStyle(
    fontFamily: DesignTokens.fontFamilyMono,
    fontSize: DesignTokens.fontSizeLG,
    fontWeight: DesignTokens.fontWeightMedium,
    color: DesignTokens.textPrimary,
  );
  
  static const TextStyle monoMedium = TextStyle(
    fontFamily: DesignTokens.fontFamilyMono,
    fontSize: DesignTokens.fontSizeMD,
    fontWeight: DesignTokens.fontWeightMedium,
    color: DesignTokens.textPrimary,
  );
  
  static const TextStyle monoSmall = TextStyle(
    fontFamily: DesignTokens.fontFamilyMono,
    fontSize: DesignTokens.fontSizeSM,
    fontWeight: DesignTokens.fontWeightMedium,
    color: DesignTokens.textSecondary,
  );
}

/// 버튼 스타일 시스템
class ButtonStyles {
  // 기본 버튼
  static ButtonStyle primary = ButtonStyle(
    backgroundColor: MaterialStateProperty.all(DesignTokens.accent),
    foregroundColor: MaterialStateProperty.all(Colors.white),
    padding: MaterialStateProperty.all(
      const EdgeInsets.symmetric(
        horizontal: DesignTokens.buttonPadding,
        vertical: DesignTokens.spacingSM,
      ),
    ),
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.buttonRadius),
      ),
    ),
    minimumSize: MaterialStateProperty.all(
      const Size(0, DesignTokens.buttonHeight),
    ),
  );
  
  // 보조 버튼
  static ButtonStyle secondary = ButtonStyle(
    backgroundColor: MaterialStateProperty.all(DesignTokens.secondary),
    foregroundColor: MaterialStateProperty.all(DesignTokens.textPrimary),
    padding: MaterialStateProperty.all(
      const EdgeInsets.symmetric(
        horizontal: DesignTokens.buttonPadding,
        vertical: DesignTokens.spacingSM,
      ),
    ),
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.buttonRadius),
        side: const BorderSide(color: DesignTokens.border),
      ),
    ),
    minimumSize: MaterialStateProperty.all(
      const Size(0, DesignTokens.buttonHeight),
    ),
  );
  
  // 텍스트 버튼
  static ButtonStyle text = ButtonStyle(
    foregroundColor: MaterialStateProperty.all(DesignTokens.accent),
    padding: MaterialStateProperty.all(
      const EdgeInsets.symmetric(
        horizontal: DesignTokens.buttonPadding,
        vertical: DesignTokens.spacingSM,
      ),
    ),
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.buttonRadius),
      ),
    ),
    minimumSize: MaterialStateProperty.all(
      const Size(0, DesignTokens.buttonHeight),
    ),
  );
}

/// 패널 스타일 시스템
class PanelStyles {
  // 기본 패널
  static BoxDecoration defaultPanel = BoxDecoration(
    color: DesignTokens.secondary,
    borderRadius: BorderRadius.circular(DesignTokens.panelRadius),
    border: Border.all(color: DesignTokens.border, width: DesignTokens.panelBorderWidth),
    boxShadow: DesignTokens.shadowMD,
  );
  
  // 강조 패널
  static BoxDecoration accentPanel = BoxDecoration(
    color: DesignTokens.secondary,
    borderRadius: BorderRadius.circular(DesignTokens.panelRadius),
    border: Border.all(color: DesignTokens.borderAccent, width: DesignTokens.panelBorderWidth),
    boxShadow: DesignTokens.shadowMD,
  );
  
  // 카드 패널
  static BoxDecoration cardPanel = BoxDecoration(
    color: DesignTokens.surface,
    borderRadius: BorderRadius.circular(DesignTokens.panelRadius),
    border: Border.all(color: DesignTokens.border, width: DesignTokens.panelBorderWidth),
    boxShadow: DesignTokens.shadowSM,
  );
}

