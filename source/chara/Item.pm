#===================================================================
#        所持アイテム情報取得パッケージ
#-------------------------------------------------------------------
#            (C) 2020 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#   
use strict;
use warnings;
require "./source/lib/Store_Data.pm";
require "./source/lib/Store_HashData.pm";

require "./source/new/NewItemFuka.pm";
require "./source/new/NewItem.pm";

use ConstData;        #定数呼び出し
use source::lib::GetNode;


#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#     
package Item;

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
    $self->{Datas}{Data}        = StoreData->new();
    $self->{Datas}{NewItem}     = NewItem->new();
    $self->{Datas}{NewItemFuka} = NewItemFuka->new();

    $self->{Datas}{NewItem}->Init    ($self->{ResultNo}, $self->{GenerateNo}, $self->{CommonDatas});
    $self->{Datas}{NewItemFuka}->Init($self->{ResultNo}, $self->{GenerateNo}, $self->{CommonDatas});

    my $header_list = "";
   
    $header_list = [
                "result_no",
                "generate_no",
                "e_no",
                "i_no",
                "name",
                "kind_id",
                "strength",
                "effect_1_id",
                "effect_1_value",
                "effect_2_id",
                "effect_2_value",
                "effect_3_id",
                "effect_3_value",
    ];

    $self->{Datas}{Data}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/chara/item_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜e_no,divY870ノード
#-----------------------------------#
sub GetData{
    my $self    = shift;
    my $e_no    = shift;
    my $table_PD2_nodes = shift;
    
    $self->{ENo} = $e_no;

    my $item_title_node = $self->GetTitleNode($table_PD2_nodes, "アイテム");
    my $item_table_nodes = $item_title_node->right;

    if (!$item_title_node) {return;}

    $self->GetItemData($item_table_nodes);
    
    return;
}

#-----------------------------------#
#    アイテムデータ取得
#------------------------------------
#    引数｜アイテムデータノード
#-----------------------------------#
sub GetItemData{
    my $self  = shift;
    my $item_table_node = shift;

    my $tr_nodes = &GetNode::GetNode_Tag("tr",\$item_table_node);
    shift(@$tr_nodes);
 
    foreach my $tr_node (@$tr_nodes){
        my ($i_no, $name, $kind_id, $strength) = (0, "", 0, 0);
        my $effects = [{"id"=> 0, "value"=> 0},{"id"=> 0, "value"=> 0},{"id"=> 0, "value"=> 0}];

        my $td_nodes = &GetNode::GetNode_Tag("td",\$tr_node);

        if ($$td_nodes[1]->as_text eq " " && $$td_nodes[2]->as_text eq " ") {next;}

        $i_no = $$td_nodes[0]->as_text;
        $name = $$td_nodes[1]->as_text;
        $kind_id  = $self->{CommonDatas}{ProperName}->GetOrAddId($$td_nodes[2]->as_text);
        $strength = $$td_nodes[3]->as_text;

        for (my $i=4; $i < 7; $i++) {
            $self->GetEffect($$effects[$i-4], $$td_nodes[$i]->as_text);

        }

        $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo}, $self->{ENo}, $i_no, $name, $kind_id, $strength,
                                                              $$effects[0]{"id"}, $$effects[0]{"value"},
                                                              $$effects[1]{"id"}, $$effects[1]{"value"},
                                                              $$effects[2]{"id"}, $$effects[2]{"value"})));
    
        if ($$td_nodes[2]->as_text eq "材料") {
            $self->{Datas}{NewItem}->RecordNewItemData($name);
        }
    }

    return;
}

#-----------------------------------#
#    アイテム付加効果取得
#------------------------------------
#    引数｜アイテムデータノード
#-----------------------------------#
sub GetEffect{
    my $self  = shift;
    my $effect_hash = shift;
    my $effect_text = shift;

    $effect_text =~ s/\s//;

    if ($effect_text =~ /(\D+)(\d+)/) {
        $$effect_hash{"id"}    = $self->{CommonDatas}{ProperName}->GetOrAddId($1);
        $$effect_hash{"value"} = $2;

    } else {
        # 効果に数値がないとき
        $$effect_hash{"id"} = $self->{CommonDatas}{ProperName}->GetOrAddId($effect_text);
    }

    $self->{Datas}{NewItemFuka}->RecordNewItemFukaData($$effect_hash{"id"});
}

#-----------------------------------#
#    項目画像テーブルノード取得
#------------------------------------
#    引数｜項目画像テーブルノード一覧
#-----------------------------------#
sub GetTitleNode{
    my $self  = shift;
    my $table_PD2_nodes = shift;
    my $title = shift;

    foreach my $node (@$table_PD2_nodes) {
       if ($node->as_text eq $title) {
           return $node;
       }
    }
    return;
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
