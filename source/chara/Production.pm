#===================================================================
#        生産Lv取得パッケージ
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


#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#     
package Production;

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
    $self->{Datas}{Data}  = StoreData->new();
    my $header_list = "";
   
    $header_list = [
                "result_no",
                "generate_no",
                "e_no",
                "cook",
                "make",
                "composition",
                "addition",
    ];

    $self->{Datas}{Data}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/chara/production_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜e_no,名前データノード
#-----------------------------------#
sub GetData{
    my $self    = shift;
    my $e_no    = shift;
    my $table_charachter_data_node = shift;
    
    $self->{ENo} = $e_no;

    $self->GetNameData($table_charachter_data_node);
    
    return;
}
#-----------------------------------#
#    名前データ取得
#------------------------------------
#    引数｜名前データノード
#-----------------------------------#
sub GetNameData{
    my $self  = shift;
    my $table_charachter_data_node = shift;
    my ($name, $player) = ("", "");
    my %statuses = ();
    my %status_linking = (
                        "料理" => "cook",
                        "作製" => "make",
                        "合成" => "composition",
                        "付加" => "addition",
                        );

    my $table_status_nodes = &GetNode::GetNode_Tag_Attr("table", "width", "450", \$table_charachter_data_node);
    my $td_status_nodes = &GetNode::GetNode_Tag_Attr_RegExp("td", "class", "BG", \$table_charachter_data_node);

    foreach my $node (@$td_status_nodes) {
        if (exists($status_linking{$node->as_text})) {
            my $text = $node->right->as_text;
            $text =~ s/Lv.//;
            $statuses{ $status_linking{$node->as_text} } = $text;
        }
    }

    $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo}, $self->{ENo}, 
                                                        $statuses{"cook"}, $statuses{"make"},
                                                        $statuses{"composition"}, $statuses{"addition"},
                                                        ) ));

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
