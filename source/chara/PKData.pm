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
    $self->{Datas}{Assault}  = StoreData->new();
    $self->{Datas}{PKResult} = StoreData->new();
    
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

    $header_list = [
                "result_no",
                "generate_no",
                "e_no",
                "assault_type",
    ];

    $self->{Datas}{Assault}->Init($header_list);

    $header_list = [
                "result_no",
                "generate_no",
                "e_no",
                "battle_result",
    ];

    $self->{Datas}{PKResult}->Init($header_list);

    #出力ファイル設定
    $self->{Datas}{PKData}->SetOutputName ( "./output/chara/pk_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    $self->{Datas}{Assault}->SetOutputName ( "./output/chara/assault_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    $self->{Datas}{PKResult}->SetOutputName ( "./output/chara/pk_result_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    
    $self->ReadBeforePKData();
    $self->ReadBeforeAssaultData();

    return;
}

#-----------------------------------#
#    前回のPKデータを読み込む
#-----------------------------------#
sub ReadBeforePKData(){
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
#    前回の襲撃データを読み込む
#-----------------------------------#
sub ReadBeforeAssaultData(){
    my $self      = shift;
    
    my $file_name = "";
    $file_name = "./output/chara/assault_" . ($self->{ResultNo} - 1) . "_0.csv" ;
    
    #既存データの読み込み
    my $content = &IO::FileRead ( $file_name );
    
    my @file_data = split(/\n/, $content);
    shift (@file_data);
    
    foreach my  $data_set(@file_data){
        my $assault_datas = [];
        @$assault_datas   = split(ConstData::SPLIT, $data_set);
        my $e_no = $$assault_datas[2];
        $self->{BeforeAssault}{$e_no} = $$assault_datas[3];
    }

    return;
}

#-----------------------------------#
#    予告データ取得
#------------------------------------
#    引数｜デュエル予告TABLEノード
#          ENo
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

    my $pk = $self->GetAssaultType($node, $e_no, scalar(@$b_Y6i_nodes), scalar(@$b_R6i_nodes));

    if (!scalar(@$b_Y6i_nodes)) {return;}

    if (!exists($self->{PKData}{$e_no})) {
        $self->{PKData}{$e_no} = [0, 0, 0, 0, 0, 0];
    }

    if ($pk < 5) {
        $self->{PKData}{$e_no}[0] += 1;
        $self->{PKData}{$e_no}[2] = $self->{ResultNo};

    } elsif ($pk == 5) {
        $self->{PKData}{$e_no}[3] += 1;
        $self->{PKData}{$e_no}[5] = $self->{ResultNo};
    }

    return;
}

#-----------------------------------#
#    デュエル結果データ取得
#------------------------------------
#    引数｜デュエル開始TABLEノード
#          ENo
#          デュエル勝敗
#-----------------------------------#
sub GetPKResultData{
    my $self = shift;
    my $node = shift;
    my $e_no = shift;
    my $duel_result = shift;

    if (!$node) {return;}

    my $b_W6i_nodes = &GetNode::GetNode_Tag_Attr("b", "class", "W6i", \$node->parent);

    if (scalar(@$b_W6i_nodes)) {return;}
    
    $self->{Datas}{PKResult}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo}, $e_no, $duel_result) ));

    if ($duel_result != 1) {return;}

    if (!exists($self->{BeforeAssault}{$e_no})) { return;}

    my $pk = $self->{BeforeAssault}{$e_no};

    if ($pk < 3) {
        $self->{PKData}{$e_no}[1] += 1;

    } elsif ($pk == 5) {
        $self->{PKData}{$e_no}[4] += 1;
    }

    return;
}

#-----------------------------------#
#    襲撃データ取得
#------------------------------------
#    引数｜デュエル予告TABLEノード
#          ENo
#          襲撃テキストノード数(0 or 1)
#          非襲撃テキストノード数(0 or 1)
#    引数｜1 : PK襲撃
#          2 : PKvsPK襲撃
#          3 : PKK被襲撃
#          4 : PKvsPK被襲撃
#          5 : PKK襲撃
#          6 : PK被襲撃
#-----------------------------------#
sub GetAssaultType{
    my $self = shift;
    my $node = shift;
    my $e_no = shift;
    my $assault = shift;
    my $assaulted = shift;

    my $assault_type = 1;
    my $enemy_pker = $self->CheckEnemyPKer($node);
    my $enemy_wanted = $self->CheckEnemyWanted($node);

    if ($assault) {
        if ($enemy_wanted) {
           if (!exists($self->{PKData}{$e_no}) || $self->{PKData}{$e_no}[0] == 0) { # 襲撃者が過去にPKをしておらず対象が賞金首のとき、PKKとして判定
               $assault_type = 5;

           } else {
               $assault_type = 2;
           }
       } else {
          $assault_type = 1;
       }

    } elsif($assaulted) {
        if (!exists($self->{CommonDatas}{Prize}{$e_no}) || $self->{CommonDatas}{Prize}{$e_no} == 0) { # 襲撃者が過去にPKをしておらず対象がPKのとき、被害者として判定
            $assault_type = 6;
        } else {
            if ($enemy_pker) { $assault_type = 4;}
            else             { $assault_type = 3;}
        }

    } else {
        return;
    }
    
    $self->{Datas}{Assault}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo}, $e_no, $assault_type) ));

    return $assault_type;
}


#-----------------------------------#
#    デュエル相手に賞金首がいる時に正を返す
#------------------------------------
#    引数｜デュエル予告TABLEノード
#-----------------------------------#
sub CheckEnemyWanted{
    my $self = shift;
    my $node = shift;

    if (!$node) {return 0;}

    my $td_nodes    = &GetNode::GetNode_Tag("td", \$node);

    my $right_link_nodes = &GetNode::GetNode_Tag("a", \$$td_nodes[2]);

    # 先頭ENoの判定
    foreach my $right_link_node (@$right_link_nodes) {
        my $e_no = &GetIkkiNode::GetENoFromLink($right_link_node);
        if (exists($self->{CommonDatas}{Prize}{$e_no}) && $self->{CommonDatas}{Prize}{$e_no} > 0) {return 1;}
    }

    return 0;
}

#-----------------------------------#
#    デュエル相手にPKがいる時に正を返す
#------------------------------------
#    引数｜デュエル予告TABLEノード
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
        if (exists($self->{PKData}{$e_no}) && $self->{PKData}{$e_no}[0] > 0) {return 1;}
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
