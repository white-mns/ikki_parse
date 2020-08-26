#===================================================================
#        定数設定
#-------------------------------------------------------------------
#            (C) 2020 @white_mns
#===================================================================

# パッケージの定義    ---------------#    
package ConstData;

# パッケージの使用宣言    ---------------#
use strict;
use warnings;

# 定数宣言    ---------------#
    use constant SPLIT => "\t"; # 区切り文字

# ▼ 実行制御 =============================================
#      実行する場合は 1 ，実行しない場合は 0 ．
    
    use constant EXE_DATA                 => 1;
        use constant EXE_DATA_PROPER_NAME        => 1;
        use constant EXE_DATA_EMBRYO_NAME        => 1;
        use constant EXE_DATA_SKILL_DATA         => 1;
        use constant EXE_DATA_AREA_DATA          => 1;
    use constant EXE_CHARA                => 1;  
        use constant EXE_CHARA_NAME              => 1;
        use constant EXE_CHARA_STATUS            => 1;
        use constant EXE_CHARA_PRODUCTION        => 1;
        use constant EXE_CHARA_EMBRYO            => 1;
        use constant EXE_CHARA_SKILL             => 1;
        use constant EXE_CHARA_ITEM              => 1;
        use constant EXE_CHARA_INIT_EQUIP        => 1;
        use constant EXE_CHARA_CURRENT_AREA      => 1;
        use constant EXE_CHARA_PARTY             => 1;
        use constant EXE_CHARA_PARTY_INFO        => 1;
        use constant EXE_CHARA_NEXT_BATTLE_ENEMY => 1;
        use constant EXE_CHARA_NEXT_BATTLE_INFO  => 1;
        use constant EXE_CHARA_NEXT_DUEL_INFO    => 1;
    use constant EXE_NEW                  => 1;  
        use constant EXE_NEW_ITEM                => 1;
        use constant EXE_NEW_ITEM_FUKA           => 1;
        use constant EXE_NEW_EMBRYO              => 1;
        use constant EXE_NEW_SKILL               => 1;
        use constant EXE_NEW_NEXT_ENEMY          => 1;
    use constant EXE_BATTLE               => 1;
    use constant EXE_NEW                  => 1;

1;
