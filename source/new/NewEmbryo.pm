#===================================================================
#        新出エンブリオ取得パッケージ
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
package NewEmbryo;

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
    $self->{Datas}{NewEmbryo} = StoreData->new();
    $self->{Datas}{AllEmbryo} = StoreData->new();
    my $header_list = "";
   
    $header_list = [
                "result_no",
                "generate_no",
                "embryo_id",
    ];

    $self->{Datas}{NewEmbryo}->Init($header_list);
    $self->{Datas}{AllEmbryo}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{NewEmbryo}->SetOutputName( "./output/new/embryo_"     . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    $self->{Datas}{AllEmbryo}->SetOutputName( "./output/new/all_embryo_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    
    $self->ReadLastNewData();

    return;
}

#-----------------------------------#
#    既存データを読み込む
#-----------------------------------#
sub ReadLastNewData(){
    my $self      = shift;
    
    my $file_name = "";
    # 前回結果の確定版ファイルを探索
    $file_name = "./output/new/all_embryo_" . sprintf("%d", ($self->{ResultNo} - 1)) . "_0.csv" ;
    
    #既存データの読み込み
    my $content = &IO::FileRead ( $file_name );
    
    my @file_data = split(/\n/, $content);
    shift (@file_data);
    
    foreach my  $data_set(@file_data){
        my $new_item_use_datas = []; 
        @$new_item_use_datas   = split(ConstData::SPLIT, $data_set);
        my $embryo_id = $$new_item_use_datas[2];
        if(!exists($self->{AllEmbryo}{$embryo_id})){
            $self->{AllEmbryo}{$embryo_id} = [$self->{ResultNo}, $self->{GenerateNo}, $embryo_id];
        }
    }

    return;
}

#-----------------------------------#
#    新出エンブリオの判定と記録
#------------------------------------
#    引数｜エンブリオID
#-----------------------------------#
sub RecordNewEmbryoData{
    my $self    = shift;
    my $embryo_id = shift;

    if (exists($self->{AllEmbryo}{$embryo_id})) {return;}

    $self->{Datas}{NewEmbryo}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo}, $embryo_id) ));

    $self->{AllEmbryo}{$embryo_id} = [$self->{ResultNo}, $self->{GenerateNo}, $embryo_id];

    return;
}
#-----------------------------------#
#    出力
#------------------------------------
#    引数｜
#-----------------------------------#
sub Output{
    my $self = shift;

    # 新出データ判定用の既出情報の書き出し
    foreach my $id (sort{$a cmp $b} keys %{ $self->{AllEmbryo} } ) {
        $self->{Datas}{AllEmbryo}->AddData(join(ConstData::SPLIT, @{ $self->{AllEmbryo}{$id} }));
    }
    
    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    return;
}
1;
