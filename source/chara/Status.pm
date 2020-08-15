#===================================================================
#        ステータス取得パッケージ
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
package Status;

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
                "clv",
                "ikki",
                "guardian_id",
                "cp",
                "ps",
                "mhp",
                "msp",
                "psp",
                "str",
                "vit",
                "tec",
                "int",
                "mnd",
                "agi",
    ];

    $self->{Datas}{Data}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/chara/status_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
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
    my %statuses = ();
    my %status_linking = (
                        "CLV" => "clv",
                        "一揆" => "ikki",
                        "守護" => "guardian_id",
                        "CP" => "cp",
                        "PS" => "ps",
                        "MHP" => "mhp",
                        "MSP" => "msp",
                        "PSP" => "psp",
                        "STR" => "str",
                        "VIT" => "vit",
                        "TEC" => "tec",
                        "INT" => "int",
                        "MND" => "mnd",
                        "AGI" => "agi",
                        );

    my $table_status_nodes = &GetNode::GetNode_Tag_Attr("table", "width", "450", \$table_charachter_data_node);
    my $td_status_nodes = &GetNode::GetNode_Tag_Attr_RegExp("td", "class", "BG", \$table_charachter_data_node);

    foreach my $node (@$td_status_nodes) {
        if (exists($status_linking{$node->as_text})) {
            if ($node->as_text =~ "守護") {
                $statuses{ $status_linking{$node->as_text} } = $self->{CommonDatas}{ProperName}->GetOrAddId($node->right->as_text);

            } else {
                $statuses{ $status_linking{$node->as_text} } = $node->right->as_text;
            }
        }
    }

    $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo}, $self->{ENo}, 
                                                        $statuses{"clv"}, $statuses{"ikki"}, $statuses{"guardian_id"},
                                                        $statuses{"cp"}, $statuses{"ps"},
                                                        $statuses{"mhp"}, $statuses{"msp"}, $statuses{"psp"},
                                                        $statuses{"str"}, $statuses{"vit"}, $statuses{"tec"},
                                                        $statuses{"int"}, $statuses{"mnd"}, $statuses{"agi"},
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
