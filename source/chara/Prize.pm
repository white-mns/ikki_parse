#===================================================================
#        賞金取得パッケージ
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
package Prize;

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
    $self->{CommonDatas}{Prize} = {};
    
    #初期化
    $self->{Datas}{Data}  = StoreData->new();
    my $header_list = "";
   
    $header_list = [
                "result_no",
                "generate_no",
                "e_no",
                "prize",
    ];

    $self->{Datas}{Data}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/chara/prize_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜e_no,キャラクターデータノード
#-----------------------------------#
sub GetData{
    my $self    = shift;
    my $e_no    = shift;
    my $table_charachter_data_node = shift;
    
    $self->{ENo} = $e_no;

    $self->GetPrizeData($table_charachter_data_node);
    
    return;
}
#-----------------------------------#
#    賞金データ取得
#------------------------------------
#    引数｜キャラクターデータノード
#-----------------------------------#
sub GetPrizeData{
    my $self  = shift;
    my $table_charachter_data_node = shift;
    my $prize = 0;

    my $td_wtd_nodes = &GetNode::GetNode_Tag_Attr("td", "class", "WTD", \$table_charachter_data_node);

    if (scalar(@$td_wtd_nodes)) {
        $prize = $$td_wtd_nodes[0]->as_text;
        $prize =~ s/ PS//g;
    }

    $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo}, $self->{ENo}, $prize) ));
    $self->{CommonDatas}{Prize}{$self->{ENo}} = $prize;

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
