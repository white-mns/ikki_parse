#===================================================================
#        新出予告敵取得パッケージ
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
package NewNextEnemy;

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
    $self->{Datas}{NewNextEnemy} = StoreData->new();
    $self->{Datas}{AllNextEnemy} = StoreData->new();
    my $header_list = "";
   
    $header_list = [
                "result_no",
                "generate_no",
                "enemy_id",
                "is_boss",
    ];

    $self->{Datas}{NewNextEnemy}->Init($header_list);
    $self->{Datas}{AllNextEnemy}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{NewNextEnemy}->SetOutputName( "./output/new/next_enemy_"     . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    $self->{Datas}{AllNextEnemy}->SetOutputName( "./output/new/all_next_enemy_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    
    $self->ReadLastNewData();

    return;
}

#-----------------------------------#
#    既存データを読み込む
#-----------------------------------#
sub ReadLastNewData(){
    my $self      = shift;
    
    my $file_name = "";
    $file_name = "./output/new/all_next_enemy_" . ($self->{ResultNo} - 1) . "_0.csv" ;
    
    #既存データの読み込み
    my $content = &IO::FileRead ( $file_name );
    
    my @file_data = split(/\n/, $content);
    shift (@file_data);
    
    foreach my  $data_set(@file_data){
        my $new_next_enemy_datas = []; 
        @$new_next_enemy_datas   = split(ConstData::SPLIT, $data_set);
        my $enemy_id = $$new_next_enemy_datas[2];
        if(!exists($self->{AllNextEnemy}{$enemy_id})){
            $self->{AllNextEnemy}{$enemy_id} = [$self->{ResultNo}, $self->{GenerateNo}, $enemy_id];
        }
    }

    return;
}

#-----------------------------------#
#    新規予告敵の判定と記録
#------------------------------------
#    引数｜固有名詞ID
#          ボスフラグ
#-----------------------------------#
sub RecordNewNextEnemyData{
    my $self    = shift;
    my $enemy_id = shift;
    my $is_boss  = shift;

    if (exists($self->{AllNextEnemy}{$enemy_id})) {return;}

    $self->{Datas}{NewNextEnemy}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo}, $enemy_id, $is_boss) ));

    $self->{AllNextEnemy}{$enemy_id} = [$self->{ResultNo}, $self->{GenerateNo}, $enemy_id];

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
    foreach my $id (sort{$a cmp $b} keys %{ $self->{AllNextEnemy} } ) {
        $self->{Datas}{AllNextEnemy}->AddData(join(ConstData::SPLIT, @{ $self->{AllNextEnemy}{$id} }));
    }
    
    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    return;
}
1;
