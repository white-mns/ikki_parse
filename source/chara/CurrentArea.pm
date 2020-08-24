#===================================================================
#        現在地取得パッケージ
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
package CurrentArea;

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
                "area_id",
                "advance",
                "bellicosity",
    ];

    $self->{Datas}{Data}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/chara/current_area_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
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
    my $b_G5_nodes = shift;
    
    $self->{ENo} = $e_no;

    $self->GetCurrentAreaData($b_G5_nodes);
    
    return;
}
#-----------------------------------#
#    現在地データ取得
#------------------------------------
#    引数｜キャラクターデータノード
#-----------------------------------#
sub GetCurrentAreaData{
    my $self  = shift;
    my $b_G5_nodes = shift;

    foreach my $node (@$b_G5_nodes) {
        if (!$node->right || $node->right !~ /HASH/) { next;}

        my ($area_id, $advance, $bellicosity) = (0, -1, -1);
        my %areaQuota = ("平原" => 1, "水辺" => 2, "砂地" => 3, "城内" => 4, "森林" => 5, "山岳" => 6);

        my @lefts = $node->left;
        @lefts = reverse(@lefts);

        if ($lefts[1]->as_text =~ /［(.+)］(.+)/) {
            my $level  = $areaQuota{$1};
            my $area_text    = $2;

            $area_id = $self->{CommonDatas}{AreaData}->GetOrAddId(0, [$area_text, $level]);

        } else {
            $area_id = $self->{CommonDatas}{AreaData}->GetOrAddId(0, [$lefts[1]->as_text, 0]);
            
        }

        if ($node->as_text =~ /【進攻度(\d+?)】/) { $advance = $1}
        if ($node->right->as_text =~ /好戦度\+(\d+?)/) { $bellicosity = $1}

        $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo}, $self->{ENo}, $area_id, $advance, $bellicosity) ));
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
