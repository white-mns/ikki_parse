#===================================================================
#        新出予告敵取得パッケージ
#-------------------------------------------------------------------
#            (C) 2019 @white_mns
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
package NewBattleEnemy;

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
    $self->{Datas}{NewBattleEnemy} = StoreData->new();
    $self->{Datas}{AllBattleEnemy} = StoreData->new();
    my $header_list = "";
   
    $header_list = [
                "result_no",
                "generate_no",
                "enemy_id",
                "is_boss",
                "area_id",
                "advance",
    ];

    $self->{Datas}{NewBattleEnemy}->Init($header_list);
    $self->{Datas}{AllBattleEnemy}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{NewBattleEnemy}->SetOutputName( "./output/new/battle_enemy_"     . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    $self->{Datas}{AllBattleEnemy}->SetOutputName( "./output/new/all_battle_enemy_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    
    $self->ReadLastNewData();

    return;
}

#-----------------------------------#
#    既存データを読み込む
#-----------------------------------#
sub ReadLastNewData(){
    my $self      = shift;
    
    my $file_name = "";
    $file_name = "./output/new/all_battle_enemy_" . ($self->{ResultNo} - 1) . "_0.csv" ;
    
    #既存データの読み込み
    my $content = &IO::FileRead ( $file_name );
    
    my @file_data = split(/\n/, $content);
    shift (@file_data);
    
    foreach my  $data_set(@file_data){
        my $new_battle_enemy_datas = [];
        @$new_battle_enemy_datas   = split(ConstData::SPLIT, $data_set);
        my $enemy_id = $$new_battle_enemy_datas[2];
        if(!exists($self->{AllBattleEnemy}{$enemy_id})){
            $self->{AllBattleEnemy}{$enemy_id} = [$self->{ResultNo}, $self->{GenerateNo}, $enemy_id];
        }
    }

    return;
}

#-----------------------------------#
#    新規予告敵の判定と記録
#------------------------------------
#    引数｜固有名詞ID
#-----------------------------------#
sub RecordNewBattleEnemyData{
    my $self    = shift;
    my $enemy_id = shift;
    my $is_boss = shift;
    my $area_id  = shift;
    my $advance  = shift;

    if (exists($self->{AllBattleEnemy}{$enemy_id})) {return;}

    $self->{Datas}{NewBattleEnemy}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo}, $enemy_id, $is_boss, $area_id, $advance) ));

    $self->{AllBattleEnemy}{$enemy_id} = [$self->{ResultNo}, $self->{GenerateNo}, $enemy_id];

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
    foreach my $id (sort{$a cmp $b} keys %{ $self->{AllBattleEnemy} } ) {
        $self->{Datas}{AllBattleEnemy}->AddData(join(ConstData::SPLIT, @{ $self->{AllBattleEnemy}{$id} }));
    }
    
    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    return;
}
1;
