#===================================================================
#        戦闘予告取得パッケージ
#-------------------------------------------------------------------
#            (C) 2020 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#   
use strict;
use warnings;
require "./source/lib/Store_Data.pm";
require "./source/lib/Store_HashData.pm";

require "./source/new/NewNextEnemy.pm";

use ConstData;        #定数呼び出し
use source::lib::GetNode;
use source::lib::GetIkkiNode;


#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#     
package NextBattle;

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
    
    #初期化
    $self->{Datas}{NextBattleEnemy} = StoreData->new();
    $self->{Datas}{NextBattleInfo}  = StoreData->new();
    $self->{Datas}{NextDuelInfo}    = StoreData->new();
    $self->{Datas}{New}   = NewNextEnemy->new();
    
    $self->{Datas}{New}->Init($self->{ResultNo}, $self->{GenerateNo}, $self->{CommonDatas});
    
    my $header_list = "";
   
    $header_list = [
                "result_no",
                "generate_no",
                "party_no",
                "is_boss",
                "enemy_id",
    ];

    $self->{Datas}{NextBattleEnemy}->Init($header_list);
 
    $header_list = [
                "result_no",
                "generate_no",
                "party_no",
                "is_boss",
                "enemy_party_name_id",
                "member_num",
                "enemy_names",
    ];

    $self->{Datas}{NextBattleInfo}->Init($header_list);
  
    $header_list = [
                "result_no",
                "generate_no",
                "left_party_no",
                "right_party_no",
                "battle_type",
    ];

    $self->{Datas}{NextDuelInfo}->Init($header_list);
   
  
    #出力ファイル設定
    $self->{Datas}{NextBattleEnemy}->SetOutputName( "./output/chara/next_battle_enemy_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    $self->{Datas}{NextBattleInfo}->SetOutputName ( "./output/chara/next_battle_info_"  . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    $self->{Datas}{NextDuelInfo}->SetOutputName   ( "./output/chara/next_duel_info_"    . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );

    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜e_no,ブロックdivノード
#-----------------------------------#
sub GetData{
    my $self = shift;
    my $e_no = shift;
    my $nodes = shift;
    
    $self->{ENo} = $e_no;
    
    my $next_battle_table = &GetIkkiNode::SearchMatchingTableNodeFromStarImg($nodes, "Next Battle");
    my $next_duel_table = &GetIkkiNode::SearchMatchingTableNodeFromStarImg($nodes, "DUEL!!");

    if (!$self->CheckPartyHead($next_battle_table)) { return;}
    
    $self->{PNo} = $e_no;

    $self->GetNextBattleEnemy($next_battle_table);
    $self->GetNextBattleInfo ($next_battle_table);
    
    if ($self->CheckDuelHead($next_duel_table)) {
        $self->GetNextDuelInfo ($next_duel_table);
    }

    return;
}

#-----------------------------------#
#    パーティ内で最も若いENoをパーティ番号として戦闘予告取得
#------------------------------------
#    引数｜対戦組み合わせデータノード
#          戦闘タイプ 
#            0:『遭遇戦』『採集』
#            1:『開放戦』『特殊戦』
#-----------------------------------#
sub GetNextBattleEnemy{
    my $self = shift;
    my $node = shift;
    my $enemy_id = 0;

    if (!$node) {return;}

    my $td_nodes    = &GetNode::GetNode_Tag("td", \$node);

    if (!scalar(@$td_nodes)) {return;}

    my $u_R5i_nodes = &GetNode::GetNode_Tag_Attr("u", "class", "R5i", \$node);

    my $is_boss = ($$u_R5i_nodes[0] && $$u_R5i_nodes[0]->as_text ne "Encounter") ? 1 : 0;
    
    my $i_nodes = &GetNode::GetNode_Tag("i", \$$td_nodes[2]);

    foreach my $i_node (@$i_nodes) {
        my $enemy_id = $self->{CommonDatas}{ProperName}->GetOrAddId($i_node->as_text);

        $self->{Datas}{NextBattleEnemy}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo}, $self->{PNo}, $is_boss, $enemy_id) ));
    
        $self->{Datas}{New}->RecordNewNextEnemyData($enemy_id, $is_boss);
    }

    return;
}

#-----------------------------------#
#    パーティ内で最も若いENoの時、そのEnoをパーティ番号としてパーティ情報を取得
#------------------------------------
#    引数｜対戦組み合わせデータノード
#          戦闘タイプ 
#            0:今回戦闘
#            1:次回予告
#-----------------------------------#
sub GetNextBattleInfo{
    my $self = shift;
    my $node = shift;

    if (!$node) {return;}

    my $td_nodes    = &GetNode::GetNode_Tag("td", \$node);

    if (!scalar(@$td_nodes)) {return;}

    # パーティ情報の取得
    my ($name_id, $member_num) = (0, 0);

    my $u_R5i_nodes = &GetNode::GetNode_Tag_Attr("u", "class", "R5i", \$node);

    my $is_boss = ($$u_R5i_nodes[0] && $$u_R5i_nodes[0]->as_text ne "Encounter") ? 1 : 0;

    my $i_nodes = &GetNode::GetNode_Tag("i", \$$td_nodes[2]);

    $name_id = $self->{CommonDatas}{ProperName}->GetOrAddId($$u_R5i_nodes[0]->as_text);
    $member_num = int( scalar(@$i_nodes) );

    my $enemy_names = "";

    foreach my $i_node (@$i_nodes) {
        $enemy_names .= $i_node->as_text . ","
    }
    chomp($enemy_names);

    $self->{Datas}{NextBattleInfo}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo}, $self->{PNo}, $is_boss, $name_id, $member_num, $enemy_names) ));

    return;
}

#-----------------------------------#
#    左側で最も若いENoの時、対人戦情報を取得
#------------------------------------
#    引数｜対戦組み合わせデータノード
#          戦闘タイプ 
#            10:決闘
#            11:練習試合
#-----------------------------------#
sub GetNextDuelInfo{
    my $self = shift;
    my $node = shift;

    if (!$node) {return;}

    my $td_nodes    = &GetNode::GetNode_Tag("td", \$node);

    if (!scalar(@$td_nodes)) {return;}

    my $left_link_nodes = &GetNode::GetNode_Tag("a", \$$td_nodes[0]);
    my $right_link_nodes = &GetNode::GetNode_Tag("a", \$$td_nodes[2]);

    if (!scalar(@$left_link_nodes) || !scalar(@$right_link_nodes)) {return;}

    my $left_party_no  = &GetIkkiNode::GetENoFromLink($$left_link_nodes[0]);
    my $right_party_no = &GetIkkiNode::GetENoFromLink($$right_link_nodes[0]);

    my $b_R5i_nodes = &GetNode::GetNode_Tag_Attr("b", "class", "R5i", \$node->parent);

    my $battle_type = ($$b_R5i_nodes[0] && $$b_R5i_nodes->as_text =~ /デュエル/) ? 1 : 0;

    $self->{Datas}{NextDuelInfo}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo}, $left_party_no, $right_party_no, $battle_type) ));

    return;
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
