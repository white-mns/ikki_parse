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
package Embryo;

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
                "order",
                "embryo_id",
                "is_physics",
                "lv",
    ];

    $self->{Datas}{Data}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/chara/embryo_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
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
    my $table_PD2_nodes = shift;
    
    $self->{ENo} = $e_no;

    $self->GetEmbryoData($table_PD2_nodes);
    
    return;
}
#-----------------------------------#
#    エンブリオデータ取得
#------------------------------------
#    引数｜名前データノード
#-----------------------------------#
sub GetEmbryoData{
    my $self  = shift;
    my $table_PD2_nodes = shift;

    my $embryo_title_node = "";

    foreach my $node (@$table_PD2_nodes) {
       if ($node->as_text eq "エンブリオ") {
           $embryo_title_node = $node;
       }
    }

    if ($embryo_title_node !~ /HASH/) {return;}

    my $order = 0;

    my @embryo_right_nodes = $embryo_title_node->right;


    foreach my $embryo_right_node (@embryo_right_nodes) {
        if ($embryo_right_node->attr("class") && $embryo_right_node->attr("class") eq "PD2") {last;}

        my ($embryo_id, $is_physics, $lv) = (0, -1, -1);
        
        my $td_nodes = &GetNode::GetNode_Tag("td", \$embryo_right_node);

        if (!$$td_nodes[0] || $$td_nodes[0] !~ /HASH/ || 
            !$$td_nodes[0]->attr("class") || $$td_nodes[0]->attr("class") ne "Y4i" || 
            !$$td_nodes[0]->as_text || $$td_nodes[0]->as_text !~ /\d+/ || 
            !$$td_nodes[1]->as_text || $$td_nodes[1]->as_text !~ /Lv\./) { next;}

        my $order = $$td_nodes[0]->as_text; 
        
        my $a_nodes = &GetNode::GetNode_Tag("a", \$$td_nodes[1]);
        my @a_child_nodes = $$a_nodes[0]->content_list;
        $is_physics = ($a_child_nodes[0]->attr("src") =~ /eb/) ? 1 : 0;
        
        if ($a_child_nodes[1]->as_text =~ /(.+) Lv.(\d+)/) {
            $embryo_id = $self->{CommonDatas}{EmbryoName}->GetOrAddId($1);
            $lv = $2;
        }

        $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo}, $self->{ENo}, $order, $embryo_id, $is_physics, $lv) ));

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
