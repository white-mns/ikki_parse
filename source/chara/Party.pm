#===================================================================
#        所属パーティ取得パッケージ
#-------------------------------------------------------------------
#            (C) 2020 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#   
use strict;
use warnings;
require "./source/lib/Store_Data.pm";
require "./source/lib/Store_HashData.pm";
use ConstData;        #定数呼び出し
use source::lib::GetNode;
use source::lib::GetIkkiNode;


#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#     
package Party;

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
    $self->{Datas}{Party}     = StoreData->new();
    $self->{Datas}{PartyInfo} = StoreData->new();
    $self->{CommonDatas}{Party} = {};

    my $header_list = "";
   
    $header_list = [
                "result_no",
                "generate_no",
                "e_no",
                "party_type",
                "party_no",
    ];

    $self->{Datas}{Party}->Init($header_list);
 
    $header_list = [
                "result_no",
                "generate_no",
                "party_no",
                "party_type",
                "name",
                "member_num",
    ];

    $self->{Datas}{PartyInfo}->Init($header_list);
   
    #出力ファイル設定
    $self->{Datas}{Party}->SetOutputName    ( "./output/chara/party_"       . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    $self->{Datas}{PartyInfo}->SetOutputName( "./output/chara/party_info_"  . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );

    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜e_no,名前データノード
#-----------------------------------#
sub GetData{
    my $self = shift;
    my $e_no = shift;
    my $nodes = shift;
    
    $self->{ENo} = $e_no;

    my $battle_table      = &GetIkkiNode::SearchMatchingTableNodeFromStarImg($nodes, "Battle!!");
    my $next_battle_table = &GetIkkiNode::SearchMatchingTableNodeFromStarImg($nodes, "Next Battle");
    my $duel_table =   &GetIkkiNode::SearchMatchingTableNodeFromStarImg($nodes, "DUEL!!", "before", "Next Battle");
    my $next_duel_table =   &GetIkkiNode::SearchMatchingTableNodeFromStarImg($nodes, "DUEL!!", "after", "Next Battle");

    $self->{CommonDatas}{Party}{$self->{ENo}} = $self->{ENo};

    $self->GetParty    ($battle_table, 0);
    $self->GetPartyInfo($battle_table, 0);

    $self->GetParty    ($next_battle_table,  1);
    $self->GetPartyInfo($next_battle_table,  1);
 
    $self->GetParty    ($duel_table, 10);
    $self->GetPartyInfo($duel_table, 10);
 
    $self->GetParty    ($next_duel_table, 11);
    $self->GetPartyInfo($next_duel_table, 11);
   
    return;
}

#-----------------------------------#
#    パーティ内で最も若いENoをパーティ番号として所属パーティ取得
#------------------------------------
#    引数｜対戦組み合わせデータノード
#          パーティタイプ 
#            0:今回戦闘
#            1:次回予告
#-----------------------------------#
sub GetParty{
    my $self = shift;
    my $node = shift;
    my $party_type = shift;

    if (!$node) {return;}
    
    my $td_nodes    = &GetNode::GetNode_Tag("td", \$node);

    if (!scalar(@$td_nodes)) {return;}
    
    my $link_nodes = &GetNode::GetNode_Tag("a", \$$td_nodes[0]);

    my $party = &GetIkkiNode::GetENoFromLink($$link_nodes[0]);

    $self->{Datas}{Party}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo}, $self->{ENo}, $party_type, $party) ));
    
    $self->{CommonDatas}{Party}{$self->{ENo}} = $party;

    return;
}

#-----------------------------------#
#    パーティ内で最も若いENoの時、そのEnoをパーティ番号としてパーティ情報を取得
#------------------------------------
#    引数｜対戦組み合わせデータノード
#          パーティタイプ 
#            0:今回戦闘
#            1:次回予告
#-----------------------------------#
sub GetPartyInfo{
    my $self = shift;
    my $node = shift;
    my $party_type = shift;

    if (!$node) {return;}
    
    my $td_nodes    = &GetNode::GetNode_Tag("td", \$node);

    if (!scalar(@$td_nodes)) {return;}
    
    my $link_nodes = &GetNode::GetNode_Tag("a", \$$td_nodes[0]);

    if ($self->{ENo} != &GetIkkiNode::GetENoFromLink($$link_nodes[0]) ) {return;} # 戦闘ENoの判定
    
    # パーティ情報の取得
    my ($name, $member_num) = (0, 0);
    
    my $u_nodes = &GetNode::GetNode_Tag("u", \$$td_nodes[0]);
    
    $name = $$u_nodes[0]->as_text;
    $member_num = int( scalar(@$link_nodes) );

    $self->{Datas}{PartyInfo}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo}, $self->{ENo}, $party_type, $name, $member_num) ));
            

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
