#===================================================================
#        戦闘勝敗解析パッケージ
#-------------------------------------------------------------------
#            (C) 2020 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#   
use strict;
use warnings;
require "./source/lib/Store_Data.pm";
require "./source/lib/Store_HashData.pm";

require "./source/new/NewBattleEnemy.pm";
require "./source/new/NewDefeatEnemy.pm";

use ConstData;        #定数呼び出し
use source::lib::GetNode;
use source::lib::GetIkkiNode;

#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#     
package BattleResult;

#-----------------------------------#
#    コンストラクタ
#-----------------------------------#
sub new {
  my $class = shift;
  
  bless {
        Datas => {},
  }, $class;
}

#-----------------------------------#
#    初期化
#-----------------------------------#
sub Init{
    my $self = shift;
    ($self->{ResultNo}, $self->{GenerateNo}, $self->{CommonDatas}) = @_;
    ($self->{BeforeResultNo}, $self->{BeforeGenerateNo}) = ($self->{ResultNo} - 1, 0);
    
    #初期化
    $self->{Datas}{BattleResult}   = StoreData->new();
    $self->{Datas}{DuelResult}     = StoreData->new();
    $self->{Datas}{NewBattleEnemy} = NewBattleEnemy->new();
    $self->{Datas}{NewDefeatEnemy} = NewDefeatEnemy->new();
    
    $self->{Datas}{NewBattleEnemy}->Init($self->{ResultNo}, $self->{GenerateNo}, $self->{CommonDatas});
    $self->{Datas}{NewDefeatEnemy}->Init($self->{ResultNo}, $self->{GenerateNo}, $self->{CommonDatas});
    
    my $header_list = "";

    $header_list = [
                "result_no",
                "generate_no",
                "before_result_no",
                "before_generate_no",
                "party_no",
                "battle_result",
    ];

    $self->{Datas}{BattleResult}->Init($header_list);
   
    $header_list = [
                "result_no",
                "generate_no",
                "before_result_no",
                "before_generate_no",
                "left_party_no",
                "right_party_no",
                "battle_result",
    ];

    $self->{Datas}{DuelResult}->Init($header_list);

    #出力ファイル設定
    $self->{Datas}{BattleResult}->SetOutputName ( "./output/chara/battle_result_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    $self->{Datas}{DuelResult}->SetOutputName ( "./output/chara/duel_result_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );


    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜項目名の前にある星画像ノード
#-----------------------------------#
sub GetData{
    my $self = shift;
    my $e_no = shift;
    my $nodes = shift;
    
    $self->{ENo} = $e_no;

    my $battle_table = &GetIkkiNode::SearchMatchingTableNodeFromStarImg($nodes, "Battle!!");
    my $duel_table =   &GetIkkiNode::SearchMatchingTableNodeFromStarImg($nodes, "DUEL!!", "before", "Next Battle");

    $self->{PNo} = $e_no;
    
    my $battle_result = &GetIkkiNode::GetBattleResultFromStarImg($nodes, "before", "DUEL!!");
    my $duel_result   = &GetIkkiNode::GetBattleResultFromStarImg($nodes, "after", "DUEL!!");

    $self->{CommonDatas}{PKData}->GetPKResultData($duel_table, $e_no, $duel_result);

    if (!$self->CheckPartyHead($battle_table)) { return;}
    
    $self->{MemberNum} = $self->GetMemberNum($battle_table);
    $self->GetBattleEnemy($battle_table, $battle_result);

    $self->{Datas}{BattleResult}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo}, $self->{BeforeResultNo}, $self->{BeforeGenerateNo}, $self->{PNo},    $battle_result) ));

    $self->AddDuelResultData($duel_table, $duel_result);
    
    return;
}

#-----------------------------------#
#    パーティ内で最も若いENoをパーティ番号として戦闘予告取得
#------------------------------------
#    引数｜対戦組み合わせデータノード
#          勝敗
#-----------------------------------#
sub GetBattleEnemy{
    my $self = shift;
    my $node = shift;
    my $battle_result = shift;
    my $enemy_id = 0;

    if (!$node) {return;}

    my $td_nodes    = &GetNode::GetNode_Tag("td", \$node);

    if (!scalar(@$td_nodes)) {return;}

    my $is_boss = $self->CheckBossBattle($node);
    
    my $i_nodes = &GetNode::GetNode_Tag("i", \$$td_nodes[2]);

    foreach my $i_node (@$i_nodes) {
        my $enemy_id = $self->{CommonDatas}{ProperName}->GetOrAddId($i_node->as_text);

        my $area_id = $self->{CommonDatas}{CurrentArea}{$self->{ENo}}[0];
        my $advance = $self->{CommonDatas}{CurrentArea}{$self->{ENo}}[1];

        $self->{Datas}{NewBattleEnemy}->RecordNewBattleEnemyData($enemy_id, $is_boss, $area_id, $advance);
        if ($battle_result == 1) {

            $self->{Datas}{NewDefeatEnemy}->RecordNewDefeatEnemyData($enemy_id, 0, $is_boss, $area_id, $advance, , $self->{PNo});
            $self->{Datas}{NewDefeatEnemy}->RecordNewDefeatEnemyData($enemy_id, $self->{MemberNum}, $is_boss, $area_id, $advance, , $self->{PNo});
        }
    }

    return;
}

#-----------------------------------#
#    左側で最も若いENoの時、対人戦情報を取得
#------------------------------------
#    引数｜対戦組み合わせデータノード
#          勝敗
#-----------------------------------#
sub AddDuelResultData{
    my $self = shift;
    my $node = shift;
    my $duel_result = shift;

    if (!$node) {return;}

    if (!$self->CheckDuelHead($node)) {return;}

    my $td_nodes    = &GetNode::GetNode_Tag("td", \$node);

    if (!scalar(@$td_nodes)) {return;}

    my $left_link_nodes = &GetNode::GetNode_Tag("a", \$$td_nodes[0]);
    my $right_link_nodes = &GetNode::GetNode_Tag("a", \$$td_nodes[2]);

    if (!scalar(@$left_link_nodes) || !scalar(@$right_link_nodes)) {return;}

    my $left_party_no  = &GetIkkiNode::GetENoFromLink($$left_link_nodes[0]);
    my $right_party_no = &GetIkkiNode::GetENoFromLink($$right_link_nodes[0]);

    $self->{Datas}{DuelResult}->AddData  (join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo}, $self->{BeforeResultNo}, $self->{BeforeGenerateNo}, $left_party_no, $right_party_no, $duel_result) ));

    return;
}

#-----------------------------------#
#    パーティ人数を取得
#------------------------------------
#    引数｜対戦組み合わせデータノード
#            0:今回戦闘
#-----------------------------------#
sub GetMemberNum{
    my $self = shift;
    my $node = shift;

    if (!$node) {return;}
    
    my $td_nodes    = &GetNode::GetNode_Tag("td", \$node);

    if (!scalar(@$td_nodes)) {return;}
    
    my $link_nodes = &GetNode::GetNode_Tag("a", \$$td_nodes[0]);

    if ($self->{ENo} != &GetIkkiNode::GetENoFromLink($$link_nodes[0]) ) {return 0;} # 戦闘ENoの判定
    
    # パーティ情報の取得
    my ($member_num) = (0);
    
    my $u_nodes = &GetNode::GetNode_Tag("u", \$$td_nodes[0]);
    
    $member_num = int( scalar(@$link_nodes) );

    return $member_num;
}


#-----------------------------------#
#    パーティ内で最も若いENoの時に正を返す
#------------------------------------
#    引数｜対戦組み合わせデータノード
#-----------------------------------#
sub CheckPartyHead{
    my $self = shift;
    my $node = shift;

    if (!$node) {return 0;}

    my $td_nodes    = &GetNode::GetNode_Tag("td", \$node);

    my $link_nodes = &GetNode::GetNode_Tag("a", \$$td_nodes[0]);

    # 先頭ENoの判定
    if ($self->{ENo} == &GetIkkiNode::GetENoFromLink($$link_nodes[0]) ) {return 1;}

    return 0;
}

#-----------------------------------#
#    対人メンバー内で最も若いENoの時に正を返す
#------------------------------------
#    引数｜対戦組み合わせデータノード
#-----------------------------------#
sub CheckDuelHead{
    my $self = shift;
    my $node = shift;

    if (!$node) {return 0;}

    my $td_nodes    = &GetNode::GetNode_Tag("td", \$node);

    my $left_link_nodes = &GetNode::GetNode_Tag("a", \$$td_nodes[0]);
    my $right_link_nodes = &GetNode::GetNode_Tag("a", \$$td_nodes[2]);

    # 先頭ENoの判定
    if ($self->{ENo} != &GetIkkiNode::GetENoFromLink($$left_link_nodes[0]) ) {return 0;}
    if ($self->{ENo} < &GetIkkiNode::GetENoFromLink($$right_link_nodes[0]) ) {return 1;}

    return 0;
}

#-----------------------------------#
#    戦闘が特殊戦か判定する
#------------------------------------
#    引数｜対戦組み合わせデータノード
#-----------------------------------#
sub CheckBossBattle{
    my $self = shift;
    my $node = shift;

    if (!$node) {return;}

    my $td_nodes    = &GetNode::GetNode_Tag("td", \$node);

    if (!scalar(@$td_nodes)) {return;}

    my $u_R5i_nodes = &GetNode::GetNode_Tag_Attr("u", "class", "R5i", \$node);

    if ($$u_R5i_nodes[0] && $$u_R5i_nodes[0]->as_text ne "Encounter") {return 1;}

    my $i_nodes = &GetNode::GetNode_Tag("i", \$$td_nodes[2]);

    my @boss_names = ("兵士");

    foreach my $boss_name (@boss_names) {
        if ($$i_nodes[0]->as_text eq $boss_name) {return 1;}
    }

    return 0;
}

#-----------------------------------#
#    出力
#------------------------------------
#    引数｜
#-----------------------------------#
sub Output{
    my $self = shift;
    
    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    return;
}
1;
