#===================================================================
#        PK情報解析パッケージ
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
package PKData;

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
    $self->{PKData} = {};
    
    #初期化
    $self->{Datas}{PKData}   = StoreData->new();
    
    my $header_list = "";

    $header_list = [
                "result_no",
                "generate_no",
                "e_no",
                "pk_num",
                "pk_win_num",
                "latest_pk_result_no",
                "pkk_num",
                "pkk_win_num",
                "latest_pkk_result_no",
    ];

    $self->{Datas}{PKData}->Init($header_list);

    #出力ファイル設定
    $self->{Datas}{PKData}->SetOutputName ( "./output/chara/pk_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    
    $self->ReadLastData();

    return;
}

#-----------------------------------#
#    既存データを読み込む
#-----------------------------------#
sub ReadLastData(){
    my $self      = shift;
    
    my $file_name = "";
    $file_name = "./output/chara/pk_" . ($self->{ResultNo} - 1) . "_0.csv" ;
    
    #既存データの読み込み
    my $content = &IO::FileRead ( $file_name );
    
    my @file_data = split(/\n/, $content);
    shift (@file_data);
    
    foreach my  $data_set(@file_data){
        my $pk_datas = [];
        @$pk_datas   = split(ConstData::SPLIT, $data_set);
        my $e_no = $$pk_datas[2];
        $self->{PKData}{$e_no} = [$$pk_datas[3], $$pk_datas[4], $$pk_datas[5], $$pk_datas[6], $$pk_datas[7], $$pk_datas[8]];
    }

    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜項目名の前にある星画像ノード
#-----------------------------------#
sub GetPKAnnounceData{
    my $self = shift;
    my $node = shift;
    my $e_no = shift;
    
    if (!$node) {return;}

    my $td_nodes    = &GetNode::GetNode_Tag("td", \$node);

    if (!scalar(@$td_nodes)) {return;}

    my $b_Y6i_nodes = &GetNode::GetNode_Tag_Attr("b", "class", "Y6i", \$node->parent);
    my $b_R6i_nodes = &GetNode::GetNode_Tag_Attr("b", "class", "R6i", \$node->parent);

    if (!scalar(@$b_Y6i_nodes) && !scalar(@$b_R6i_nodes)) {return;}

    if (!scalar(@$b_Y6i_nodes)) {return;}
    my $pk = $self->CheckEnemyPKer($node);

    if (!exists($self->{PKData}{$e_no})) {
        $self->{PKData}{$e_no} = [0, 0, 0, 0, 0, 0];
    }

    if ($pk == 1) {
        $self->{PKData}{$e_no}[0] += 1;
        $self->{PKData}{$e_no}[2] = $self->{ResultNo};

    } else {
        $self->{PKData}{$e_no}[3] += 1;
        $self->{PKData}{$e_no}[5] = $self->{ResultNo};
    }

    return;
}

#-----------------------------------#
#    対人メンバー内で最も若いENoの時に正を返す
#------------------------------------
#    引数｜対戦組み合わせデータノード
#-----------------------------------#
sub CheckEnemyPKer{
    my $self = shift;
    my $node = shift;

    if (!$node) {return 0;}

    my $td_nodes    = &GetNode::GetNode_Tag("td", \$node);

    my $right_link_nodes = &GetNode::GetNode_Tag("a", \$$td_nodes[2]);

    # 先頭ENoの判定
    foreach my $right_link_node (@$right_link_nodes) {
        my $e_no = &GetIkkiNode::GetENoFromLink($right_link_node);
        if (exists($self->{PKData}{$e_no}) && $self->{PKData}{$e_no}[0]) {return 1;}
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
    
 
    # PK情報の書き出し
    foreach my $e_no (sort{$a cmp $b} keys %{ $self->{PKData} } ) {
        my $datas = $self->{PKData}{$e_no};
        $self->{Datas}{PKData}->AddData  (join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo}, $e_no, $$datas[0], $$datas[1], $$datas[2], $$datas[3], $$datas[4], $$datas[5]) ));
    }

    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    return;
}
1;
